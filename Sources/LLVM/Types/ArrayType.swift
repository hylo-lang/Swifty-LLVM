internal import llvmc

/// An array type in LLVM IR.
public struct ArrayType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance representing arrays of `count` `element`s in `module`.
  public init(_ count: Int, _ element: IRType, in module: inout Module) {
    precondition(LLVMGetTypeContext(element.llvm.raw) == module.context)
    self.llvm = .init(LLVMArrayType(element.llvm.raw, UInt32(count)))
  }

  /// Creates an instance with `t`, failing iff `t` isn't a void type.
  public init?(_ t: IRType) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMArrayTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
  }

  /// The type of an element in instances of this type.
  public var element: IRType { AnyType(LLVMGetElementType(llvm.raw)) }

  /// The number of elements in instances of this type.
  public var count: Int { Int(LLVMGetArrayLength(llvm.raw)) }

  /// Returns a constant whose LLVM IR type is `self` and whose value is aggregating `elements`.
  public func constant<S: Sequence>(
    contentsOf elements: S, in module: inout Module
  ) -> ArrayConstant where S.Element == IRValue {
    .init(of: self, containing: elements, in: &module)
  }
  
}
