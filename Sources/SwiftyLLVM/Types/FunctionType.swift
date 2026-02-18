internal import llvmc

/// A function type in LLVM IR.
public struct FunctionType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns the ID of a function type with given `parameters` and `returnType` in `module`.
  ///
  /// The return type is `void` if `returnType` is passed `nil`.
  public static func create<each T: IRType>(
    from parameters: (repeat (each T).Identity),
    to returnType: AnyType.Identity? = nil,
    in module: inout Module
  ) -> Self.Identity {
    let r =
      returnType.map({ module.types[$0] as any IRType })
      ?? (module.types[VoidType.create(in: &module)] as any IRType)

    // Mapping variadic tuple to array:
    var handles: [LLVMTypeRef?] = []
    for param in repeat each parameters {
      handles.append(module.types[param.erased].llvm.raw)
    }

    let handle = handles.withUnsafeMutableBufferPointer { buffer in
      return TypeRef(LLVMFunctionType(r.llvm.raw, buffer.baseAddress, UInt32(buffer.count), 0))
    }
    return .init(module.types.demandId(for: handle))
  }

  /// Creates an instance with `t`, failing iff `t` isn't a function type.
  public init?(_ t: any IRType) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMFunctionTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
  }

  /// The return type of the function.
  public var returnType: any IRType { AnyType(LLVMGetReturnType(llvm.raw)) }

  /// The parameters of the function.
  public var parameters: [any IRType] {
    let n = LLVMCountParamTypes(llvm.raw)
    var handles: [LLVMTypeRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetParamTypes(llvm.raw, &handles)
    return handles.map({ AnyType($0!) as any IRType })
  }

  /// Whether the function accepts a variable number of arguments
  ///
  /// E.g. a function like `declare i1 @llvm.coro.suspend.retcon(...)`
  public var isVarArg: Bool {
    LLVMIsFunctionVarArg(llvm.raw) != 0
  }

}
