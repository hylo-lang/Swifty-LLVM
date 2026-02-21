internal import llvmc

/// A value in LLVM IR.
public protocol IRValue: CustomStringConvertible, LLVMEntity where Handle == ValueRef {

  /// A handle to the LLVM object wrapped by this instance.
  var llvm: ValueRef { get }

}

extension IRValue {
  public init(temporarilyWrapping r: Self.Reference) {
    self.init(temporarilyWrapping: r.raw)
  }

  init(temporarilyWrapping r: LLVMValueRef) {
    self.init(temporarilyWrapping: ValueRef(r))
  }

  /// A string representation of the value.
  public var description: String {
    guard let s = LLVMPrintValueToString(llvm.raw) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return String(cString: s)
  }

  /// The LLVM IR type of this value.
  public var type: AnyType.Reference { .init(LLVMTypeOf(llvm.raw)) }

  /// The name of this value.
  public var name: String { String(from: llvm.raw, readingWith: LLVMGetValueName2(_:_:)) ?? "" }

  /// `true` iff this value is the `null` instance of its type.
  public var isNull: Bool { LLVMIsNull(llvm.raw) != 0 }

  /// `true` iff this value is constant.
  public var isConstant: Bool { LLVMIsConstant(llvm.raw) != 0 }

  /// `true` iff this value is a terminator instruction.
  public var isTerminator: Bool { LLVMIsATerminatorInst(llvm.raw) != nil }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == <R: IRValue>(lhs: Self, rhs: R) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == (lhs: any IRValue, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == (lhs: Self, rhs: any IRValue) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is not equal to `rhs`.
  public static func != (lhs: any IRValue, rhs: Self) -> Bool {
    lhs.llvm != rhs.llvm
  }

  /// Returns `true` iff `lhs` is not equal to `rhs`.
  public static func != (lhs: Self, rhs: any IRValue) -> Bool {
    lhs.llvm != rhs.llvm
  }

}

/// Returns `true` iff `lhs` is equal to `rhs`.
public func == (lhs: any IRValue, rhs: any IRValue) -> Bool {
  lhs.llvm == rhs.llvm
}

/// Returns `true` iff `lhs` is not equal to `rhs`.
public func != (lhs: any IRValue, rhs: any IRValue) -> Bool {
  lhs.llvm != rhs.llvm
}
