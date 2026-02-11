internal import llvmc

/// A constant integer value in LLVM IR.
public struct IntegerConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueReference) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance with `v`, failing iff `v` isn't a constant integer value.
  public init?(_ v: IRValue) {
    if let h = LLVMIsAConstantInt(v.llvm.raw) {
      self.llvm = .init(h)
    } else {
      return nil
    }
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
