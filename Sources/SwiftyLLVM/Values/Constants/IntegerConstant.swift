internal import llvmc

/// A constant integer value in LLVM IR.
public struct IntegerConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

  /// The sign extended value of this constant.
  public var sext: Int64 {
    LLVMConstIntGetSExtValue(llvm.raw)
  }

  /// The zero extended value of this constant.
  public var zext: UInt64 {
    LLVMConstIntGetZExtValue(llvm.raw)
  }

}

extension UnsafeReference<IntegerConstant> {
  /// Creates an instance with `v`, failing iff `v` isn't a constant integer value.
  public init?(_ v: AnyValue.UnsafeReference) {
    if let h = LLVMIsAConstantInt(v.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }
}
