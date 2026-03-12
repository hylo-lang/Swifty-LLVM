internal import llvmc

/// Options for configuring a target machine.
public struct TargetMachineOptions {
  /// The CPU of the machine.
  public var cpu: String = ""

  /// The comma-separated features of the machine.
  public var features: String = ""

  /// The level of optimization used during code generation. Defaults to `.none`.
  public var optimization: OptimizationLevel = .none

  /// The relocation model used during code generation. Defaults to `.default`.
  public var relocation: RelocationModel = .default

  /// The code model used during code generation. Defaults to `.default`.
  public var code: CodeModel = .default

  /// Creates the target machine configuration options with given initial values.
  ///
  /// - Parameters:
  ///   - cpu: The type of CPU to target. Defaults to the CPU of the host machine.
  ///   - features: The feature string of the target.
  ///   - optimization: The level of optimization used during code generation. Defaults to `.none`.
  ///   - relocation: The relocation model used during code generation. Defaults to `.default`.
  ///   - codeModel: The code model used during code generation. Defaults to `.default`.
  public init(
    cpu: String = "", features: String = "", optimization: OptimizationLevel = .none,
    relocation: RelocationModel = .default, codeModel: CodeModel = .default
  ) {
    self.cpu = cpu
    self.features = features
    self.optimization = optimization
    self.relocation = relocation
    self.code = codeModel
  }

  /// Exposes a temporary LLVM instance of this configuration to `witness`.
  /// 
  /// - Safety: `witness` must not escape the LLVM handle passed to it.
  internal func withLLVMOptions<R>(_ witness: (LLVMTargetMachineOptionsRef) throws -> R) rethrows -> R {
    let llvmOptions = LLVMCreateTargetMachineOptions()!
    defer { LLVMDisposeTargetMachineOptions(llvmOptions) }

    LLVMTargetMachineOptionsSetCPU(llvmOptions, cpu)
    LLVMTargetMachineOptionsSetFeatures(llvmOptions, features)
    LLVMTargetMachineOptionsSetCodeGenOptLevel(llvmOptions, optimization.codegen)
    LLVMTargetMachineOptionsSetRelocMode(llvmOptions, relocation.llvm)
    LLVMTargetMachineOptionsSetCodeModel(llvmOptions, code.llvm)

    return try witness(llvmOptions)
  }
}


