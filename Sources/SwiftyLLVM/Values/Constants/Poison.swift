internal import llvmc

/// A poison value in LLVM IR.
public struct Poison: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates the poison value of `t`.
  public init(of t: IRType) {
    self.llvm = .init(LLVMGetPoison(t.llvm.raw))
  }

  /// Creates an intance with `v`, failing iff `v` is not a poison value.
  public init?(_ v: IRValue) {
    if let h = LLVMIsAPoisonValue(v.llvm.raw) {
      self.llvm = .init(h)
    } else {
      return nil
    }
  }

}
