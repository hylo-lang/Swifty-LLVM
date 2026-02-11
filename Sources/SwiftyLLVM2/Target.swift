internal import llvmc

/// The specification of a platform on which code runs.
///
/// `Target` objects wrap immortal references to immutable LLVM objects. 
/// The underlying object is released only when the process ends.
public struct Target: @unchecked Sendable {

  /// The triple of the target.
  ///
  /// A triple is a string  taking the form `<arch><sub>-<vendor>-<sys>-<abi>` where:
  /// * `arch` = `x86_64`, `i386`, `arm`, `thumb`, `mips`, etc.
  /// * `sub` = `v5`, `v6m`, `v7a`, `v7m`, etc.
  /// * `vendor` = `pc`, `apple`, `nvidia`, `ibm`, etc.
  /// * `sys` = `none`, `linux`, `win32`, `darwin`, `cuda`, etc.
  /// * `env` = `eabi`, `gnu`, `android`, `macho`, `elf`, etc.
  ///
  /// For example, `arm64-apple-darwin22.3.0`.
  ///
  /// - SeeAlso: https://clang.llvm.org/docs/CrossCompilation.html.
  public let triple: String

  /// A handle to the immortal LLVM object wrapped by this instance.
  internal let immortalReference: LLVMTargetRef

  /// Creates an instance wrapping `llvm`, which represents the target associated with `triple`.
  private init(wrappingImmortal targetReference: LLVMTargetRef, for triple: String) {
    self.triple = triple
    self.immortalReference = targetReference
  }

  /// Creates an instance from a triple.
  public init(triple: String) throws {
    var handle: LLVMTargetRef? = nil
    var error: UnsafeMutablePointer<CChar>? = nil
    let success = LLVMGetTargetFromTriple(triple, &handle, &error)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw LLVMError(.init(cString: e))
    }
    guard success == 0 else {
      throw LLVMError("Unknown during LLVMGetTargetFromTriple")
    }

    self.init(wrappingImmortal: handle!, for: triple)
  }

  /// Creates an instance representing the target associated with `machine`.
  public init(of machine: TargetMachine) {
    let h = LLVMGetTargetMachineTarget(machine.llvm)
    self.init(wrappingImmortal: h!, for: machine.triple)
  }

  public init(of module: Module) {
    let h = LLVMGetTarget(module.moduleReference)
    self.init(wrappingImmortal: h!, for: module.target.triple)
  }

  /// The name of the target.
  public var name: String {
    guard let s = LLVMGetTargetName(immortalReference) else { return "" }
    return .init(cString: s)
  }

  /// `true` if the target has a JIT.
  public var hasJIT: Bool {
    LLVMTargetHasJIT(immortalReference) != 0
  }

  /// `true` if the target has an assembly back-end.
  public var hasAssemblyBackEnd: Bool {
    LLVMTargetHasAsmBackend(immortalReference) != 0
  }

  /// Returns the target representing the machine host.
  public static func host() throws -> Target {
    try initializeHost()

    let triple = LLVMGetDefaultTargetTriple()
    if let t = triple {
      defer { LLVMDisposeMessage(t) }
      return try .init(triple: .init(cString: t))
    } else {
      return try .init(triple: "")
    }
  }

  /// The initialization of the native target.
  private static func initializeHost() throws {
    guard LLVMInitializeNativeAsmParser() == 0 else {
      throw LLVMError("Failed to initialize native asm parser")
    }
    guard LLVMInitializeNativeAsmPrinter() == 0 else {
      throw LLVMError("Failed to initialize native asm printer")
    }
    guard LLVMInitializeNativeDisassembler() == 0 else {
      throw LLVMError("Failed to initialize native disassembler")
    }
    guard LLVMInitializeNativeTarget() == 0 else {
      throw LLVMError("Failed to initialize native target")
    }
  }

}

extension Target: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(immortalReference)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.immortalReference == rhs.immortalReference
  }

}

extension Target: CustomStringConvertible {

  public var description: String {
    .init(cString: LLVMGetTargetDescription(immortalReference))
  }

}
