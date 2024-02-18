import llvmc

/// The type of a value in LLVM IR.
internal struct AnyType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMTypeRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm` in `context`.
  internal init(_ llvm: LLVMTypeRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

}
