/// The settings necessary for code generation, including target information and compiler options.
internal import llvmc

public struct TargetMachine: ~Copyable {

  /// A handle to the LLVM object wrapped by this instance.
  internal let llvm: LLVMTargetMachineRef

  /// The data layout of the machine.
  public let layout: DataLayout

  /// The LLVM backend for this machine.
  public let backend: Backend

  /// Creates an instance for the given target specification and codegen options.
  public init(
    target: TargetSpecification,
    optimization: OptimizationLevel = .none,
    relocation: RelocationModel = .default,
    codeModel: CodeModel = .default
  ) {
    let o = LLVMCreateTargetMachineOptions()!
    defer { LLVMDisposeTargetMachineOptions(o) }

    LLVMTargetMachineOptionsSetCPU(o, target.cpu)
    LLVMTargetMachineOptionsSetFeatures(o, target.features)
    LLVMTargetMachineOptionsSetCodeGenOptLevel(o, optimization.llvm)
    LLVMTargetMachineOptionsSetRelocMode(o, relocation.llvm)
    LLVMTargetMachineOptionsSetCodeModel(o, codeModel.llvm)

    self.llvm = LLVMCreateTargetMachineWithOptions(target.target.backend.llvm, target.target.triple, o)
    self.backend = target.target.backend
    self.layout = .init(LLVMCreateTargetDataLayout(self.llvm))
  }

  /// Creates a machine targeting the host with default codegen settings.
  public static func host(
    optimization: OptimizationLevel = .none,
    relocation: RelocationModel = .default,
    codeModel: CodeModel = .default
  ) throws -> TargetMachine {
    .init(target: try .host(), optimization: optimization, relocation: relocation, codeModel: codeModel)
  }

  deinit {
    LLVMDisposeTargetMachine(llvm)
  }

  /// The triple string of the machine.
  public var triple: String {
    guard let s = LLVMGetTargetMachineTriple(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

  /// The CPU name of the machine.
  public var cpu: String {
    guard let s = LLVMGetTargetMachineCPU(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

  /// The feature string of the machine.
  public var features: String {
    guard let s = LLVMGetTargetMachineFeatureString(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

}
extension TargetMachine {

  /// The target triple string of this machine.
  public var description: String { triple }

}
