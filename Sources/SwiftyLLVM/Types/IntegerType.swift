internal import llvmc

/// An integer type in LLVM IR.
public struct IntegerType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Returns the ID of an integer type with given `bitWidth` in `module`.
  ///
  /// - Requires: `bitWidth` is greater than 0.
  public static func create(_ bitWidth: Int, in module: inout Module) -> IntegerType.UnsafeReference {
    .init(LLVMIntTypeInContext(module.context, UInt32(bitWidth)))
  }

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: TypeRef) {
    self.llvm = handle
  }

  /// The number of bits in the representation of the type's instances.
  public var bitWidth: Int { Int(LLVMGetIntTypeWidth(llvm.raw)) }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`, truncating or
  /// sign-extending if needed to fit `self.bitWidth`.
  ///
  /// - Requires: `v` must be representable in `self.`
  public func callAsFunction(_ v: Int) -> IntegerConstant.UnsafeReference {
    constant(v)
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`, truncating or
  /// sign-extending if needed to fit `self.bitWidth`.
  public func constant<T: BinaryInteger>(_ v: T) -> IntegerConstant.UnsafeReference {
    .init(LLVMConstInt(llvm.raw, UInt64(truncatingIfNeeded: v), 0))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is parsed from `text` with
  /// given `radix`.
  ///
  /// Zero is returned if `text` is not a valid integer value.
  ///
  /// - Requires: `radix` must be in the range `2...36`.
  public func constant(
    parsing text: String,
    radix: Int = 10
  ) -> IntegerConstant.UnsafeReference {
    return text.withCString { (s) in
      .init(LLVMConstIntOfStringAndSize(llvm.raw, s, UInt32(text.utf8.count), UInt8(radix))!)
    }
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value's binary presentation is
  /// `words`, from least to most significant.
  public func constant<Words: Collection<UInt64>>(words: Words) -> IntegerConstant.UnsafeReference {
    let w = Array(words)
    return .init(LLVMConstIntOfArbitraryPrecision(llvm.raw, UInt32(w.count), w))
  }

  /// The zero value of this type.
  public var zero: IntegerConstant.UnsafeReference {
    .init(LLVMConstNull(llvm.raw))
  }
}

extension UnsafeReference<IntegerType> {
  /// Creates an instance with `t`, failing iff `t` isn't an integer type.
  public init?(_ t: AnyType.UnsafeReference) {
    guard LLVMGetTypeKind(t.llvm.raw) == LLVMIntegerTypeKind else { return nil }
    self.init(t.llvm)
  }
}
