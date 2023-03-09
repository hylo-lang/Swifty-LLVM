#!/usr/bin/env swift

import Foundation

/// An error indicating that the compiler's environment is not properly configured.
struct EnvironmentError: Error, CustomStringConvertible {

  /// The error's message.
  let description: String

  /// Creates an instance with given `messsage`.
  init(_ messsage: String) { self.description = messsage }

}

extension String {

  /// Returns `self` in which occurrences of new lines have been replaced by spaces.
  func replacingNewlinesBySpaces() -> String {
    reduce(into: "") { (s, c) in
      s.append(c.isNewline ? " " : c)
    }
  }

}

extension FileHandle: TextOutputStream {
  
  public func write(_ string: String) {
    let data = Data(string.utf8)
    self.write(data)
  }

}

/// The required major version of LLVM.
let requiredMajor = CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1])! : 15

/// The current working directly.
let currentDirectory = URL(
  fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)

/// The standard error.
var stderr = FileHandle.standardError

/// Returns the path of the specified executable.
func find(_ executable: String) throws -> String {
  if executable.contains("/") { return executable }

  // Look in the current working directory.
  var candidateURL = currentDirectory.appendingPathComponent(executable)
  if FileManager.default.fileExists(atPath: candidateURL.path) {
    return candidateURL.path
  }

  // Look in the PATH.
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
  #endif

  throw EnvironmentError("executable not found: \(executable)")
}

/// Executes the program at `programPath` with given `arguments`` in a subprocess.
@discardableResult
func runCommandLine(_ programPath: String, _ arguments: [String] = []) throws -> String? {  
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

/// Generates a pkg-config file specific to this system's configuration.
func generateConfigFile() throws {
  let llvmConfigExecutable = try find("llvm-config")

  func llvmConfig(_ arguments: String...) throws -> String? {
    try runCommandLine(llvmConfigExecutable, arguments)
  }

  guard 
    let llvmRoot = try llvmConfig("--src-root"),
    let version = try llvmConfig("--version")
  else {
    throw EnvironmentError("cannot locate LLVM")
  }
  print("note: found LLVM \(version) at \(llvmRoot)", to: &stderr)

  let versionComponents = version.components(separatedBy: ".").compactMap({ Int($0) })
  guard versionComponents.count == 3 else {
    throw EnvironmentError("invalid LLVM version: \(version)")
  }
  guard versionComponents[0] >= requiredMajor else {
    throw EnvironmentError("requires LLVM \(requiredMajor) but found \(version)")
  }

  var libs = try "-L\(llvmConfig("--libdir", "--system-libs", "--libs",  "core", "analysis")!)"
    .replacingNewlinesBySpaces()
  #if os(Linux)
    libs += " -L/usr/lib -lc++"
  #elseif os(macOS)
    libs += " -lc++"
  #endif
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
    to: URL(fileURLWithPath: "llvm.pc"),
    atomically: true,
    encoding: String.Encoding.utf8)
}

do {
  try generateConfigFile()
} catch {
  print("error: \(error)", to: &stderr)
  exit(-1)
}