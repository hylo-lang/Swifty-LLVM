internal import llvmc
internal import llvmshims

/// LLVM's backend descriptor, representing a target architecture family.
///
/// Instances are wrapping eternal immutable LLVM target objects, so they are safe to use
/// across multiple threads, and can be compared for equality by their handle.
public struct Backend {

  /// A handle to the LLVM object wrapped by this instance.
  internal let llvm: LLVMTargetRef

  /// Creates an instance wrapping `llvm`.
  private init(wrapping llvm: LLVMTargetRef) {
    self.llvm = llvm
  }

  /// Creates a wrapper for the target associated with `triple`.
  public init(ofTriple triple: String) throws {
    #if SWIFTY_LLVM_CROSS_COMPILATION_ENABLED
    _ = Backend.initializeCrossCompilation
    #else
    _ = Backend.initializeHost
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

  /// Returns the target representing the machine host.
  public static func host() throws -> Backend {
    // Ensures LLVM targets are initialized.
    _ = initializeHost

    return try .init(ofTriple: Target.hostTriple)
  }

  /// The initialization of the native target.
  internal static let initializeHost: Void = {
    LLVMInitializeNativeAsmParser()
    LLVMInitializeNativeAsmPrinter()
    LLVMInitializeNativeDisassembler()
    LLVMInitializeNativeTarget()
  }()

  #if SWIFTY_LLVM_CROSS_COMPILATION_ENABLED
  /// The initialization of all targets for potential cross-compilation.
  /// 
  /// Set `SWIFTY_LLVM_CROSS_COMPILATION_ENABLED` to `true` using SPM
  /// `swift build -Xswiftc -DSWIFTY_LLVM_CROSS_COMPILATION_ENABLED`
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

extension Backend: Hashable {

  /// Hashes this instance by its underlying LLVM target handle.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(llvm)
  }

  /// Returns `true` iff `lhs` and `rhs` wrap the same LLVM target.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

}

extension Backend: CustomStringConvertible {

  /// A textual description of the target from LLVM.
  public var description: String {
    guard let s = LLVMGetTargetDescription(llvm) else { return "" }
    return .init(cString: s)
  }

}
