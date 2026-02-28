internal import llvmc

/// An array type in LLVM IR.
public struct ArrayType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns an array type of `count` elements of type `element`.
  ///
  /// - Requires: `element` is defined in the same LLVM context as `module`.
  public static func create(_ count: Int, _ element: UnsafeReference<some IRType>, in module: inout Module)
    -> ArrayType.UnsafeReference
  {
    precondition(LLVMGetTypeContext(element.llvm.raw) == module.context)
    return ArrayType.UnsafeReference(LLVMArrayType2(element.llvm.raw, UInt64(count)))
  }

  /// The type of an element in instances of this type.
  public var element: AnyType.UnsafeReference { .init(LLVMGetElementType(llvm.raw)) }

  /// The number of elements in instances of this type.
  public var count: Int { Int(LLVMGetArrayLength(llvm.raw)) }

  /// Returns a constant whose LLVM IR type is `self` and whose value aggregates `elements`.
  public func constant<S: Sequence>(
    contentsOf elements: S, in module: inout Module
  ) -> ArrayConstant.UnsafeReference where S.Element == AnyValue.UnsafeReference {
    ArrayConstant.create(of: ArrayType.UnsafeReference(llvm), containing: elements, in: &module)
  }

}

extension UnsafeReference<ArrayType> {
  /// Creates an instance with `t`, failing iff `t` isn't an array type.
  public init?(_ t: UnsafeReference<AnyType>) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMArrayTypeKind {
      self.init(t.llvm)
    } else {
      return nil
    }
  }
}