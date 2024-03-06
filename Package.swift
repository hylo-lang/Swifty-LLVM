// swift-tools-version: 5.9
import PackageDescription


// BEGIN: Poor person's pkg-config processing, since SPM doesn't
// fully understand pkg-config files on Windows.
import Foundation

#if os(Windows)
  let osIsWindows = true
#else
  let osIsWindows = false
#endif

/// The text used to separate elements of the PATH environment variable.
let pathSeparator: Character = osIsWindows ? ";" : ":"

/// Returns the contents of the pkg-config file for `package` if they
/// can be found in `PKG_CONFIG_PATH`.
///
/// N.B. Does not search the standard locations for the file as
/// pkg-config would.
func pseudoPkgConfigText(_ package: String) -> String? {
  guard let pcp = ProcessInfo.processInfo.environment["PKG_CONFIG_PATH"] else { return nil }

  return pcp.split(separator: pathSeparator)
    .lazy.compactMap({ try? String(contentsOfFile: "\($0)/\(package).pc") }).first
}

/// Returns the un-quoted, un-escaped elements in the remainder of the
/// any (logical) lines beginning with `"\(key): "` in pcFileText, the contents
/// of a pkg-config file.
func pkgConfigValues(in pcFileText: String, for key: String) -> [String] {
  let keyPattern = NSRegularExpression.escapedPattern(for: key)
  let lineHeaders = pcFileText.matches(
    forRegex: #"(?m)(?<!\\[\r]?[\n])^[ \t]*"# + keyPattern
      + #"[ \t]*:[ \t]*"#).joined().compactMap { $0 }

  var r: [String] = []

  for h in lineHeaders {
    var input = pcFileText[h.endIndex...]
    var open = false
    func add(_ c: Character) {
      if !open { r.append("") }
      r[r.count - 1].append(c)
      open = true
    }

    header:
      while let c = input.popFirst(), !c.isNewline {
      switch c {
      case "'", "\"":
        let quote = c
        quoting:
          while let c1 = input.popFirst() {
          switch c1 {
          case "\\":
            if let c2 = input.popFirst() { add(c2) }
          case quote:
            break quoting
          default: add(c1)
          }
        }
      case "\\": if let c1 = input.popFirst() { add(c1) }
      case _ where c.isNewline: break header
      case _ where c.isWhitespace: open = false
      case _: add(c)
      }
    }
  }
  return r
}

extension String {

  /// Returns, for each match of the valid regular expression
  /// `pattern`, the given match `groups` in the same order in which
  /// they were passed.
  func matches(forRegex pattern: String, groups: [Int] = [0]) -> [[Substring?]] {
    let r = try! NSRegularExpression(pattern: pattern)
    return r.matches(
      in: self,
      range: NSRange(startIndex..<endIndex, in: self)
    ).map { m in
      groups.map { g in
        Range(m.range(at: g), in: self).map { self[ $0 ] }
      }
    }
  }

}

// END: Poor person's pkg-config processing.  Used to implement
// `windowsSettings()` below.

/// Returns the linker needed for building on Windows.
func windowsLinkerSettings() -> [LinkerSetting] {
  guard let t = pseudoPkgConfigText("llvm") else { return [] }

  let libs = pkgConfigValues(in: t, for: "Libs")
  let linkLibraries = libs.lazy.filter { $0.starts(with: "-l") || $0.first != "-" }.map {
    let rest = $0.dropFirst($0.first == "-" ? 2 : 0)
    let afterSlashes = rest.lastIndex(where: { $0 == "/" || $0 == "\\" })
      .map { rest.index(after: $0) } ?? rest.startIndex
    return rest[afterSlashes...]
  }

  return Array(
    linkLibraries
      .filter { $0.hasPrefix("LLVM") && $0.hasSuffix(".lib") }
      .map { LinkerSetting.linkedLibrary(String($0.dropLast(4))) })
}

let llvmLinkerSettings = osIsWindows ? windowsLinkerSettings() : []

let package = Package(
  name: "Swifty-LLVM",
  products: [
    .library(name: "SwiftyLLVM", targets: ["SwiftyLLVM"]),
  ],
  targets: [
    // LLVM API Wrappers.
    .target(
      name: "SwiftyLLVM",
      dependencies: ["llvmc", "llvmshims"],
      swiftSettings: [.unsafeFlags(["-enable-experimental-feature", "AccessLevelOnImport"])],
      linkerSettings: llvmLinkerSettings),
    .target(
      name: "llvmshims",
      dependencies: ["llvmc"],
      linkerSettings: llvmLinkerSettings),

    // Tests.
    .testTarget(name: "LLVMTests", dependencies: ["SwiftyLLVM"]),

    // LLVM's C API
    .systemLibrary(name: "llvmc", pkgConfig: "llvm"),
  ],
  cxxLanguageStandard: .cxx20)
