internal import llvmc

/// A global value in LLVM IR.
public protocol Global: IRValue {}

extension Global {

  /// The LLVM IR "value type" of this global.
  ///
  /// This "value type" of a global differs from its formal type, which is always a pointer type.
  public var valueType: any IRType {
    AnyType(LLVMGlobalGetValueType(llvm.raw))
  }

  /// The linkage of this global.
  public var linkage: Linkage {
    .init(llvm: LLVMGetLinkage(llvm.raw))
  }

}
