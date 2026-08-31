internal import llvmc
internal import llvmshims

/// A function type in LLVM IR.
///
/// - See https://llvm.org/docs/LangRef.html#function-type.
public struct FunctionType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

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
  public var parameters: Parameters { .init(of: self) }

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

extension FunctionType {

  /// A collection containing the parameter types of a function type in LLVM IR.
  public struct Parameters: BidirectionalCollection {

    /// The collection index type.
    public typealias Index = Int

    /// The collection element type.
    public typealias Element = AnyType.UnsafeReference

    /// The function type containing the elements of the collection.
    private let parent: FunctionType

    /// Creates a collection containing the parameters of `t`.
    fileprivate init(of t: FunctionType) {
      self.parent = t
    }

    /// The number of parameters in the collection.
    public var count: Int {
      Int(LLVMCountParamTypes(parent.llvm.raw))
    }

    /// The position of the first element.
    public var startIndex: Int { 0 }

    /// The position one past the last element.
    public var endIndex: Int { count }

    /// Returns the index immediately after `position`.
    public func index(after position: Int) -> Int {
      precondition(position < count, "index is out of bounds")
      return position + 1
    }

    /// Returns the index immediately before `position`.
    public func index(before position: Int) -> Int {
      precondition(position > 0, "index is out of bounds")
      return position - 1
    }

    /// The parameter type at `position`.
    public subscript(position: Int) -> AnyType.UnsafeReference {
      precondition(position >= 0 && position < count, "index is out of bounds")
      return .init(SwiftyLLVMGetParamType(parent.llvm.raw, UInt32(position)))
    }

  }

}
