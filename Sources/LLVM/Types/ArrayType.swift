import llvmc

/// An array type in LLVM IR.
public struct ArrayType: IRType, Hashable, Contextual {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMTypeRef

  public let context: ContextHandle

  /// Creates an instance representing arrays of `count` `element`s in `module`.
  public init(_ count: Int, _ element: IRType, in module: inout Module) {
    context = module.context
    precondition(LLVMGetTypeContext(element.llvm) == context.raw)
    self.llvm = LLVMArrayType(element.llvm, UInt32(count))
  }

  /// Creates an instance with `t`, failing iff `t` isn't a void type.
  public init?(_ t: IRType) {
    if (t.inContext { LLVMGetTypeKind(t.llvm) }) == LLVMArrayTypeKind {
      self.llvm = t.llvm
      self.context = t.context
    } else {
      return nil
    }
  }

  /// The type of an element in instances of this type.
  public var element: IRType {
    inContext {
      AnyType(LLVMGetElementType(llvm), in: context)
    }
  }

  /// The number of elements in instances of this type.
  public var count: Int { inContext { Int(LLVMGetArrayLength(llvm)) } }

  /// Returns a constant whose LLVM IR type is `self` and whose value is aggregating `elements`.
  public func constant<S: Sequence>(
    contentsOf elements: S, in module: inout Module
  ) -> ArrayConstant where S.Element == IRValue {
    inContext {
      .init(of: self, containing: elements, in: &module)
    }
  }
  
}
