import llvmc

/// A basic block in LLVM IR.
public struct BasicBlock: Hashable, Contextual {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMBasicBlockRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMBasicBlockRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

}

extension BasicBlock: CustomStringConvertible {

  public var description: String {
    guard let s = LLVMGetBasicBlockName(llvm) else { return "" }
    return String(cString: s)
  }

}
