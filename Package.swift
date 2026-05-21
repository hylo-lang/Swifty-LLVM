// swift-tools-version:6.2

// MARK: Poor person's pkg-config processing, required to handle pkg-config files on Windows.

import Foundation
import PackageDescription

#if os(Windows)
  let osIsWindows = true
#else
  let osIsWindows = false
#endif

/// The text used to separate elements of the PATH environment variable.
let pathSeparator: Character = osIsWindows ? ";" : ":"

/// Returns the contents of the pkg-config file for `package` if they can be found in
/// `PKG_CONFIG_PATH`.
///
/// This function does not search the standard locations for the file as pkg-config would.
func pkgConfigContents(_ package: String) -> String? {
  if let p = ProcessInfo.processInfo.environment["PKG_CONFIG_PATH"] {
    for q in p.split(separator: pathSeparator) {
      if let s = try? String(contentsOfFile: "\(q)/\(package).pc", encoding: .utf8) { return s }
    }
  }
  return nil
}

/// Returns the un-quoted, un-escaped elements in the remainder of the (logical) lines beginning
/// with `"\(key): "` in `pcContents`, which are the contents of a pkg-config file.
func pkgConfigValues(in pcContents: String, for key: String) throws -> [String] {
  let keyPattern = NSRegularExpression.escapedPattern(for: key)
  let lineHeadersPattern = #"(?m)(?<!\\[\r]?[\n])^[ \t]*"# + keyPattern + #"[ \t]*:[ \t]*"#
  let lineHeaders = try pcContents.matches(forRegex: lineHeadersPattern).joined().compactMap { $0 }

  var r: [String] = []
  for h in lineHeaders {
    var input = pcContents[h.endIndex...]

    func add(_ c: Character) {
      r[r.count - 1].append(c)
    }

    header: while let c = input.popFirst(), !c.isNewline {
      switch c {
      case "'", "\"":
        let quote = c
        quoting: while let c1 = input.popFirst() {
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
      case _ where c.isWhitespace: break
      case _: r[r.count - 1].append(c)
      }
    }
  }
  return r
}

extension String {

  /// Returns, for each match of the valid regular expression `pattern`, the given match `groups`
  /// in the same order in which they were passed.
  func matches(forRegex pattern: String, groups: [Int] = [0]) throws -> [[Substring?]] {
    let r = try NSRegularExpression(pattern: pattern)
    return r.matches(in: self, range: NSRange(startIndex..<endIndex, in: self)).map { m in
      groups.map { g in Range(m.range(at: g), in: self).map { self[ $0 ] } }
    }
  }

}

extension Substring {

  /// Returns `prefix` if `self` is equal to `prefix + suffix`; otherwise, returns `self`.
  func droppingSuffix(_ suffix: String) -> Substring {
    self.hasSuffix(suffix) ? Substring(self.dropLast(suffix.count)) : self
  }

}

extension Optional {

  /// Returns the value wrapped in `optional` or calls `trap` if `optional` is `nil`.
  public static func ?? (optional: Self, trap: @autoclosure () -> Never) -> Wrapped {
    if let wrapped = optional { wrapped } else { trap() }
  }

}

// MARK: Helpers for getting flags and other settings

/// Returns the linker needed for building on Windows.
func windowsLinkerSettings() -> [LinkerSetting] {
  let t = pkgConfigContents("llvm") ??
    fatalError("Didn't find llvm.pc in any of the locations of PKG_CONFIG_PATH.")

  do {
    let libs = try pkgConfigValues(in: t, for: "Libs")
    return libs.compactMap { (lib) -> LinkerSetting? in
      if !lib.starts(with: "-l") && (lib.first == "-") { return nil }

      let rest = lib.dropFirst(lib.first == "-" ? 2 : 0)
      let afterSlashes = rest.lastIndex(where: { $0 == "/" || $0 == "\\" })
        .map { rest.index(after: $0) } ?? rest.startIndex

      let s = rest[afterSlashes...].droppingSuffix(".lib")
      return LinkerSetting.linkedLibrary(String(s))
    }
  } catch {
    fatalError("Failed to acquire pkg-config values. Error: \(error)")
  }
}

/// Returns the path to an executable named `name` or `name.exe` if one can be found at one of the
/// locations in the PATH environment variable; otherwise, returns `nil`.
func findExecutableOnPath(name: String) -> String? {
  let path = ProcessInfo.processInfo.environment["PATH"] 
    ?? fatalError("No PATH environment variable found")

  let executableFileName = osIsWindows ? "\(name).exe" : name

  let locations = path.split(separator: pathSeparator)
  for l in locations {
    let p = URL(fileURLWithPath: String(l)).appendingPathComponent(executableFileName).path
    if FileManager.default.isExecutableFile(atPath: p) { return p }
  }
  return nil
}

/// Returns the contents written to the standard output by `executable` ran with `arguments`.
func readProcessOutput(executable: String, arguments: [String]) -> String? {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: executable)
  process.arguments = arguments

  let pipe = Pipe()
  process.standardOutput = pipe
  do {
    try process.run()
  } catch {
    print("Failed to run process. Error: \(error)")
    return nil
  }
  process.waitUntilExit()

  guard process.terminationStatus == 0 else {
    print("Process terminated with status \(process.terminationStatus)")
    return nil
  }

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(data: data, encoding: .utf8) ?? fatalError("Failed to read process output")
}

/// Returns the flags for linking zstd on macOS.
///
/// LLVM requires zstd, which is a dependency, to be linked dynamically. This function returns the
/// flags instructing the linker to do so.
///
/// This function does not work on Windows, as zstd does not include a pkg-config file on that
/// platform. It is also not reliable on Linux yet because zstd generates wrong pkgconfig. TL;DR:
/// libzstd.pc contains a non-architecture specific library directory on Linux.
/// See https://github.com/facebook/zstd/issues/4488
///
/// The returned flags are only needed on macOS. Windows and Linux link zstd already.
func zstdLinkerFlagsForMacOS() -> String {
  if let executable = findExecutableOnPath(name: "pkg-config"),
    let ls = readProcessOutput(
      executable: executable,
      arguments: ["libzstd", "--libs-only-L"])
  {
    return ls.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  // Fallback: search common directories where zstd may be installed.
  let commonPaths = [
    "/opt/local/lib",  // MacPorts
    "/opt/homebrew/lib",  // Homebrew (Apple Silicon)
    "/usr/local/lib",  // Homebrew (Intel)
  ]
  for path in commonPaths {
    if FileManager.default.fileExists(atPath: "\(path)/libzstd.dylib")
      || FileManager.default.fileExists(atPath: "\(path)/libzstd.a")
    {
      return "-L\(path)"
    }
  }
  fatalError("Failed to find zstd library both via pkg-config and common paths.")
}

let llvmLinkerSettings =
  osIsWindows
  ? windowsLinkerSettings()
  : [.unsafeFlags([zstdLinkerFlagsForMacOS()], .when(platforms: [.macOS]))]

// MARK: Package manifest

let package = Package(
  name: "Swifty-LLVM",
  platforms: [
    .macOS(.v15),
  ],
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
