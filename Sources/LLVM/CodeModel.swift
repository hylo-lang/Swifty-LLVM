import llvmc

/// Constraints on address ranges that the program and its symbols may use.
public enum CodeModel: Hashable, Sendable {

  /// The model default to the target for which code is being generated.
  case `default`

  /// The model default to the target for JITed code.
  case jit

  /// Tiny code model.
  case tiny

  /// Small code model.
  case small

  /// Kernel code model.
  case kernel

  /// Medium code model.
  case medium

  /// Large code model.
  case large

  /// The LLVM representation of this instance.
  internal var llvm: LLVMCodeModel {
    switch self {
    case .default:
      return LLVMCodeModelDefault
    case .jit:
      return LLVMCodeModelJITDefault
    case .tiny:
      return LLVMCodeModelTiny
    case .small:
      return LLVMCodeModelSmall
    case .kernel:
      return LLVMCodeModelKernel
    case .medium:
      return LLVMCodeModelMedium
    case .large:
      return LLVMCodeModelLarge
    }
  }

}
