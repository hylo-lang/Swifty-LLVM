internal import llvmc

/// A floating-point type in LLVM IR.
public struct FloatingPointType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Creates an instance wrapping `llvm`.
  private init(_ llvm: LLVMTypeRef) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance with `t`, failing iff `t` isn't a floating point type.
  public init?(_ t: any IRType) {
    switch LLVMGetTypeKind(t.llvm.raw) {
    case LLVMHalfTypeKind, LLVMFloatTypeKind, LLVMDoubleTypeKind, LLVMFP128TypeKind:
      self.llvm = t.llvm
    default:
      return nil
    }
  }

  /// Returns the type `half` in `module`
  public static func half(in module: inout Module) -> Self.Identity {
    .init(module.types.demandId(for: .init(LLVMHalfTypeInContext(module.context))))
  }

  /// Returns the type `float` in `module`.
  public static func float(in module: inout Module) -> Self.Identity {
    .init(module.types.demandId(for: .init(LLVMFloatTypeInContext(module.context))))
  }

  /// Returns the type `double` in `module`
  public static func double(in module: inout Module) -> Self.Identity {
    .init(module.types.demandId(for: .init(LLVMDoubleTypeInContext(module.context))))
  }

  /// Returns the type `fp128` in `module`
  public static func fp128(in module: inout Module) -> Self.Identity {
    .init(module.types.demandId(for: .init(LLVMFP128TypeInContext(module.context))))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`.
  public func callAsFunction(_ v: Double, in module: inout Module) -> FloatingPointConstant.Identity {
    constant(v, in: &module)
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is `v`.
  public func constant(_ v: Double, in module: inout Module) -> FloatingPointConstant.Identity {
    .init(module.values.demandId(for: .init(LLVMConstReal(llvm.raw, v))))
  }

  /// Returns a constant whose LLVM IR type is `self` and whose value is parsed from `text`.
  ///
  /// Zero is returned if `text` is not a valid floating-point value.
  public func constant(parsing text: String, in module: inout Module) -> FloatingPointConstant.Identity {
    let handle = text.withCString({
      LLVMConstRealOfStringAndSize(llvm.raw, $0, UInt32(text.utf8.count))
    })
    return .init(module.values.demandId(for: .init(handle!)))
  }

  /// The zero value of this type.
  public func zero(in module: inout Module) -> FloatingPointConstant.Identity {
    .init(module.values.demandId(for: .init(LLVMConstNull(llvm.raw))))
  }

}
