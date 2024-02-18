import llvmc

/// An instruction in LLVM IR.
public struct Instruction: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm` in `context`.
  internal init(_ llvm: LLVMValueRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

}
