#!/usr/bin/env swift

import Foundation

/// An error indicating that the compiler's environment is not properly configured.
struct EnvironmentError: Error {

  /// The error's message.
  let message: String

}

extension String {

  func replacingNewlinesBySpaces() -> String {
    reduce(into: "") { (s, c) in
      s.append(c.isNewline ? " " : c)
    }
  }

}

let currentDirectory = URL(
  fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)

/// Returns the path of the specified executable.
func find(_ executable: String) throws -> String {
  // Nothing to do if `executable` is a path
  if executable.contains("/") {
    return executable
  }

  // Search in the current working directory.
  var candidateURL = currentDirectory.appendingPathComponent(executable)
  if FileManager.default.fileExists(atPath: candidateURL.path) {
    return candidateURL.path
  }

  // Search in the PATH.
  #if os(Windows)
    let environmentPath = ProcessInfo.processInfo.environment["Path"] ?? ""
    for base in environmentPath.split(separator: ";") {
      candidateURL = URL(fileURLWithPath: String(base)).appendingPathComponent(executable)
      if FileManager.default.fileExists(atPath: candidateURL.path + ".exe") {
        return candidateURL.path
      }
    }
  #else
    let environmentPath = ProcessInfo.processInfo.environment["PATH"] ?? "/usr/bin"
    for base in environmentPath.split(separator: ":") {
      candidateURL = URL(fileURLWithPath: String(base)).appendingPathComponent(executable)
      if FileManager.default.fileExists(atPath: candidateURL.path) {
        return candidateURL.path
      }
    }
    if let p = runCommandLine("/usr/bin/which", [executable]) {
      return URL(fileURLWithPath: p)
    }
  #endif
  throw EnvironmentError(message: "executable not found: \(executable)")
}

/// Executes the program at `path` with the specified arguments in a subprocess.
@discardableResult
func runCommandLine(
  _ programPath: String,
  _ arguments: [String] = []
) throws -> String? {
  print(([programPath] + arguments).joined(separator: " "))
  
  let pipe = Pipe()
  let process = Process()
  process.executableURL = URL(fileURLWithPath: programPath)
  process.arguments = arguments
  process.standardOutput = pipe
  try process.run()
  process.waitUntilExit()

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(data: data, encoding: .utf8).flatMap({ (result) -> String? in
    let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  })
}

let llvmConfigExecutable = try find("llvm-config")

func llvmConfig(_ arguments: String...) throws -> String? {
  try runCommandLine(llvmConfigExecutable, arguments)
}

let requiredVersionMajor = CommandLine.arguments.count > 0 ? Int(CommandLine.arguments[1])! : 15

guard let version = try llvmConfig("--version") else {
  throw EnvironmentError(message: "cannot identify LLVM version")
}

let versionComponents = version.components(separatedBy: ".").compactMap({ Int($0) })
guard versionComponents.count == 3 else {
  throw EnvironmentError(message: "invalid LLVM version: \(version)")
}
guard versionComponents[0] >= requiredVersionMajor else {
  throw EnvironmentError(message: "requires LLVM \(requiredVersionMajor)")
}

#if os(Linux)
  var libs = "-L/usr/lib -lc++ -L"
#elseif os(macOS)
  var libs = "-lc++ -L"
#endif
libs +=
  try llvmConfig("--libdir", "--system-libs", "--libs",  "core", "analysis")!
    .replacingNewlinesBySpaces()
let cflags = try "-I" + llvmConfig("--includedir")!.replacingNewlinesBySpaces()

let file = """
Name: LLVM
Description: Low-level Virtual Machine compiler framework
Version: \(versionComponents.map(String.init(describing:)).joined(separator: "."))
URL: http://www.llvm.org/
Libs: \(libs)
Cflags: \(cflags)
"""

try file.write(
  to: URL(fileURLWithPath: "/usr/local/lib/pkgconfig/llvm.pc"),
  atomically: true,
  encoding: String.Encoding.utf8)
