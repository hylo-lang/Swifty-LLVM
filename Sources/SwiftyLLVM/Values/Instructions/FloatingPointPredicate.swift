internal import llvmc

/// The predicate of a floating point comparison.
///
/// - Note: Ordered means that neither operand is a QNAN while unordered means that either operand
///   may be a QNAN.
/// - See https://llvm.org/docs/LangRef.html#fcmp-instruction.
public enum FloatingPointPredicate: String, Hashable, Sendable, CaseIterable {

  /// No comparison; always false.
  case alwaysFalse = "false"

  /// No comparison; always true.
  case alwaysTrue = "true"

  /// Values are ordered and equal.
  case oeq

  /// Values are ordered and not equal.
  case one

  /// Values are ordered and LHS is greater than RHS.
  case ogt

  /// Values are ordered and LHS greater than or equal to RHS.
  case oge

  /// Values are ordered and LHS is less than RHS.
  case olt

  /// Values are ordered and LHS is less than or equal to RHS.
  case ole

  /// Values are ordered (no nans).
  case ord

  /// Values are unordered or equal.
  case ueq

  /// Values are unordered or not equal.
  case une

  /// Values are unordered or LHS is greater than RHS.
  case ugt

  /// Values are unordered or LHS is greater than or equal to RHS.
  case uge

  /// Values are unordered or LHS is less than RHS.
  case ult

  /// Values are unordered or LHS is less than or equal to RHS.
  case ule

  /// Values are unordered (either nans).
  case uno

  /// The LLVM identifier of the predicate.
  internal var llvm: LLVMRealPredicate {
    switch self {
    case .alwaysFalse:
      LLVMRealPredicateFalse
    case .alwaysTrue:
      LLVMRealPredicateTrue
    case .oeq:
      LLVMRealOEQ
    case .one:
      LLVMRealONE
    case .ogt:
      LLVMRealOGT
    case .oge:
      LLVMRealOGE
    case .olt:
      LLVMRealOLT
    case .ole:
      LLVMRealOLE
    case .ord:
      LLVMRealORD
    case .ueq:
      LLVMRealUEQ
    case .une:
      LLVMRealUNE
    case .ugt:
      LLVMRealUGT
    case .uge:
      LLVMRealUGE
    case .ult:
      LLVMRealULT
    case .ule:
      LLVMRealULE
    case .uno:
      LLVMRealUNO
    }
  }

}

extension FloatingPointPredicate: LosslessStringConvertible {

  /// Creates a predicate from its mnemonic.
  public init?(_ description: String) {
    self.init(rawValue: description)
  }

  /// The mnemonic of this predicate.
  public var description: String { self.rawValue }

}
