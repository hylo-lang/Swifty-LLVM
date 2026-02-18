internal import llvmc

/// An integer type in LLVM IR.
public struct IntegerType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance with given `bitWidth` in `module`.
  ///
  /// - Requires: `bitWidth` is greater than 0.
  @available(*, deprecated, message: "Use create(_ bitWidth: _ in module:) instead.")
  public init(_ bitWidth: Int, in module: inout Module) {
    self.llvm = .init(LLVMIntTypeInContext(module.context, UInt32(bitWidth)))
  }

  /// Returns the ID of an integer type with given `bitWidth` in `module`.
  ///
  /// - Requires: `bitWidth` is greater than 0.
  public static func create(_ bitWidth: Int, in module: inout Module) -> Self.Identity {
    .init(
      module.types.demandId(for: .init(LLVMIntTypeInContext(module.context, UInt32(bitWidth)))))
  }

  /// Creates an instance with `t`, failing iff `t` isn't an integer type.
  public init?(_ t: any IRType) {
    guard LLVMGetTypeKind(t.llvm.raw) == LLVMIntegerTypeKind else { return nil }
    self.llvm = t.llvm
  }

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMTypeRef) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: TypeRef) {
    self.init(handle.raw)
  }

  /// The number of bits in the representation of the type's instances.
  public var bitWidth: Int { Int(LLVMGetIntTypeWidth(llvm.raw)) }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`, truncating or
  /// sign-extending if needed to fit `self.bitWidth`.
  ///
  /// - Requires: `v` must be representable in `self.`
  public func callAsFunction(_ v: Int) -> IntegerConstant {
    constant(v)
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`, registered in `module`.
  public func callAsFunction(_ v: Int, in module: inout Module) -> IntegerConstant.Identity {
    constant(v, in: &module)
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`, truncating or
  /// sign-extending if needed to fit `self.bitWidth`.
  @available(*, deprecated, message: "TODO migrate to returning id")
  public func constant<T: BinaryInteger>(_ v: T) -> SwiftyLLVM.IntegerConstant {
    .init(LLVMConstInt(llvm.raw, UInt64(truncatingIfNeeded: v), 0))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`, registered in `module`.
  public func constant<T: BinaryInteger>(_ v: T, in module: inout Module) -> IntegerConstant.Identity {
    .init(
      module.values.demandId(for: 
        ValueRef(LLVMConstInt(llvm.raw, UInt64(truncatingIfNeeded: v), 0))))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is parsed from `text` with
  /// given `radix`.
  ///
  /// Zero is returned if `text` is not a valid integer value.
  ///
  /// - Requires: `radix` must be in the range `2...36`.
  public func constant(parsing text: String, radix: Int = 10) -> IntegerConstant {
    let h = text.withCString { (s) in
      LLVMConstIntOfStringAndSize(llvm.raw, s, UInt32(text.utf8.count), UInt8(radix))!
    }
    return .init(h)
  }

  /// Returns a constant parsed from `text` and registered in `module`.
  public func constant(
    parsing text: String,
    radix: Int = 10,
    in module: inout Module
  ) -> IntegerConstant.Identity {
    let h = text.withCString { (s) in
      LLVMConstIntOfStringAndSize(llvm.raw, s, UInt32(text.utf8.count), UInt8(radix))!
    }
    return .init(module.values.demandId(for: ValueRef(h)))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value's binary presentation is
  /// `words`, from least to most significant.
  public func constant<Words: Collection<UInt64>>(words: Words) -> IntegerConstant {
    let w = Array(words)
    return .init(LLVMConstIntOfArbitraryPrecision(llvm.raw, UInt32(w.count), w))
  }

  /// Returns a constant with binary representation `words`, registered in `module`.
  public func constant<Words: Collection<UInt64>>(
    words: Words,
    in module: inout Module
  ) -> IntegerConstant.Identity {
    let w = Array(words)
    let handle = LLVMConstIntOfArbitraryPrecision(llvm.raw, UInt32(w.count), w)!
    return .init(module.values.demandId(for: ValueRef(handle)))
  }

  /// The zero value of this type.
  public var zero: IntegerConstant {
    .init(LLVMConstNull(llvm.raw))
  }

  /// The zero value of this type, registered in `module`.
  public func zero(in module: inout Module) -> IntegerConstant.Identity {
    .init(module.values.demandId(for: ValueRef(LLVMConstNull(llvm.raw))))
  }

}
