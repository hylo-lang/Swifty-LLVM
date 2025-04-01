internal import llvmc

/// The type of an atomic read-modify-write binary operation.
public enum AtomicRMWBinOp: Sendable {

  /// Set the new value and return the one old.
  case xchg
  /// Add a value and return the old one.
  case add
  /// Subtract a value and return the old one.
  case sub
  /// And a value and return the old one.
  case and
  /// Not-And a value and return the old one.
  case nand
  /// OR a value and return the old one.
  case or
  /// Xor a value and return the old one.
  case xor
  /// Sets the value if it's greater than the original using a signed comparison and return the old one.
  case max
  /// Sets the value if it's Smaller than the original using a signed comparison and return the old one.
  case min
  /// Sets the value if it's greater than the original using an unsigned comparison and return the old one.
  case uMax
  /// Sets the value if it's greater than the  original using an unsigned comparison and return  the old one.
  case uMin
  /// Add a floating point value and return the  old one.
  case fAdd
  /// Subtract a floating point value and return the old one.
  case fSub
  /// Sets the value if it's greater than the original using an floating point comparison and return the old one.
  case fMax
  /// Sets the value if it's smaller than the original using an floating point comparison and return the old one.
  case fMin


  /// Creates an instance from its LLVM representation.
  internal init(llvm: LLVMAtomicRMWBinOp) {
    switch llvm {
    case LLVMAtomicRMWBinOpXchg:
      self = .xchg
    case LLVMAtomicRMWBinOpAdd:
      self = .add
    case LLVMAtomicRMWBinOpSub:
      self = .sub
    case LLVMAtomicRMWBinOpAnd:
      self = .and
    case LLVMAtomicRMWBinOpNand:
      self = .nand
    case LLVMAtomicRMWBinOpOr:
      self = .or
    case LLVMAtomicRMWBinOpXor:
      self = .xor
    case LLVMAtomicRMWBinOpMax:
      self = .max
    case LLVMAtomicRMWBinOpMin:
      self = .min
    case LLVMAtomicRMWBinOpUMax:
      self = .uMax
    case LLVMAtomicRMWBinOpUMin:
      self = .uMin
    case LLVMAtomicRMWBinOpFAdd:
      self = .fAdd
    case LLVMAtomicRMWBinOpFSub:
      self = .fSub
    case LLVMAtomicRMWBinOpFMax:
      self = .fMax
    case LLVMAtomicRMWBinOpFMin:
      self = .fMin
    default:
      fatalError("unsupported atomic RMW binary operation")
    }
  }

  /// The LLVM representation of this instance.
  internal var llvm: LLVMAtomicRMWBinOp {
    switch self {
    case .xchg:
      return LLVMAtomicRMWBinOpXchg
    case .add:
      return LLVMAtomicRMWBinOpAdd
    case .sub:
      return LLVMAtomicRMWBinOpSub
    case .and:
      return LLVMAtomicRMWBinOpAnd
    case .nand:
      return LLVMAtomicRMWBinOpNand
    case .or:
      return LLVMAtomicRMWBinOpOr
    case .xor:
      return LLVMAtomicRMWBinOpXor
    case .max:
      return LLVMAtomicRMWBinOpMax
    case .min:
      return LLVMAtomicRMWBinOpMin
    case .uMax:
      return LLVMAtomicRMWBinOpUMax
    case .uMin:
      return LLVMAtomicRMWBinOpUMin
    case .fAdd:
      return LLVMAtomicRMWBinOpFAdd
    case .fSub:
      return LLVMAtomicRMWBinOpFSub
    case .fMax:
      return LLVMAtomicRMWBinOpFMax
    case .fMin:
      return LLVMAtomicRMWBinOpFMin
    }
  }

}
