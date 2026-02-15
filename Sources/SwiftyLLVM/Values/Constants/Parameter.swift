internal import llvmc
internal import llvmshims

/// A parameter in a LLVM IR function.
public struct Parameter: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance wrapping `llvm`.
  public init(wrappingTemporarily llvm: ValueRef) {
    self.llvm = llvm
  }

  /// Creates an intance with `v`, failing iff `v` is not a parameter.
  public init?(_ v: any IRValue) {
    if let h = LLVMIsAArgument(v.llvm.raw) {
      self.llvm = .init(h)
    } else {
      return nil
    }
  }

  /// The function containing the parameter.
  public var parent: Function { .init(LLVMGetParamParent(llvm.raw)) }

  /// The index of the parameter in its function.
  ///
  /// Complexity: may be O(#parameters), though it's typically low.
  public var index: Int {
    let i = SwiftyLLVMGetArgumentIndex(llvm.raw)
    assert(i != SWIFTY_LLVM_INVALID_ARGUMENT_INDEX, "Invalid parameter index")
    return Int(i)
  }

}

extension Parameter: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(llvm)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

}
