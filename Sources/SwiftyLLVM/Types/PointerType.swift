internal import llvmc

/// An pointer type in LLVM IR.
public struct PointerType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  private init(_ llvm: LLVMTypeRef) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance wrapping `handle`.
  public init(wrappingTemporarily handle: TypeRef) {
    self.init(handle.raw)
  }

  /// Creates an instance with `t`, failing iff `t` isn't a pointer type.
  public init?(_ t: any IRType) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMPointerTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
  }

  /// Creates an opaque pointer type in address space `s` in `module`.
  public init(inAddressSpace s: AddressSpace = .default, in module: inout Module) {
    self.init(LLVMPointerTypeInContext(module.context, s.llvm))
  }

  /// The address space of the pointer.
  public var addressSpace: AddressSpace { .init(LLVMGetPointerAddressSpace(llvm.raw)) }

}
