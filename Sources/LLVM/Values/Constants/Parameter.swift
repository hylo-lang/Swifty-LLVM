import llvmc

/// A parameter in a LLVM IR function.
public struct Parameter: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  /// The index of the parameter in its function.
  public let index: Int

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm`, which represents the `i`-th parameter of a function.
  internal init(_ llvm: LLVMValueRef, _ i: Int, in context: ContextHandle) {
    self.context = context
    self.llvm = llvm
    self.index = i
  }

  /// Creates an intance with `v`, failing iff `v` is not a parameter.
  public init?(_ v: IRValue) {
    if let h = (v.inContext { LLVMIsAArgument(v.llvm) }) {
      self.llvm = h
      self.context = v.context
      self.index = Function(LLVMGetParamParent(h), in: v.context).parameters.firstIndex(where: { $0.llvm == h })!
    } else {
      return nil
    }
  }

  /// The function containing the parameter.
  public var parent: Function { inContext { .init(LLVMGetParamParent(llvm), in: context) } }

}

extension Parameter: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(llvm)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

}
