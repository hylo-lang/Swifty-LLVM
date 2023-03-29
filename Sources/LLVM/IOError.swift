/// An error that occurred during an IO operation.
public enum IOError: Error {

  /// Data could not be written to a file.
  case writeFailure

  /// Data could not be read.
  case readFailure(message: String)

}

extension IOError: CustomStringConvertible {

  public var description: String {
    switch self {
    case .writeFailure:
      return "write failure"
    case .readFailure(let m):
      return "read failure: \(m)"
    }
  }

}
