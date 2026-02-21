internal import llvmc

/// An array type in LLVM IR.
public struct ArrayType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Creates an instance with `t`, failing iff `t` isn't a void type.
  public init?(_ t: any IRType) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMArrayTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
  }

  public static func create(_ count: Int, _ element: Reference<some IRType>, in module: inout Module)
    -> ArrayType.Reference
  {
    precondition(LLVMGetTypeContext(element.llvm.raw) == module.context)
    return ArrayType.Reference(LLVMArrayType2(element.llvm.raw, UInt64(count)))
  }

  /// The type of an element in instances of this type.
  public var element: AnyType.Reference { .init(LLVMGetElementType(llvm.raw)) }

  /// The number of elements in instances of this type.
  public var count: Int { Int(LLVMGetArrayLength(llvm.raw)) }

  /// Returns a constant whose LLVM IR type is `self` and whose value is aggregating `elements`.
  public func constant<S: Sequence>(
    contentsOf elements: S, in module: inout Module
  ) -> ArrayConstant.Reference where S.Element == AnyValue.Reference {
    ArrayConstant.create(of: ArrayType.Reference(llvm), containing: elements, in: &module)
  }

}
