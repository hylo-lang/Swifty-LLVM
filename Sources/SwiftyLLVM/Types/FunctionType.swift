internal import llvmc

/// A function type in LLVM IR.
public struct FunctionType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns a reference to a function type with given `parameters` and `returnType` in `module`.
  ///
  /// The return type is `void` if `returnType` is passed `nil`.
  public static func create(
    from parameters: [AnyType.UnsafeReference],
    to returnType: AnyType.UnsafeReference? = nil,
    in module: inout Module
  ) -> FunctionType.UnsafeReference {
    let r = returnType ?? module.void.erased

    var mutableParameters = parameters.map { Optional.some($0.raw) }

    return mutableParameters.withUnsafeMutableBufferPointer { f in
      return FunctionType.UnsafeReference(LLVMFunctionType(r.raw, f.baseAddress, UInt32(f.count), 0))
    }
  }

  /// The return type of the function.
  public var returnType: AnyType.UnsafeReference { .init(LLVMGetReturnType(llvm.raw)) }

  /// The parameters of the function.
  public var parameters: [AnyType.UnsafeReference] {
    let n = LLVMCountParamTypes(llvm.raw)
    var handles: [LLVMTypeRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetParamTypes(llvm.raw, &handles)
    return handles.map { AnyType.UnsafeReference($0!) }
  }

  /// Whether the function accepts a variable number of arguments.
  ///
  /// E.g. a function like `declare i1 @llvm.coro.suspend.retcon(...)`.
  public var isVarArg: Bool {
    LLVMIsFunctionVarArg(llvm.raw) != 0
  }

}

extension UnsafeReference<FunctionType> {
  /// Creates an instance with `t`, failing iff `t` isn't a function type.
  public init?(_ t: AnyType.UnsafeReference) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMFunctionTypeKind {
      self.init(t.llvm)
    } else {
      return nil
    }
  }
}
