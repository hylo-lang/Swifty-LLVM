internal import llvmc

/// A constant floating-point number in LLVM IR.
public struct FloatingPointConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueReference

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: ValueReference) {
    self.llvm = llvm
  }
  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance with `v`, failing iff `v` isn't a constant floating-point number.
  public init?(_ v: IRValue) {
    if let h = LLVMIsAConstantFP(v.llvm.raw) {
      self.llvm = .init(h)
    } else {
      return nil
    }
  }

  /// A pair `(v, l)` where `v` is the value of this constant and `l` is `true` iff
  /// precision was lost in the conversion.
  public var value: (value: Double, lostPrecision: Bool) {
    var l: Int32 = 0
    let v = LLVMConstRealGetDouble(llvm.raw, &l)
    return (v, l != 0)
  }

}
