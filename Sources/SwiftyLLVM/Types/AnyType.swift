internal import llvmc

/// The type of a value in LLVM IR.
internal struct AnyType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMTypeRef) {
    self.llvm = .init(llvm)
  }

}
