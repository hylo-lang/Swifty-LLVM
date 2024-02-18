import llvmc

/// An pointer type in LLVM IR.
public struct PointerType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMTypeRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm` in `context`.
  private init(_ llvm: LLVMTypeRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

  /// Creates an instance with `t`, failing iff `t` isn't a pointer type.
  public init?(_ t: IRType) {
    if (t.inContext { LLVMGetTypeKind(t.llvm) == LLVMPointerTypeKind }) {
      self.llvm = t.llvm
      self.context = t.context
    } else {
      return nil
    }
  }

  /// Creates an opaque pointer type in address space `s` in `module`.
  public init(inAddressSpace s: AddressSpace = .default, in module: inout Module) {
    self = module.inContext {
      .init(LLVMPointerTypeInContext(module.context.raw, s.llvm), in: module.context)
    }
  }

  /// The address space of the pointer.
  public var addressSpace: AddressSpace { .init(LLVMGetPointerAddressSpace(llvm)) }

}
