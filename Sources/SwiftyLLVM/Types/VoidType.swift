internal import llvmc

/// A `void` type in LLVM IR.
public struct VoidType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(wrappingTemporarily llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Creates an instance in `module`.
  public init(in module: inout Module) {
    self.llvm = .init(LLVMVoidTypeInContext(module.context))
  }

  /// Creates an instance with `t`, failing iff `t` isn't a void type.
  public init?(_ t: any IRType) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMVoidTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
  }

}
