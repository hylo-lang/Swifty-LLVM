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

extension Optional {

  /// Returns the value wrapped in `optional` or calls `trap` if `optional` is `nil`.
  public static func ?? (optional: Self, trap: @autoclosure () -> Never) -> Wrapped {
    if let wrapped = optional { wrapped } else { trap() }
  }

}

// MARK: Helpers for getting flags and other settings

/// Returns the value of the environment variable with given key.
///
/// On Windows, comparison is case-insensitive.
func environmentEntry(forKey k: String) -> String? {
  if osIsWindows {
    ProcessInfo.processInfo.environment.first {
      $0.key.caseInsensitiveCompare(k) == .orderedSame
    }?.value
  } else {
    ProcessInfo.processInfo.environment[k]
  }
}

/// Returns the path to an executable named `name` or `name.exe` if one can be found at one of the
/// locations in the PATH environment variable; otherwise, returns `nil`.
func findExecutableOnPath(name: String) -> String? {
  let path = environmentEntry(forKey: "PATH") ?? fatalError("No PATH environment variable found")

  let executableFileName = osIsWindows ? "\(name).exe" : name

  let locations = path.split(separator: pathSeparator)
  for l in locations {
    let p = URL(fileURLWithPath: String(l)).appendingPathComponent(executableFileName).path
    if FileManager.default.isExecutableFile(atPath: p) { return p }
  }
  return nil
}

/// Returns the contents written to the standard output by `executable` ran with `arguments`, or
/// `nil` on failure.
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
    let libraries = readProcessOutput(
      executable: executable,
      arguments: ["libzstd", "--libs-only-L"])
  {
    return libraries.trimmingCharacters(in: .whitespacesAndNewlines)
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

#if os(macOS)
  let llvmLinkerSettings: [LinkerSetting] = [.unsafeFlags([zstdLinkerFlagsForMacOS()])]
#else
  let llvmLinkerSettings: [LinkerSetting] = []
#endif

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
