internal import llvmc

/// A function type in LLVM IR.
///
/// - See https://llvm.org/docs/LangRef.html#function-type.
public struct FunctionType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  private let parameterStorage = SharedMutable<[LLVMTypeRef?]?>(nil)

  public func hash(into hasher: inout Hasher) {
    llvm.hash(into: &hasher)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.llvm == rhs.llvm
  }

  public struct Parameters: RandomAccessCollection {
    private let llvmFunction: TypeRef
    private let lazyStorage: SharedMutable<[LLVMTypeRef?]?>

    internal init(llvmFunction: TypeRef, lazyStorage: SharedMutable<[LLVMTypeRef?]?>) {
      self.llvmFunction = llvmFunction
      self.lazyStorage = lazyStorage
    }

    public typealias Element = AnyType.UnsafeReference

    public var startIndex: Int { 0 }
    public var endIndex: Int {
      lazyStorage.read(
        applying: { $0.map(\.count) ?? Int(LLVMCountParamTypes(llvmFunction.raw)) } )
    }

    public subscript(position: Int) -> AnyType.UnsafeReference {
      lazyStorage.modify(
        applying: {
          let x = $0 ?? modify(
            &$0, {
              let n = LLVMCountParamTypes(llvmFunction.raw)
              var r: [LLVMTypeRef?] = .init(repeating: nil, count: Int(n))
              LLVMGetParamTypes(llvmFunction.raw, &r)
              $0 = r
              return r
            })
          return .init(x[position]!)
        })
    }
  }

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns a function type with `parameters` and `returnType` in `module`.
  ///
  /// The return type is `void` if `returnType` is `nil`.
  public static func create(
    from parameters: [AnyType.UnsafeReference],
    to returnType: AnyType.UnsafeReference? = nil,
    in module: inout Module
  ) -> FunctionType.UnsafeReference {
    let r = returnType ?? module.void.t

    var mutableParameters = parameters.map { Optional.some($0.raw) }

    return mutableParameters.withUnsafeMutableBufferPointer { f in
      FunctionType.UnsafeReference(LLVMFunctionType(r.raw, f.baseAddress, UInt32(f.count), 0))
    }
  }

  /// The return type of the function.
  public var returnType: AnyType.UnsafeReference { .init(LLVMGetReturnType(llvm.raw)) }

  /// The parameters of the function.
  ///
  /// Complexity: O(parameters.count)
  public var parameters: Parameters {
    return Parameters(llvmFunction: self.llvm, lazyStorage: parameterStorage)
  }

  /// `true` iff the function accepts a variable number of arguments.
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
