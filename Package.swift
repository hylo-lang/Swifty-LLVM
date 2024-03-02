// swift-tools-version: 5.9
import PackageDescription


// BEGIN: Poor person's pkg-config processing, since SPM doesn't
// understand pkg-config files on Windows.
import Foundation

#if os(Windows)
  let osIsWindows = true
#else
  let osIsWindows = false
#endif


/// The text used to separate elements of the PATH environment variable.
let pathSeparator = osIsWindows ? ";" : ":"

/// Returns the first capture group text for regular expression
/// matches to `pattern` in the `Libs:` line of `package`'s pkg-config
/// file.
func pkgCongigLibsMatches(package: String, pattern: String) -> [Substring] {
  guard let pcp = ProcessInfo.processInfo.environment["PKG_CONFIG_PATH"],
        let llvm_pc_text = pcp.split(separator: pathSeparator).lazy
          .compactMap({ try? String(contentsOfFile: "\($0)/\(package).pc") }).first,
        let libs_line = llvm_pc_text.split(whereSeparator: { $0.isNewline })
          .first(where: { $0.starts(with: "Libs: ") })
  else { return [] }

  // Swift.Regex is not available in Package.swift, so must use
  // NSRegularExpression, which makes this code uglier than necessary

  let libName = try! NSRegularExpression(pattern: pattern)

  let libs = String(libs_line)
  return libName.matches(
    in: libs,
    range: NSRange(libs.startIndex..<libs.endIndex, in: libs)
  ).map { libs[ Range($0.range(at: 1), in: libs)! ] }
}

let customLinkerSettings: [LinkerSetting]
  = osIsWindows ? pkgCongigLibsMatches(
    package: "llvm", pattern: #"(LLVM[^\/. "+"\t" +#"]+.lib)(\s|"|$)"#)
  .map {.linkedLibrary(String($0))} : []

// END: Poor person's pkg-config processing, since SPM doesn't
// understand pkg-config files on Windows.

let package = Package(
  name: "Swifty-LLVM",
  products: [
    .library(name: "LLVM", targets: ["LLVM"]),
  ],
  targets: [
    // LLVM API Wrappers.
    .target(
      name: "LLVM",
      dependencies: ["llvmc", "llvmshims"],
      linkerSettings: customLinkerSettings),
    .target(
      name: "llvmshims",
      dependencies: ["llvmc"],
      linkerSettings: customLinkerSettings),

    // Tests.
    .testTarget(name: "LLVMTests", dependencies: ["LLVM"]),

    // LLVM's C API
    .systemLibrary(name: "llvmc", pkgConfig: "llvm"),
  ],
  cxxLanguageStandard: .cxx20)
