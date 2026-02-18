internal import llvmc

/// A global value in LLVM IR.
public protocol Global: IRValue {}

extension Global {

  /// The LLVM IR "value type" of this global.
  ///
  /// This "value type" of a global differs from its formal type, which is always a pointer type.
  public func valueType(in module: inout Module) -> AnyType.Identity {
    let handle = TypeRef(LLVMGlobalGetValueType(llvm.raw))
    return .init(module.types.demandId(for: handle))
  }

  /// The linkage of this global.
  public var linkage: Linkage {
    .init(llvm: LLVMGetLinkage(llvm.raw))
  }

}
