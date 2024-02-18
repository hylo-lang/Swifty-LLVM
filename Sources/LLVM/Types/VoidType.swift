import llvmc

/// A `void` type in LLVM IR.
public struct VoidType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMTypeRef

  public let context: ContextHandle

  /// Creates an instance in `module`.
  public init(in module: inout Module) {
    self.context = module.context
    self.llvm = module.inContext { LLVMVoidTypeInContext(module.context.raw) }
  }

  /// Creates an instance with `t`, failing iff `t` isn't a void type.
  public init?(_ t: IRType) {
    if (t.inContext { LLVMGetTypeKind(t.llvm) == LLVMVoidTypeKind }) {
      self.llvm = t.llvm
      self.context = t.context
    } else {
      return nil
    }
  }

}
