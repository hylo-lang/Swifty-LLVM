/// LLVM's backend descriptor, representing a target architecture family.
internal import llvmc

public struct Target {

  /// A handle to the LLVM object wrapped by this instance.
  internal let llvm: LLVMTargetRef

  /// Creates an instance wrapping `llvm`.
  private init(wrapping llvm: LLVMTargetRef) {
    self.llvm = llvm
  }

  /// Creates a wrapper for the target associated with `triple`.
  public init(ofTriple triple: String) throws {
    #if SWIFTY_LLVM_CROSS_COMPILATION_ENABLED
    _ = Target.initializeCrossCompilation
    #else
    _ = Target.initializeHost
    #endif
    
    var handle: LLVMTargetRef? = nil
    var error: UnsafeMutablePointer<CChar>? = nil
    LLVMGetTargetFromTriple(triple, &handle, &error)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw LLVMError(.init(cString: e))
    }

    self.init(wrapping: handle!)
  }

  /// Creates a wrapper for the target associated with `machine`.
  public init(of machine: borrowing TargetMachine) {
    llvm = LLVMGetTargetMachineTarget(machine.llvm)!
  }

  /// The name of the target.
  public var name: String {
    guard let s = LLVMGetTargetName(llvm) else { return "" }
    return .init(cString: s)
  }

  /// `true` if the target has a JIT.
  public var hasJIT: Bool {
    LLVMTargetHasJIT(llvm) != 0
  }

  /// `true` if the target has an assembly back-end.
  public var hasAssemblyBackEnd: Bool {
    LLVMTargetHasAsmBackend(llvm) != 0
  }

  public static var defaultTargetTriple: String {
    // Ensures LLVM targets are initialized.
    _ = initializeHost

    guard let s = LLVMGetDefaultTargetTriple() else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

  /// Returns the target representing the machine host.
  public static func host() throws -> Target {
    // Ensures LLVM targets are initialized.
    _ = initializeHost

    return try .init(ofTriple: defaultTargetTriple)
  }

  /// The initialization of the native target.
  private static let initializeHost: Void = {
    LLVMInitializeNativeAsmParser()
    LLVMInitializeNativeAsmPrinter()
    LLVMInitializeNativeDisassembler()
    LLVMInitializeNativeTarget()
  }()

  #if SWIFTY_LLVM_CROSS_COMPILATION_ENABLED
  /// The initialization of all targets for potential cross-compilation.
  /// 
  /// Set `SWIFTY_LLVM_CROSS_COMPILATION_ENABLED` to `true` using SPM
  /// `swift build `
  private static let initializeCrossCompilation: Void = {
    // Note: this could be more granular, but for now we have two types 
    // of LLVM distributables: one with only the native target, and one with all targets.
    LLVMInitializeAllTargetInfos()
    LLVMInitializeAllTargets()
    LLVMInitializeAllTargetMCs()
    LLVMInitializeAllAsmParsers()
    LLVMInitializeAllAsmPrinters()
  }()
  #endif

}
extension Target: Hashable {

  /// Hashes this instance by its underlying LLVM target handle.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(llvm)
  }

  /// Returns `true` iff `lhs` and `rhs` wrap the same LLVM target.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

}
extension Target: CustomStringConvertible {

  /// A textual description of the target from LLVM.
  public var description: String {
    guard let s = LLVMGetTargetDescription(llvm) else { return "" }
    return .init(cString: s)
  }

}
