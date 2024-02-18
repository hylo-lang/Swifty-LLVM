import llvmc

/// An undefined value in LLVM IR.
public struct Undefined: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  public let context: ContextHandle

  /// Creates an undefined value of type `t`.
  public init(of t: IRType) {
    self.context = t.context
    self.llvm = t.inContext { LLVMGetUndef(t.llvm) }
  }

  /// Creates an instance with `v`, failing iff `v` is not an undefined value.
  public init?(_ v: IRValue) {
    if let h = ( v.inContext { LLVMIsAUndefValue(v.llvm) } ) {
      self.llvm = h
      self.context = v.context
    } else {
      return nil
    }
  }

}
