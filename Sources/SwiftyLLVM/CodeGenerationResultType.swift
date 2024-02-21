import llvmc

/// The kind of result produced by code generation.
public enum CodeGenerationResultType: Hashable {

  /// Assembly.
  case assembly

  /// An object file.
  case objectFile

  /// The LLVM representation of this instance.
  internal var llvm: LLVMCodeGenFileType {
    switch self {
    case .assembly:
      return LLVMAssemblyFile
    case .objectFile:
      return LLVMObjectFile
    }
  }

}
