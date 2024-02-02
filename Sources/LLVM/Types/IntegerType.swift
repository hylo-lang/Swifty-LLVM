import llvmc

/// An integer type in LLVM IR.
public struct IntegerType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMTypeRef

  /// Creates an instance with given `bitWidth` in `module`.
  ///
  /// - Requires: `bitWidth` is greater than 0.
  public init(_ bitWidth: Int, in module: inout Module) {
    self.llvm = LLVMIntTypeInContext(module.context, UInt32(bitWidth))
  }

  /// Creates an instance with `t`, failing iff `t` isn't an integer type.
  public init?(_ t: IRType) {
    guard LLVMGetTypeKind(t.llvm) == LLVMIntegerTypeKind else { return nil }
    self.llvm = t.llvm
  }

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMTypeRef) {
    self.llvm = llvm
  }

  /// The number of bits in the representation of the type's instances.
  public var bitWidth: Int { Int(LLVMGetIntTypeWidth(llvm)) }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`, truncating or
  /// sign-extending if needed to fit `self.bitWidth`.
  ///
  /// - Requires: `v` must be representable in `self.`
  public func callAsFunction(_ v: Int) -> IntegerConstant {
    constant(v)
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`, truncating or
  /// sign-extending if needed to fit `self.bitWidth`.
  public func constant<T: BinaryInteger>(_ v: T) -> SwiftyLLVM.IntegerConstant {
    .init(LLVMConstInt(llvm, UInt64(truncatingIfNeeded: v), 0))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is parsed from `text` with
  /// given `radix`.
  ///
  /// Zero is returned if `text` is not a valid integer value.
  ///
  /// - Requires: `radix` must be in the range `2...36`.
  public func constant(parsing text: String, radix: Int = 10) -> IntegerConstant {
    let h = text.withCString { (s) in
      LLVMConstIntOfStringAndSize(llvm, s, UInt32(text.utf8.count), UInt8(radix))!
    }
    return .init(h)
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value's binary presentation is
  /// `words`, from least to most significant.
  public func constant<Words: Collection<UInt64>>(words: Words) -> IntegerConstant {
    let w = Array(words)
    return .init(LLVMConstIntOfArbitraryPrecision(llvm, UInt32(w.count), w))
  }

  /// The zero value of this type.
  public var zero: IntegerConstant {
    .init(LLVMConstNull(llvm))
  }

}
