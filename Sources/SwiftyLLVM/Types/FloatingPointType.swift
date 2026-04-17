internal import llvmc

/// A floating-point type in LLVM IR.
public struct FloatingPointType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns the 16-bit floating-point type `half` in `module`.
  public static func half(in module: inout Module) -> FloatingPointType.UnsafeReference {
    half(in: .init(module.context))
  }

  /// Returns the 16-bit floating-point type `half` in `context`.
  static func half(in context: ContextRef) -> FloatingPointType.UnsafeReference {
    .init(LLVMHalfTypeInContext(context.raw))
  }

  /// Returns the 16-bit "brain" floating-point type `bfloat` in `module`.
  ///
  /// Represented as truncated IEEE 754 binary32, with 1 sign bit, 8 exponent bits and 7 fraction bits.
  public static func bfloat(in module: inout Module) -> FloatingPointType.UnsafeReference {
    bfloat(in: .init(module.context))
  }

  /// Returns the 16-bit "brain" floating-point type `bfloat` in `context`.
  ///
  /// Represented as truncated IEEE 754 binary32, with 1 sign bit, 8 exponent bits and 7 fraction bits.
  static func bfloat(in context: ContextRef) -> FloatingPointType.UnsafeReference {
    .init(LLVMBFloatTypeInContext(context.raw))
  }

  /// Returns the 32-bit floating-point type `float` in `module`.
  ///
  /// Represented as IEEE 754 binary32.
  public static func float(in module: inout Module) -> FloatingPointType.UnsafeReference {
    float(in: .init(module.context))
  }

  /// Returns the 32-bit floating-point type `float` in `context`.
  ///
  /// Represented as IEEE 754 binary32.
  static func float(in context: ContextRef) -> FloatingPointType.UnsafeReference {
    .init(LLVMFloatTypeInContext(context.raw))
  }

  /// Returns the 64-bit floating-point type `double` in `module`.
  ///
  /// Represented as IEEE 754 binary64.
  public static func double(in module: inout Module) -> FloatingPointType.UnsafeReference {
    double(in: .init(module.context))
  }

  /// Returns the 64-bit floating-point type `double` in `context`.
  ///
  /// Represented as IEEE 754 binary64.
  static func double(in context: ContextRef) -> FloatingPointType.UnsafeReference {
    .init(LLVMDoubleTypeInContext(context.raw))
  }

  /// Returns the 80-bit floating-point type `x86_fp80` in `module`.
  ///
  /// Represented as in X87.
  public static func x86_fp80(in module: inout Module) -> FloatingPointType.UnsafeReference {
    x86_fp80(in: .init(module.context))
  }

  /// Returns the 80-bit floating-point type `x86_fp80` in `context`.
  ///
  /// Represented as in X87.
  static func x86_fp80(in context: ContextRef) -> FloatingPointType.UnsafeReference {
    .init(LLVMX86FP80TypeInContext(context.raw))
  }

  /// Returns the 128-bit floating-point type `fp128` in `module`.
  ///
  /// Represented as IEEE 754 binary128.
  public static func fp128(in module: inout Module) -> FloatingPointType.UnsafeReference {
    fp128(in: .init(module.context))
  }

  /// Returns the 128-bit floating-point type `fp128` in `context`.
  ///
  /// Represented as IEEE 754 binary128.
  static func fp128(in context: ContextRef) -> FloatingPointType.UnsafeReference {
    .init(LLVMFP128TypeInContext(context.raw))
  }

  /// Returns the 128-bit floating-point type `ppc_fp128` in `module`.
  ///
  /// Represented as the PowerPC double-double format, with two 64-bit IEEE 754 binary64 parts.
  public static func ppc_fp128(in module: inout Module) -> FloatingPointType.UnsafeReference {
    ppc_fp128(in: .init(module.context))
  }

  /// Returns the 128-bit floating-point type `ppc_fp128` in `context`.
  ///
  /// Represented as the PowerPC double-double format, with two 64-bit IEEE 754 binary64 parts.
  static func ppc_fp128(in context: ContextRef) -> FloatingPointType.UnsafeReference {
    .init(LLVMPPCFP128TypeInContext(context.raw))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`.
  public func callAsFunction(_ v: Double)
    -> FloatingPointConstant.UnsafeReference
  {
    constant(v)
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`.
  public func constant(_ v: Double) -> FloatingPointConstant.UnsafeReference {
    .init(LLVMConstReal(llvm.raw, v))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is parsed from `text`.
  ///
  /// Zero is returned if `text` is not a valid floating-point value.
  public func constant(parsing text: String)
    -> FloatingPointConstant.UnsafeReference
  {
    text.withCString({
      .init(LLVMConstRealOfStringAndSize(llvm.raw, $0, UInt32(text.utf8.count))!)
    })
  }

  /// The zero value of this type.
  public var zero: FloatingPointConstant.UnsafeReference {
    .init(LLVMConstNull(llvm.raw))
  }

}
extension UnsafeReference<FloatingPointType> {

  /// Creates an instance with `t`, failing iff `t` isn't a floating point type.
  public init?(_ t: AnyType.UnsafeReference) {
    switch LLVMGetTypeKind(t.llvm.raw) {
    case LLVMHalfTypeKind, LLVMFloatTypeKind, LLVMDoubleTypeKind, LLVMFP128TypeKind,
      LLVMBFloatTypeKind, LLVMX86_FP80TypeKind, LLVMPPC_FP128TypeKind:
      self.init(t.llvm)
    default:
      return nil
    }
  }

}
