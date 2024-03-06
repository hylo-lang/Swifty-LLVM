internal import llvmc

/// An instruction in LLVM IR.
public struct Instruction: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = .init(llvm)
  }

}
