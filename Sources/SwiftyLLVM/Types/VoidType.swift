internal import llvmc

/// A `void` type in LLVM IR.
///
/// - See https://llvm.org/docs/LangRef.html#void-type.
public struct VoidType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns a reference to the `void` type in `context`.
  static func create(in context: ContextRef) -> VoidType.UnsafeReference {
    .init(LLVMVoidTypeInContext(context.raw))
  }

}

extension UnsafeReference<VoidType> {

  /// Creates an instance with `t`, failing iff `t` isn't a void type.
  public init?(_ t: AnyType.UnsafeReference) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMVoidTypeKind {
      self.init(t.llvm)
    } else {
      return nil
    }
  }

}
