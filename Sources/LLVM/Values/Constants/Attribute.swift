import llvmc

/// An attribute on a function in LLVM IR.
public enum Attribute {

  /// A target-independent attribute.
  case targetIndependent(llvm: LLVMAttributeRef)

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMAttributeRef?) {
    if LLVMIsEnumAttribute(llvm) != 0 {
      self = .targetIndependent(llvm: llvm!)
    } else {
      fatalError()
    }
  }

}
