import llvmc

/// The type of a value in LLVM IR.
public protocol IRType: CustomStringConvertible, Contextual {

  /// A handle to the LLVM object wrapped by this instance.
  var llvm: LLVMTypeRef { get }

}

extension IRType {

  /// A string representation of the type.
  public var description: String {
    inContext {
      guard let s = LLVMPrintTypeToString(llvm) else { return "" }
      defer { LLVMDisposeMessage(s) }
      return String(cString: s)
    }
  }

  /// `true` if the size of the type is known.
  public var isSized: Bool {
    inContext { LLVMTypeIsSized(llvm) != 0 }
  }

  /// The `null` instance of this type (e.g., the zero of `i32`).
  public var null: IRValue {
    inContext { AnyValue(LLVMConstNull(llvm), in: context) }
  }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == <R: IRType>(lhs: Self, rhs: R) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == (lhs: IRType, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is equal to `rhs`.
  public static func == (lhs: Self, rhs: IRType) -> Bool {
    lhs.llvm == rhs.llvm
  }

  /// Returns `true` iff `lhs` is not equal to `rhs`.
  public static func != (lhs: IRType, rhs: Self) -> Bool {
    lhs.llvm != rhs.llvm
  }

  /// Returns `true` iff `lhs` is not equal to `rhs`.
  public static func != (lhs: Self, rhs: IRType) -> Bool {
    lhs.llvm != rhs.llvm
  }

}

/// Returns `true` iff `lhs` is equal to `rhs`.
public func == (lhs: IRType, rhs: IRType) -> Bool {
  lhs.llvm == rhs.llvm
}

/// Returns `true` iff `lhs` is not equal to `rhs`.
public func != (lhs: IRType, rhs: IRType) -> Bool {
  lhs.llvm != rhs.llvm
}

extension Array where Element == IRType {

  func withHandles<T>(_ action: (UnsafeMutableBufferPointer<LLVMTypeRef?>) -> T) -> T {
    let p = UnsafeMutablePointer<LLVMTypeRef?>.allocate(capacity: count)
    defer { p.deallocate() }
    for (i, t) in enumerated() {
      p.advanced(by: i).initialize(to: t.llvm)
    }
    return action(.init(start: p, count: count))
  }

}
