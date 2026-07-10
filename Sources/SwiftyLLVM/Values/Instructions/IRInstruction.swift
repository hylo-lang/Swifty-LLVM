/// An instruction in LLVM IR.
public protocol IRInstruction: IRValue {}

extension IRInstruction {

  /// The value operands of `self`.
  public var operands: Operands { .init(of: self) }

}
