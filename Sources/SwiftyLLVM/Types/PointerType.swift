internal import llvmc

/// An pointer type in LLVM IR.
public struct PointerType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: TypeRef) {
    self.llvm = handle
  }

  /// Returns the ID of an opaque pointer type in address space `s` in `module`.
  public static func create(inAddressSpace s: AddressSpace = .default, in module: inout Module)
    -> PointerType.UnsafeReference
  {
    .init(LLVMPointerTypeInContext(module.context, s.llvm))
  }

  /// The address space of the pointer.
  public var addressSpace: AddressSpace { .init(LLVMGetPointerAddressSpace(llvm.raw)) }

}

extension UnsafeReference<PointerType> {
  /// Creates an instance with `t`, failing iff `t` isn't a pointer type.
  public init?(_ t: AnyType.UnsafeReference) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMPointerTypeKind {
      self.init(t.llvm)
    } else {
      return nil
    }
  }
}
