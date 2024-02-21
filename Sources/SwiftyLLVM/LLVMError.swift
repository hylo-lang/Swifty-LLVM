/// An error that occurred during a LLVM operation.
public struct LLVMError: Error {

  /// A description of the error.
  public let description: String

  /// Creates an instance with given `description`.
  internal init(_ description: String) {
    self.description = description
  }

}
