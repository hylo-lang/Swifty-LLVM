internal import llvmc

/// A basic block in LLVM IR.
public struct BasicBlock: Hashable { // todo make non-copyable
  /// A handle to the LLVM object wrapped by this instance.
  private let llvm: BasicBlockReference

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMBasicBlockRef) {
    self.llvm = .init(llvm)
  }

  /// The name of the basic block.
  /// 
  /// Empty if not present.
  public var name: String {
    guard let s = LLVMGetBasicBlockName(llvm.raw) else { return "" }
    return String(cString: s)
  }

}

// extension BasicBlock: CustomStringConvertible { // is this needed?

//   public var description: String { name }

// }
