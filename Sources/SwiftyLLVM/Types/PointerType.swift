internal import llvmc

/// An pointer type in LLVM IR.
public struct PointerType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  private init(_ llvm: LLVMTypeRef) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance with `t`, failing iff `t` isn't a pointer type.
  public init?(_ t: IRType) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMPointerTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
  }

  /// Creates an opaque pointer type in address space `s` in `context`.
  public init(inAddressSpace s: AddressSpace = .default, in context: inout Context) {
    self.init(LLVMPointerTypeInContext(context.llvm, s.llvm))
  }

  /// The address space of the pointer.
  public var addressSpace: AddressSpace { .init(LLVMGetPointerAddressSpace(llvm.raw)) }

}
