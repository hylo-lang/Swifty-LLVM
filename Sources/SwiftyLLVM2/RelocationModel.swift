internal import llvmc

/// The settings of position-independent code (PIC) during code generation.
public enum RelocationModel: Hashable, Sendable {

  /// The model default to the target for which code is being generated.
  case `default`

  /// Non-relocatable code, machine instructions may use absolute addressing modes.
  case `static`

  /// Fully relocatable position independent code; machine instructions need to use relative
  /// addressing modes.
  case PIC

  /// Dynamically relocatable code without full position independence.
  case dynamicNoPIC

  /// Read-only position independent code.
  case ROPI

  /// Read-write position independent code.
  case RWPI

  /// Read-Only and Read-Write Position Independent code.
  case ROPI_RWPI

  /// The LLVM representation of this instance.
  internal var llvm: LLVMRelocMode {
    switch self {
    case .default:
      return LLVMRelocDefault
    case .static:
      return LLVMRelocStatic
    case .PIC:
      return LLVMRelocPIC
    case .dynamicNoPIC:
      return LLVMRelocDynamicNoPic
    case .ROPI:
      return LLVMRelocROPI
    case .RWPI:
      return LLVMRelocRWPI
    case .ROPI_RWPI:
      return LLVMRelocROPI_RWPI
    }
  }

}
