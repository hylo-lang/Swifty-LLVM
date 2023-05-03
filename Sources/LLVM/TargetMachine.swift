import llvmc

/// The settings necessary for code generation, including target information and compiler options.
public struct TargetMachine {

  /// A handle to the LLVM object wrapped by this instance.
  private let wrapped: ManagedPointer<LLVMTargetMachineRef>

  /// Creates an instance with given properties.
  ///
  /// - Parameters:
  ///   - target: The platform for which code is generated.
  ///   - cpu: The type of CPU to target. Defaults to the CPU of the host machine.
  ///   - features: The features a of the target.
  ///   - optimization: The level of optimization used during code generation. Defaults to `.none`.
  ///   - relocation: The relocation model used during code generation. Defaults to `.default`.
  ///   - code: The code model used during code generation. Defaults to `.default`.
  public init(
    for target: Target,
    cpu: String = "",
    features: String = "",
    optimization: OptimitzationLevel = .none,
    relocation: RelocationModel = .default,
    code: CodeModel = .default
  ) {
    let handle = LLVMCreateTargetMachine(
      target.llvm, target.triple, cpu, features, optimization.codegen, relocation.llvm, code.llvm)
    self.wrapped = .init(handle!, dispose: LLVMDisposeTargetMachine(_:))
  }

  /// The triple of the machine.
  public var triple: String {
    guard let s = LLVMGetTargetMachineTriple(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

  /// The CPU of the machine.
  public var cpu: String {
    guard let s = LLVMGetTargetMachineCPU(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

  /// The features of the machine.
  public var features: String {
    guard let s = LLVMGetTargetMachineFeatureString(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

  /// The target associated with the machine.
  public var target: Target {
    .init(of: self)
  }

  /// The data layout of the machine.
  public var layout: DataLayout {
    .init(of: self)
  }

  /// A handle to the LLVM object wrapped by this instance.
  internal var llvm: LLVMTargetMachineRef { wrapped.llvm }

}

extension TargetMachine: CustomStringConvertible {

  public var description: String { triple }

}
