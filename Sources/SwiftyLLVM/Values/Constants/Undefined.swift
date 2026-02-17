internal import llvmc

/// An undefined value in LLVM IR.
public struct Undefined: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(wrappingTemporarily llvm: ValueRef) {
    self.llvm = llvm
  }

  /// Creates an undefined value of type `t`.
  @available(*, deprecated, message: "Use create(of:in:) instead.")
  public init(of t: any IRType) {
    self.llvm = .init(LLVMGetUndef(t.llvm.raw))
  }

  /// Creates and registers an undefined value of type `t` in `module`.
  public static func create(of t: some IRType, in module: inout Module) -> Self.ID {
    .init(module.values.insertIfAbsent(ValueRef(LLVMGetUndef(t.llvm.raw))))
  }

  /// Creates an instance with `v`, failing iff `v` is not an undefined value.
  public init?(_ v: any IRValue) {
    if let h = LLVMIsAUndefValue(v.llvm.raw) {
      self.llvm = .init(h)
    } else {
      return nil
    }
  }

}
