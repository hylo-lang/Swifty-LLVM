import llvmc

/// A constant integer value in LLVM IR.
public struct IntegerConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm` in `context`.
  internal init(_ llvm: LLVMValueRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

  /// Creates an instance with `v`, failing iff `v` isn't a constant integer value.
  public init?(_ v: IRValue) {
    if let h = (v.inContext { LLVMIsAConstantInt(v.llvm) }) {
      self.llvm = h
      self.context = v.context
    } else {
      return nil
    }
  }

  /// The sign extended value of this constant.
  public var sext: Int64 {
    LLVMConstIntGetSExtValue(llvm)
  }

  /// The zero extended value of this constant.
  public var zext: UInt64 {
    LLVMConstIntGetZExtValue(llvm)
  }

}
