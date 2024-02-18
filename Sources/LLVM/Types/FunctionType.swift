import llvmc

/// A function type in LLVM IR.
public struct FunctionType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMTypeRef

  public let context: ContextHandle

  /// Creates an instance with given `parameters` and `returnType` in `module`.
  ///
  /// The return type is `void` if `returnType` is passed `nil`.
  public init(from parameters: [IRType], to returnType: IRType? = nil, in module: inout Module) {
    self.context = module.context
    let r = returnType ?? VoidType(in: &module)
    self.llvm = module.inContext {
      parameters.withHandles { (p) in
        LLVMFunctionType(r.llvm, p.baseAddress, UInt32(p.count), 0)
      }
    }
  }

  /// Creates an instance with `t`, failing iff `t` isn't a function type.
  public init?(_ t: IRType) {
    if (t.inContext { LLVMGetTypeKind(t.llvm) }) == LLVMFunctionTypeKind {
      self.llvm = t.llvm
      self.context = t.context
    } else {
      return nil
    }
  }

  /// The return type of the function.
  public var returnType: IRType { AnyType(LLVMGetReturnType(llvm), in: context) }

  /// The parameters of the function.
  public var parameters: [IRType] {
    inContext {
      let n = LLVMCountParamTypes(llvm)
      var handles: [LLVMAttributeRef?] = .init(repeating: nil, count: Int(n))
      LLVMGetParamTypes(llvm, &handles)
      return handles.map({ AnyType($0!, in: context) as IRType })
    }
  }

}

