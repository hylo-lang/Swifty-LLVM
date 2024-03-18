internal import llvmc

/// A `void` type in LLVM IR.
public struct VoidType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance in `context`.
  public init(in context: inout Context) {
    self.llvm = .init(LLVMVoidTypeInContext(context.llvm))
  }

  /// Creates an instance with `t`, failing iff `t` isn't a void type.
  public init?(_ t: IRType) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMVoidTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
  }

}
