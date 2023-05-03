import llvmc

/// An array type in LLVM IR.
public struct ArrayType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMTypeRef

  /// Creates an instance representing arrays of `count` `element`s in `module`.
  public init(_ count: Int, _ element: IRType, in module: inout Module) {
    precondition(LLVMGetTypeContext(element.llvm) == module.context)
    self.llvm = LLVMArrayType(element.llvm, UInt32(count))
  }

  /// Creates an instance with `t`, failing iff `t` isn't a void type.
  public init?(_ t: IRType) {
    if LLVMGetTypeKind(t.llvm) == LLVMArrayTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
  }

  /// The type of an element in instances of this type.
  public var element: IRType { AnyType(LLVMGetElementType(llvm)) }

  /// The number of elements in instances of this type.
  public var count: Int { Int(LLVMGetArrayLength(llvm)) }
  
}
