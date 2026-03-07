internal import llvmc

/// A poison value in LLVM IR.
public struct Poison: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

  /// Creates the poison value of type `t` in `module`.
  public static func create<T: IRType>(of t: T.UnsafeReference, in module: inout Module) -> Poison.UnsafeReference {
    .init(LLVMGetPoison(t.raw))
  }

}

extension UnsafeReference<Poison> {
  /// Creates an instance with `v`, failing iff `v` is not a poison value.
  public init?(_ v: AnyValue.UnsafeReference) {
    if let h = LLVMIsAPoisonValue(v.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }
}
