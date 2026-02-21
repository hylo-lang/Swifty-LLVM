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
  public var basicBlocks: [BasicBlock.Reference] {
    let n = LLVMCountBasicBlocks(llvm.raw)
    var handles: [LLVMBasicBlockRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetBasicBlocks(llvm.raw, &handles)
    return handles.map({ BasicBlock.Reference($0!) })
  }

  public var parameters: Function.Parameters { .init(of: self) }

  /// The the function's entry, if any.
  public var entry: BasicBlock.Reference? {
    guard LLVMCountBasicBlocks(llvm.raw) > 0 else { return nil }
    return BasicBlock.Reference(LLVMGetEntryBasicBlock(llvm.raw))
  }

  /// Creates an instance with `v`, failing iff `v` isn't a function.
  public init?(_ v: any IRValue) {
    if let h = LLVMIsAFunction(v.llvm.raw) {
      self.llvm = .init(h)
    } else {
      return nil
    }
  }

}

extension Function {

  /// The return value of a LLVM IR function.
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

  /// A collection containing the parameters of a LLVM IR function.
  public struct Parameters: BidirectionalCollection {

    public typealias Index = Int

    public typealias Element = Parameter.Reference

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

    public var startIndex: Int { 0 }

    public var endIndex: Int { count }

    public func index(after position: Int) -> Int {
      precondition(position < count, "index is out of bounds")
      return position + 1
    }

    public func index(before position: Int) -> Int {
      precondition(position > 0, "index is out of bounds")
      return position - 1
    }

    public subscript(position: Int) -> Parameter.Reference {
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
