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
  public static func create(
    from parameters: [AnyType.Identity],
    to returnType: AnyType.Identity? = nil,
    in module: inout Module
  ) -> Self.Identity {
    let r = module.types[returnType ?? module.void.erased]

    let handle = parameters.map { module.types[$0] }
      .withHandles { f in
        return TypeRef(LLVMFunctionType(r.llvm.raw, f.baseAddress, UInt32(f.count), 0))
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
