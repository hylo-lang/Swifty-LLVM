internal import llvmc
internal import llvmshims

/// A parameter in an LLVM IR function.
public struct Parameter: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: ValueRef) {
    self.llvm = llvm
  }

  /// Temporary wrapper of the function containing the parameter.
  public var parent: Function { .init(temporarilyWrapping: LLVMGetParamParent(llvm.raw)) }

  /// The index of the parameter in its function.
  public var index: Int {
    let i = SwiftyLLVMGetArgumentIndex(llvm.raw)
    assert(i != -1, "Invalid parameter index")
    return Int(i)
  }

}

extension Parameter: Hashable {

  /// Computes the hash based on the LLVM object reference.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(llvm)
  }

  /// Checks reference equality of two `Parameter` wrappers.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

}

extension UnsafeReference<Parameter> {
  /// Creates an instance with `v`, failing iff `v` is not a parameter.
  public init?(_ v: AnyValue.UnsafeReference) {
    if let h = LLVMIsAArgument(v.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }
}
