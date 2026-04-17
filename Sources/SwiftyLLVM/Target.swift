internal import llvmc
internal import llvmshims

/// A target triple string paired with its resolved LLVM backend.
///
/// Construction validates that LLVM has a backend for the given triple string.
/// Instances are equal if they have the same normalized triple string.
public struct Target: Hashable {

  /// The normalized triple string (e.g. "x86_64-unknown-linux-gnu").
  public let triple: String

  /// The LLVM backend for this triple.
  public let backend: Backend

  /// Creates an instance iff LLVM has a backend for `triple`.
  public init(_ triple: String) throws {
    let n = Target.normalizeTriple(triple)
    self.triple = n
    self.backend = try Backend(ofTriple: n)
  }

  /// Returns the LLVM-normalized form of `triple`.
  ///
  /// Fills in omitted components so that equivalent triples
  /// (e.g. "x86_64-linux-gnu" and "x86_64-unknown-linux-gnu") produce the same string.
  public static func normalizeTriple(_ triple: String) -> String {
    let p = LLVMNormalizeTargetTriple(triple)!
    defer { LLVMDisposeMessage(p) }
    return String(cString: p)
  }

  /// The triple for the host machine.
  public static func host() throws -> Target {
    try .init(hostTriple)
  }

  /// The target triple string for the host machine.
  public static var hostTriple: String {
    // Ensure LLVM targets are initialized.
    _ = Backend.initializeHost

    guard let s = LLVMGetDefaultTargetTriple() else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

  /// Returns `true` iff `cpu` is a recognised CPU name for this triple,
  /// or is empty (meaning generic).
  public func isCPUValid(_ cpu: String) -> Bool {
    SwiftyLLVMIsCPUValid(backend.llvm, triple, cpu)
  }

  /// Returns the first unrecognised feature in `features` for this triple,
  /// or `nil` if all features are valid.
  ///
  /// An empty string always returns `nil`.
  /// The format is a comma-separated list of "+feature" or "-feature" entries.
  public func firstInvalidFeature(in features: String) -> String? {
    guard let p = SwiftyLLVMGetFirstInvalidFeature(backend.llvm, triple, features) else {
      return nil
    }
    defer { LLVMDisposeMessage(p) }
    return String(cString: p)
  }

  /// Hashes this instance by its normalized triple string.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(triple)
  }

  /// Returns `true` if the normalized triple strings are equal.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.triple == rhs.triple
  }

}
