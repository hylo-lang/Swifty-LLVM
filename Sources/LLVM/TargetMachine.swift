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
      target.llvm, target.triple, cpu, features, optimization.llvm, relocation.llvm, code.llvm)
    self.wrapped = .init(handle!, dispose: LLVMDisposeTargetMachine(_:))
  }

  /// A handle to the LLVM object wrapped by this instance.
  internal var llvm: LLVMTargetMachineRef { wrapped.llvm }

}

extension TargetMachine: CustomStringConvertible {

  public var description: String {
    let s = LLVMGetTargetMachineTriple(llvm)
    defer { LLVMDisposeMessage(s) }
    return s.map({ .init(cString: $0) }) ?? ""
  }

}
