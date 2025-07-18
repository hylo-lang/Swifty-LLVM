internal import llvmc

/// The predicate of an integer comparison.
public enum IntegerPredicate: String, Hashable, Sendable {

  /// Values are equal.
  case eq

  /// Values are not equal.
  case ne

  /// LHS is greater than RHS, by unsigned comparison.
  case ugt

  /// LHS is greater than or equal to RHS, by unsigned comparison.
  case uge

  /// LHS is less than RHS, by unsigned comparison.
  case ult

  /// LHS is less than or equal to RHS, by unsigned comparison.
  case ule

  /// LHS is less than RHS, by signed comparison.
  case slt

  /// LHS is greater than or equal to RHS, by signed comparison.
  case sge

  /// LHS is greater than RHS, by signed comparison.
  case sgt

  /// LHS is less than or equal to RHS, by signed comparison.
  case sle

  /// The LLVM identifier of the predicate.
  internal var llvm: LLVMIntPredicate {
    switch self {
    case .eq:
      return LLVMIntEQ
    case .ne:
      return LLVMIntNE
    case .ugt:
      return LLVMIntUGT
    case .uge:
      return LLVMIntUGE
    case .ult:
      return LLVMIntULT
    case .ule:
      return LLVMIntULE
    case .sgt:
      return LLVMIntSGT
    case .sge:
      return LLVMIntSGE
    case .slt:
      return LLVMIntSLT
    case .sle:
      return LLVMIntSLE
    }
  }

}

extension IntegerPredicate: LosslessStringConvertible {

  public init?(_ description: String) {
    self.init(rawValue: description)
  }

  public var description: String { self.rawValue }

}
