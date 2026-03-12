/// An error that occurred during an LLVM operation.
public struct LLVMError: Error, Sendable {

  /// A description of the error.
  public let description: String

  /// Creates an error with a given message.
  internal init(_ description: String) {
    self.description = description
  }

}
