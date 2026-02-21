internal import llvmc

/// A cursor specifying where IR instructions should be inserted.
public struct InsertionPoint: ~Copyable {
  /// A handle to the LLVM object wrapped by this instance.
  internal let llvm: LLVMBuilderRef

  /// Creates an instance taking ownership of `reference`.
  internal init(sinking reference: LLVMBuilderRef) {
    self.llvm = reference
  }

  deinit {
    LLVMDisposeBuilder(llvm)
  }
}
