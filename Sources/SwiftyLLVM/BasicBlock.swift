internal import llvmc

/// A basic block in LLVM IR.
public struct BasicBlock: Hashable, LLVMEntity {
  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: BasicBlockRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: BasicBlockRef) {
    self.llvm = handle
  }

}

extension BasicBlock: CustomStringConvertible {

  public var description: String {
    guard let s = LLVMGetBasicBlockName(llvm.raw) else { return "" }
    return String(cString: s)
  }

}
