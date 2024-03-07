internal import llvmc

/// The type of a value in LLVM IR.
public protocol IRType: CustomStringConvertible {

  /// A handle to the LLVM object wrapped by this instance.
  var llvm: TypeRef { get }

}

extension IRType {

  /// A string representation of the type.
  public var description: String {
    guard let s = LLVMPrintTypeToString(llvm.raw) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return String(cString: s)
  }

  /// `true` if the size of the type is known.
  public var isSized: Bool { LLVMTypeIsSized(llvm.raw) != 0 }

  /// The `null` instance of this type (e.g., the zero of `i32`).
  public var null: IRValue { AnyValue(LLVMConstNull(llvm.raw)) }

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
      p.advanced(by: i).initialize(to: t.llvm.raw)
    }
    return action(.init(start: p, count: count))
  }

}
