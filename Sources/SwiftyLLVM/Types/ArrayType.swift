internal import llvmc

/// An array type in LLVM IR.
public struct ArrayType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance representing arrays of `count` `element`s in `context`.
  public init(_ count: Int, _ element: IRType, in context: inout Context) {
    precondition(LLVMGetTypeContext(element.llvm.raw) == context.llvm)
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
  
}
