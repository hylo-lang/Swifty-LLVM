internal import llvmc

/// A function in LLVM IR.
public struct Function: Global, Callable, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: ValueRef) {
    self.llvm = llvm
  }

  /// Returns `true` iff the IR in `self` is well formed.
  public func isWellFormed() -> Bool {
    LLVMVerifyFunction(llvm.raw, LLVMReturnStatusAction) == 0
  }

  /// The basic blocks of the function.
  public var basicBlocks: [BasicBlock.UnsafeReference] {
    let n = LLVMCountBasicBlocks(llvm.raw)
    var handles: [LLVMBasicBlockRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetBasicBlocks(llvm.raw, &handles)
    return handles.map({ BasicBlock.UnsafeReference($0!) })
  }

  /// The parameters of the function.
  public var parameters: Function.Parameters { .init(of: self) }

  /// The function's entry block, if any.
  public var entry: BasicBlock.UnsafeReference? {
    guard LLVMCountBasicBlocks(llvm.raw) > 0 else { return nil }
    return BasicBlock.UnsafeReference(LLVMGetEntryBasicBlock(llvm.raw))
  }

}

extension Function {

  /// The return value of an LLVM IR function.
  public struct Return: Hashable {

    /// The function defining the return value.
    public let parent: Function

    /// Creates an instance representing the return value of `parent`.
    fileprivate init(_ parent: some Callable) {
      self.parent = Function(temporarilyWrapping: parent.llvm)
    }

  }

}

extension Function {

  /// A collection containing the parameters of an LLVM IR function.
  public struct Parameters: BidirectionalCollection {

    /// The collection index type.
    public typealias Index = Int

    /// The collection element type.
    public typealias Element = Parameter.UnsafeReference

    /// The function containing the elements of the collection.
    private let parent: any Callable

    /// Creates a collection containing the parameters of `f`.
    fileprivate init(of f: any Callable) {
      self.parent = f
    }

    /// The number of parameters in the collection.
    public var count: Int {
      Int(LLVMCountParams(parent.llvm.raw))
    }

    /// The position of the first element.
    public var startIndex: Int { 0 }

    /// The position past the last element.
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

    /// The parameter at `position`.
    public subscript(position: Int) -> Parameter.UnsafeReference {
      precondition(position >= 0 && position < count, "index is out of bounds")
      return .init(LLVMGetParam(parent.llvm.raw, UInt32(position)))
    }

  }

}

extension Callable {
  /// The return value of the function.
  public var returnValue: Function.Return { .init(self) }

  /// The parameters of the function.
  public var parameters: Function.Parameters { .init(of: self) }
}

extension UnsafeReference<Function> {
  /// Creates an instance with `v`, failing iff `v` isn't a function.
  public init?(_ v: AnyValue.UnsafeReference) {
    if let h = LLVMIsAFunction(v.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }
}
