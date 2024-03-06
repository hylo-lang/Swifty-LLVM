internal import llvmc

/// The level of optimization used during code generation.
public enum OptimitzationLevel: Hashable {

  /// No optimization (a.k.a. `O0`).
  case none

  /// Moderate optimization (a.k.a. `O1`).
  case less

  /// Full optimization  (a.k.a. `O2`).
  case `default`

  /// Full optimization with aggressive inlining and vectorization (a.k.a. `O3`).
  case aggressive

  /// The LLVM representation of this instance for code generation.
  internal var codegen: LLVMCodeGenOptLevel {
    switch self {
    case .none:
      return LLVMCodeGenLevelNone
    case .less:
      return LLVMCodeGenLevelLess
    case .default:
      return LLVMCodeGenLevelDefault
    case .aggressive:
      return LLVMCodeGenLevelAggressive
    }
  }

}
