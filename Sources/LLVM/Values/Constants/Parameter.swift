import llvmc

/// A parameter in a LLVM IR function.
public struct Parameter: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Creates an intance with `v`, failing iff `v` is not a parameter.
  public init?(_ v: IRValue) {
    if let h = LLVMIsAArgument(v.llvm) {
      self.llvm = h
    } else {
      return nil
    }
  }

}
