internal import llvmc

/// A value in LLVM IR.
internal struct AnyValue: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueReference

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: ValueReference) {
    self.llvm = llvm
  }

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = ValueReference(llvm)
  }
  
}
