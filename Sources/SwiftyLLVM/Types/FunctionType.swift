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
    from parameters: [AnyType.Reference],
    to returnType: AnyType.Reference? = nil,
    in module: inout Module
  ) -> FunctionType.Reference {
    let r = returnType ?? module.void.erased

    var mutableParameters = parameters.map { Optional.some($0.raw) }

    return mutableParameters.withUnsafeMutableBufferPointer { f in
      return FunctionType.Reference(LLVMFunctionType(r.raw, f.baseAddress, UInt32(f.count), 0))
    }
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
  public var returnType: AnyType.Reference { .init(LLVMGetReturnType(llvm.raw)) }

  /// The parameters of the function.
  public var parameters: [AnyType.Reference] {
    let n = LLVMCountParamTypes(llvm.raw)
    var handles: [LLVMTypeRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetParamTypes(llvm.raw, &handles)
    return handles.map { AnyType.Reference($0!) }
  }

  /// Whether the function accepts a variable number of arguments
  ///
  /// E.g. a function like `declare i1 @llvm.coro.suspend.retcon(...)`
  public var isVarArg: Bool {
    LLVMIsFunctionVarArg(llvm.raw) != 0
  }

}
