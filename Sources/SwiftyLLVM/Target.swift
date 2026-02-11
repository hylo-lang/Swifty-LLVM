internal import llvmc

/// The specification of a platform on which code runs.
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

  /// A handle to the LLVM object wrapped by this instance.
  internal let llvm: LLVMTargetRef

  /// Creates an instance wrapping `llvm`, which represents the target associated with `triple`.
  private init(wrapping llvm: LLVMTargetRef, for triple: String) {
    self.triple = triple
    self.llvm = llvm
  }

  /// Creates an instance from a triple.
  public init(triple: String) throws {
    var handle: LLVMTargetRef? = nil
    var error: UnsafeMutablePointer<CChar>? = nil
    LLVMGetTargetFromTriple(triple, &handle, &error)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw LLVMError(.init(cString: e))
    }

    self.init(wrapping: handle!, for: triple)
  }

  /// Creates an instance representing the target associated with `machine`.
  public init(of machine: borrowing TargetMachine) {
    let h = LLVMGetTargetMachineTarget(machine.llvm)
    self.init(wrapping: h!, for: machine.triple)
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
  public static func host() throws -> Target {
    // Ensures LLVM targets are initialized.
    _ = initializeHost

    let triple = LLVMGetDefaultTargetTriple()
    if let t = triple {
      defer { LLVMDisposeMessage(t) }
      return try .init(triple: .init(cString: t))
    } else {
      return try .init(triple: "")
    }
  }

  /// The initialization of the native target.
  private static let initializeHost: Void = {
    LLVMInitializeNativeAsmParser()
    LLVMInitializeNativeAsmPrinter()
    LLVMInitializeNativeDisassembler()
    LLVMInitializeNativeTarget()
  }()

}

extension Target: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(llvm)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

}

extension Target: CustomStringConvertible {

  public var description: String {
    .init(cString: LLVMGetTargetDescription(llvm))
  }

}
