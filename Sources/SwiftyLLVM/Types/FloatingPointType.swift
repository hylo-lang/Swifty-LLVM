internal import llvmc

/// A floating-point type in LLVM IR.
public struct FloatingPointType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns the type `half` in `module`
  public static func half(in module: inout Module) -> FloatingPointType.UnsafeReference {
    .init(LLVMHalfTypeInContext(module.context))
  }

  /// Returns the type `float` in `module`.
  public static func float(in module: inout Module) -> FloatingPointType.UnsafeReference {
    .init(LLVMFloatTypeInContext(module.context))
  }

  /// Returns the type `double` in `module`
  public static func double(in module: inout Module) -> FloatingPointType.UnsafeReference {
    .init(LLVMDoubleTypeInContext(module.context))
  }

  /// Returns the type `fp128` in `module`
  public static func fp128(in module: inout Module) -> FloatingPointType.UnsafeReference {
    .init(LLVMFP128TypeInContext(module.context))
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
    case LLVMHalfTypeKind, LLVMFloatTypeKind, LLVMDoubleTypeKind, LLVMFP128TypeKind:
      self.init(t.llvm)
    default:
      return nil
    }
  }
}
