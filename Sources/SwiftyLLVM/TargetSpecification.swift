internal import llvmc

/// Errors thrown when constructing a `TargetSpecification` with invalid CPU or feature values.
public enum TargetSpecificationError: Error, CustomStringConvertible, Equatable {

  /// The CPU name is not recognised for the target architecture.
  case invalidCPU(String, triple: String)

  /// A feature is not recognised for the target architecture.
  case invalidFeature(String, triple: String)

  public var description: String {
    switch self {
    case .invalidCPU(let cpu, let triple):
      return "Unknown CPU '\(cpu)' for target '\(triple)'."
    case .invalidFeature(let feature, let triple):
      return "Unknown feature '\(feature)' for target '\(triple)'."
    }
  }

}

/// A validated combination of target triple, backend, CPU name, and feature string.
///
/// The set of valid CPU names and features depends on the architecture (determined
/// by the triple), so these three values form a validation group.
///
/// The initialiser validates the CPU and features against the target's processor
/// table and throws `TargetSpecError` if either is unrecognised.
public struct TargetSpecification: Equatable {

  /// The target triple.
  public let target: Target

  /// The LLVM CPU name that's valid for `target`. An empty string means the architecture's generic baseline.
  public let cpu: String

  /// The LLVM CPU feature string. An empty string means no additional features.
  public let features: String

  /// Creates an instance iff `cpu` and `features` are valid for `target`.
  ///
  /// - Throws: `TargetSpecificationError.invalidCPU` if `cpu` is not recognised,
  ///           `TargetSpecificationError.invalidFeature` if any feature is not recognised.
  public init(target: Target, cpu: String = "", features: String = "") throws {
    guard target.isCPUValid(cpu) else {
      throw TargetSpecificationError.invalidCPU(cpu, triple: target.triple)
    }
    if let invalid = target.firstInvalidFeature(in: features) {
      throw TargetSpecificationError.invalidFeature(invalid, triple: target.triple)
    }
    self.target = target
    self.cpu = cpu
    self.features = features
  }

  /// The host machine's native target, with generic CPU and features.
  public static func host() throws -> TargetSpecification {
    try .init(
      target: .host(),
      cpu: "",
      features: "")
  }

  /// The host machine's native target, with detected native CPU and features.
  public static func native() throws -> TargetSpecification {
    try .init(
      target: .host(),
      cpu: hostCPUName,
      features: hostCPUFeatures)
  }

  /// The name of the host machine's CPU (e.g. "skylake", "apple-m1").
  ///
  /// This is the CPU that LLVM detects for the machine running this process.
  /// Suitable for native compilation but not for cross-compilation or portable distributables.
  public static var hostCPUName: String {
    _ = Backend.initializeHost
    guard let s = LLVMGetHostCPUName() else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

  /// The feature string of the host machine's CPU (e.g. "+sse4.2,+avx2").
  ///
  /// This is the set of CPU features that LLVM detects for the machine running this process.
  /// Suitable for native compilation but not for cross-compilation or portable distributables.
  public static var hostCPUFeatures: String {
    _ = Backend.initializeHost
    guard let s = LLVMGetHostCPUFeatures() else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

}
