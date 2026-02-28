internal import llvmc

/// An undefined value in LLVM IR.
public struct Undefined: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: ValueRef) {
    self.llvm = llvm
  }

  /// Creates and registers an undefined value of type `t` in `module`.
  public static func create<T: IRType>(of t: T.Reference, in module: inout Module) -> Self.Reference {
    return .init(LLVMGetUndef(t.raw))
  }

}

extension Reference<Undefined> {
  /// Creates an instance with `v`, failing iff `v` is not an undefined value.
  public init?(_ v: AnyValue.Reference) {
    if let h = LLVMIsAUndefValue(v.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }
}
