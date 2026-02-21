internal import llvmc

/// An instruction in LLVM IR.
public struct Instruction: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    llvm = handle
  }

}
