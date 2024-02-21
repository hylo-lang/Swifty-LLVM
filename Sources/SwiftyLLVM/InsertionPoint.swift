import llvmc

/// A cursor specifying where IR instructions should be inserted.
public struct InsertionPoint {

  /// A pointer the object wrapped by this instance.
  private let wrapped: ManagedPointer<LLVMBuilderRef>

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMBuilderRef) {
    self.wrapped = .init(llvm, dispose: LLVMDisposeBuilder(_:))
  }

  /// A handle to the LLVM object wrapped by this instance.
  internal var llvm: LLVMBuilderRef { wrapped.llvm }

}
