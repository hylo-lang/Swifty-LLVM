internal import llvmc

/// A cursor specifying where IR instructions should be inserted.
public struct InsertionPoint : ~Copyable{

  /// A pointer the object wrapped by this instance.
  internal let llvm: LLVMBuilderRef

  /// Creates an instance wrapping `llvm`, taking ownership of it.
  internal init(consuming llvm: LLVMBuilderRef) {
    self.llvm = llvm
  }

  deinit {
    LLVMDisposeBuilder(llvm)
  }
}
