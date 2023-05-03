import llvmc

/// LLVM's `alloca` instruction.
public struct Alloca: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Creates an instance with `s`, failing iff `s` isn't an `alloca`
  public init?(_ s: IRValue) {
    if let h = LLVMIsAAllocaInst(s.llvm) {
      self.llvm = h
    } else {
      return nil
    }
  }

  /// The type of the value allocated by the instruction.
  public var allocatedType: IRType { AnyType(LLVMGetAllocatedType(llvm)) }

  /// The preferred alignment of the allocated memory.
  public var alignment: Int { Int(LLVMGetAlignment(llvm)) }

}
