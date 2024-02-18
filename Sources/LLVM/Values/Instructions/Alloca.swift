import llvmc

/// LLVM's `alloca` instruction.
public struct Alloca: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm` in `context`.
  internal init(_ llvm: LLVMValueRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

  /// Creates an instance with `s`, failing iff `s` isn't an `alloca`
  public init?(_ s: IRValue) {
    if let h = (s.inContext { LLVMIsAAllocaInst(s.llvm) }) {
      self.llvm = h
      self.context = s.context
    } else {
      return nil
    }
  }

  /// The type of the value allocated by the instruction.
  public var allocatedType: IRType { inContext { AnyType(LLVMGetAllocatedType(llvm), in: context) } }

  /// The preferred alignment of the allocated memory.
  public var alignment: Int { inContext { Int(LLVMGetAlignment(llvm)) } }

}
