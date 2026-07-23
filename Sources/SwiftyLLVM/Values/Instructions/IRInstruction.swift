internal import llvmc

/// An instruction in LLVM IR.
public protocol IRInstruction: IRValue {}

extension IRInstruction {

  /// The value operands of `self`.
  public var operands: Operands { .init(of: self) }

  /// The fast floating point operation flags used for allowing additional optimizations.
  /// 
  /// - Requires: `self` is a floating-point operation (fneg, fadd, fsub, fmul, fdiv, frem, fcmp, 
  ///   fptrunc, fpext), uitofp, sitofp, and phi, select, or call instructions that return a
  ///   floating-point type.
  /// 
  /// - Note: fast math flags don't apply to compile-time constants.
  /// - See: https://llvm.org/docs/LangRef.html#fast-math-flags
  public var fastMathFlags: FastMathFlags {
    if isConstant { 
      .init()
    } else {
      .init(rawValue: LLVMGetFastMathFlags(llvm.raw))
    }
  }

}
