internal import llvmc

/// LLVM's `load` instruction.
///
/// - See https://llvm.org/docs/LangRef.html#load-instruction.
public struct Load: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

  /// Inserts a typed load instruction from `source`.
  public static func insert<T: IRType, V: IRValue>(
    _ type: T.UnsafeReference, from source: V.UnsafeReference, at p: borrowing InsertionPoint,
    in module: inout Module
  ) -> Load.UnsafeReference {
    .init(LLVMBuildLoad2(p.llvm, type.raw, source.raw, "")!)
  }

  /// The assumed alignment of the source memory.
  public var alignment: Int { Int(LLVMGetAlignment(llvm.raw)) }

}

extension UnsafeReference<Load> {

  /// Creates an instance with `s`, failing iff `s` isn't a `load`.
  public init?(_ s: AnyValue.UnsafeReference) {
    if let h = LLVMIsALoadInst(s.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }

}
