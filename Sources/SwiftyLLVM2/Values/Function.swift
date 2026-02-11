internal import llvmc
public struct Function: LLVMEntity {
  /// A handle to the LLVM object wrapped by this instance.
  internal let functionReference: ValueReference

  /// Creates an instance wrapping given LLVM function.
  internal init(wrappingTemporarily f: ValueReference) {
    self.functionReference = f
  }

  
}