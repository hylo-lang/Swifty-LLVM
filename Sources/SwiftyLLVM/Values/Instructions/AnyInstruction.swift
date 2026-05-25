internal import llvmc

/// An instruction in LLVM IR.
public struct AnyInstruction: IRInstruction, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

}

extension UnsafeReference<AnyInstruction> {

  /// Creates an instance with `value`, failing iff `value` isn't an instruction.
  public init?(_ value: AnyValue.UnsafeReference) {
    if let handle = LLVMIsAInstruction(value.llvm.raw) {
      self.init(handle)
    } else {
      return nil
    }
  }

}
