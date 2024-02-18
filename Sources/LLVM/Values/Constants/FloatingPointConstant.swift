import llvmc
import llvmshims

/// A constant floating-point number in LLVM IR.
public struct FloatingPointConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm` in `context`.
  internal init(_ llvm: LLVMValueRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

  /// Creates an instance with `v`, failing iff `v` isn't a constant floating-point number.
  public init?(_ v: IRValue) {
    if let h = (v.inContext { LLVMIsAConstantFP(v.llvm) }) {
      self.llvm = h
      self.context = v.context
    } else {
      return nil
    }
  }

  /// A pair `(v, l)` where `v` is the value of this constant and `l` is `true` iff
  /// precision was lost in the conversion.
  public var value: (value: Double, lostPrecision: Bool) {
    inContext {
      var l: Int32 = 0
      let v = LLVMConstRealGetDouble(llvm, &l)
      return (v, l != 0)
    }
  }

}
