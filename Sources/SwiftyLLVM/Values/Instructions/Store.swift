internal import llvmc

/// LLVM's `store` instruction.
///
/// - See https://llvm.org/docs/LangRef.html#store-instruction.
public struct Store: IRInstruction {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

  /// Inserts a store instruction with the given alignment.
  public static func insert<V1: IRValue, V2: IRValue>(
    _ value: V1.UnsafeReference, to location: V2.UnsafeReference, alignedAt alignment: Int,
    at p: borrowing InsertionPoint,
    in module: inout Module
  ) -> Store.UnsafeReference {
    let r = LLVMBuildStore(p.llvm, value.raw, location.raw)!
    LLVMSetAlignment(r, UInt32(alignment))
    return .init(r)
  }

  /// The assumed alignment of the target memory.
  public var alignment: Int { Int(LLVMGetAlignment(llvm.raw)) }

}

extension UnsafeReference<Store> {

  /// Creates an instance with `s`, failing iff `s` isn't a `store`.
  public init?(_ s: AnyValue.UnsafeReference) {
    if let h = LLVMIsAStoreInst(s.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }

}
