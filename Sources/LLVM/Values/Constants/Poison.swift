import llvmc

/// A poison value in LLVM IR.
public struct Poison: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  public let context: ContextHandle

  /// Creates the poison value of `t`.
  public init(of t: IRType) {
    self.llvm = t.inContext { LLVMGetPoison(t.llvm) }
    self.context = t.context
  }

  /// Creates an intance with `v`, failing iff `v` is not a poison value.
  public init?(_ v: IRValue) {
    if let h = (v.inContext { LLVMIsAPoisonValue(v.llvm) }) {
      self.llvm = h
      self.context = v.context
    } else {
      return nil
    }
  }

}
