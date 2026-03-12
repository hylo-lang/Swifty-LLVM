/// The settings necessary for code generation, including target information and compiler options.
internal import llvmc

public struct TargetMachine: ~Copyable {

  /// A handle to the LLVM object wrapped by this instance.
  internal let llvm: LLVMTargetMachineRef

  /// The data layout of the machine.
  public let layout: DataLayout

  /// The target associated with the machine.
  public let target: Target

  /// Creates an instance with `options` for the specified `triple`.
  public init(options: TargetMachineOptions = TargetMachineOptions(), triple: String) throws {
    let target = try Target(ofTriple: triple)
    self.init(target: target, options: options, triple: triple)
  }

  /// Creates an instance with `options` for the specified `triple`.
  /// 
  /// - Requires: `triple` corresponds to `target`.
  public init(target: Target, options: TargetMachineOptions = TargetMachineOptions(), triple: String) {
    precondition((try? Target(ofTriple: triple).llvm) == target.llvm, "The triple must correspond to the target.")

    self.llvm = options.withLLVMOptions { o in
      LLVMCreateTargetMachineWithOptions(target.llvm, triple, o)
    }
    self.target = target
    self.layout = .init(LLVMCreateTargetDataLayout(self.llvm))
  }

  public static func host(options: TargetMachineOptions = .init()) throws -> TargetMachine {
    return try TargetMachine(options: options, triple: Target.defaultTargetTriple)
  }

  deinit {
    LLVMDisposeTargetMachine(llvm)
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

}
extension TargetMachine {

  /// The target triple of this machine.
  public var description: String { triple }

}
