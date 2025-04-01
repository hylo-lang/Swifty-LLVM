internal import llvmc

/// The settings of position-independent code (PIC) during code generation.
public enum RelocationModel: Hashable, Sendable {

  /// The model default to the target for which code is being generated.
  case `default`

  /// Non-relocatable code, machine instructions may use absolute addressing modes.
  case `static`

  /// Fully relocatable position independent code; machine instructions need to use relative
  /// addressing modes.
  case pic

  /// The LLVM representation of this instance.
  internal var llvm: LLVMRelocMode {
    switch self {
    case .default:
      return LLVMRelocDefault
    case .static:
      return LLVMRelocStatic
    case .pic:
      return LLVMRelocPIC
    }
  }

}
