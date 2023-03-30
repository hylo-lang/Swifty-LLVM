import llvmc

/// The specification of a platform on which code runs.
public struct Target {

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

  /// Creates an instance wrapping `llvm`, which represents the target associated to `triple`.
  private init(triple: String, llvm: LLVMTargetRef) {
    self.triple = triple
    self.llvm = llvm
  }

  /// Returns the target representing the machine host.
  public static func host() throws -> Target {
    // Ensures LLVM targets are initialized.
    _ = initializeHost

    let triple = LLVMGetDefaultTargetTriple()
    var handle: LLVMTargetRef? = nil
    var error: UnsafeMutablePointer<CChar>? = nil
    LLVMGetTargetFromTriple(triple, &handle, &error)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw TargetError(description: .init(cString: e))
    }

    if let t = triple {
      defer { LLVMDisposeMessage(t) }
      return .init(triple: .init(cString: t), llvm: handle!)
    } else {
      return .init(triple: "", llvm: handle!)
    }
  }

  /// The initialization of the native target.
  private static let initializeHost: Void = {
    LLVMInitializeNativeTarget()
  }()

}
