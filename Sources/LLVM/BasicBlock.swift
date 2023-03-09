import llvmc

/// A basic block in LLVM IR.
public struct BasicBlock: Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMBasicBlockRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMBasicBlockRef) {
    self.llvm = llvm
  }

}

extension BasicBlock: CustomStringConvertible {

  public var description: String {
    guard let s = LLVMGetBasicBlockName(llvm) else { return "" }
    return String(cString: s)
  }

}
