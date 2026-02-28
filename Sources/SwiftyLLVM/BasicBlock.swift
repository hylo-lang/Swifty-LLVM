internal import llvmc

/// A basic block in LLVM IR.
public struct BasicBlock: Hashable, LLVMEntity {
  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: BasicBlockRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: BasicBlockRef) {
    self.llvm = handle
  }

  /// The name of the block, or `nil` if it is unnamed.
  public var name: String? {
    guard let s = LLVMGetBasicBlockName(llvm.raw) else { return nil }
    let n = String(cString: s)
    if n.isEmpty { return nil }
    return n
  }
}

extension BasicBlock: CustomStringConvertible {
  /// A human-readable description of the block.
  public var description: String { name ?? "<unnamed>" }

}
