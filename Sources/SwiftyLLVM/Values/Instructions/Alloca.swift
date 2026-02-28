internal import llvmc

/// LLVM's `alloca` instruction.
public struct Alloca: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    llvm = handle
  }

  /// Inserts an `alloca` instruction of `type` at insertion point `p`.
  public static func insert<T: IRType>(
    _ type: T.UnsafeReference, at p: borrowing InsertionPoint, in module: inout Module
  )
    -> Alloca.UnsafeReference
  {
    return Alloca.UnsafeReference(LLVMBuildAlloca(p.llvm, type.raw, "")!)
  }

  /// The type of the value allocated by the instruction.
  public var allocatedType: AnyType.UnsafeReference { .init(LLVMGetAllocatedType(llvm.raw)) }

  /// The preferred alignment of the allocated memory.
  public var alignment: Int { Int(LLVMGetAlignment(llvm.raw)) }

}

extension UnsafeReference<Alloca> {
  /// Creates an instance with `s`, failing iff `s` isn't an `alloca`
  public init?(_ s: AnyValue.UnsafeReference) {
    if let h = LLVMIsAAllocaInst(s.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }
}
