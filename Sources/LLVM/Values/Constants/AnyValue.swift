import llvmc

/// A value in LLVM IR.
internal struct AnyValue: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm` in `context`.
  internal init(_ llvm: LLVMValueRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

}
