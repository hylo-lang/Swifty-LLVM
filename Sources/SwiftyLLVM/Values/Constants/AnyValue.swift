internal import llvmc

/// A value in LLVM IR.
public struct AnyValue: IRValue, LLVMEntity {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance wrapping `handle`.
  public init(wrappingTemporarily handle: ValueRef) {
    self.init(handle.raw)
  }

}
