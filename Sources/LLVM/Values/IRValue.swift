import llvmc

/// A value in LLVM IR.
public protocol IRValue: CustomStringConvertible {

  /// A handle to the LLVM object wrapped by this instance.
  var llvm: LLVMValueRef { get }

}

extension IRValue {

  /// A string representation of the type.
  public var description: String {
    guard let s = LLVMPrintValueToString(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return String(cString: s)
  }

  /// The LLVM IR type of this value.
  public var type: IRType { AnyType(LLVMTypeOf(llvm)) }

  /// The name of this value.
  public var name: String {
    get {
      String(from: llvm, readingWith: LLVMGetValueName2(_:_:)) ?? ""
    }
    set {
      newValue.withCString({ LLVMSetValueName2(llvm, $0, newValue.utf8.count) })
    }
  }

  /// `true` iff this value is the `null` instance of its type.
  public var isNull: Bool { LLVMIsNull(llvm) != 0 }

  /// `true` iff this value is constant.
  public var isConstant: Bool { LLVMIsConstant(llvm) != 0 }

  /// `true` iff this value is a terminator instruction.
  public var isTerminator: Bool { LLVMIsATerminatorInst(llvm) != nil }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == <R: IRValue>(lhs: Self, rhs: R) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == (lhs: IRValue, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == (lhs: Self, rhs: IRValue) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is not equal to `rhs`.
  public static func != (lhs: IRValue, rhs: Self) -> Bool {
    lhs.llvm != rhs.llvm
  }

  /// Returns `true` iff `lhs` is not equal to `rhs`.
  public static func != (lhs: Self, rhs: IRValue) -> Bool {
    lhs.llvm != rhs.llvm
  }

}

/// Returns `true` iff `lhs` is equal to `rhs`.
public func == (lhs: IRValue, rhs: IRValue) -> Bool {
  lhs.llvm == rhs.llvm
}

/// Returns `true` iff `lhs` is not equal to `rhs`.
public func != (lhs: IRValue, rhs: IRValue) -> Bool {
  lhs.llvm != rhs.llvm
}
