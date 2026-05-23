internal import llvmc
internal import llvmshims

/// The level of optimization used during code generation.
public enum OptimizationLevel: Hashable, Sendable {

  /// No optimization (a.k.a. `O0`).
  case none

  /// Moderate optimization (a.k.a. `O1`).
  case less

  /// Full optimization (a.k.a. `O2`).
  case `default`

  /// Full optimization with aggressive inlining and vectorization (a.k.a. `O3`).
  case aggressive

  /// The LLVM representation of this instance for code generation.
  internal var llvm: LLVMCodeGenOptLevel {
    switch self {
    case .none:
      LLVMCodeGenLevelNone
    case .less:
      LLVMCodeGenLevelLess
    case .default:
      LLVMCodeGenLevelDefault
    case .aggressive:
      LLVMCodeGenLevelAggressive
    }
  }

  /// The optimization level representation used by optimization passes exposed by the custom LLVM
  /// shims in SwiftyLLVM.
  internal var swiftyLLVMRepresentation: SwiftyLLVMPassOptimizationLevel {
    switch self {
    case .none:
      SwiftyLLVMPassOptimizationLevelO0
    case .less:
      SwiftyLLVMPassOptimizationLevelO1
    case .default:
      SwiftyLLVMPassOptimizationLevelO2
    case .aggressive:
      SwiftyLLVMPassOptimizationLevelO3
    }
  }

}
