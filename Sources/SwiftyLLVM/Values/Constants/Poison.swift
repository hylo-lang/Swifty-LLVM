internal import llvmc

/// A poison value in LLVM IR.
public struct Poison: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

  /// Creates and registers the poison value of `t` in `module`.
  public static func create<T: IRType>(of t: T.Reference, in module: inout Module) -> Poison.Reference {
    .init(LLVMGetPoison(t.raw))
  }

  /// Creates an intance with `v`, failing iff `v` is not a poison value.
  public init?(_ v: any IRValue) {
    if let h = LLVMIsAPoisonValue(v.llvm.raw) {
      self.llvm = .init(h)
    } else {
      return nil
    }
  }

}
