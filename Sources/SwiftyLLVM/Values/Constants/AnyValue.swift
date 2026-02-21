internal import llvmc

/// A value in LLVM IR.
public struct AnyValue: IRValue, LLVMEntity {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

}
