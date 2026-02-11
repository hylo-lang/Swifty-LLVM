internal import llvmc

/// A function in LLVM IR.
public struct Function: Global, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  private let functionReference: ValueReference
  /// A handle to the LLVM object wrapped by this instance.
  public var llvm: ValueReference { functionReference }

  /// Creates an instance wrapping given LLVM function.
  internal init(_ f: LLVMValueRef) {
    self.functionReference = .init(f)
  }

  /// Creates an instance with `v`, failing iff `v` isn't a function.
  public init?(_ v: IRValue) {
    if let h = LLVMIsAFunction(v.llvm.raw) {
      self.functionReference = .init(h)
    } else {
      return nil
    }
  }

  /// The parameters of the function.
  public var parameters: Parameters { .init(of: self) }

  public func countBasicBlocks() -> Int {
    Int(LLVMCountBasicBlocks(functionReference.raw))
  }

  /// The the function's entry, if any.
  public var entry: BasicBlock? {
    guard countBasicBlocks() > 0 else { return nil }
    return .init(LLVMGetEntryBasicBlock(functionReference.raw))
  }

  /// Projects the basic blocks of the function.
  public var basicBlocks: [BasicBlock] {
    var handles: [LLVMBasicBlockRef?] = .init(repeating: nil, count: countBasicBlocks())
    LLVMGetBasicBlocks(functionReference.raw, &handles)

    return handles.map({ BasicBlock(wrappingTemporarily: $0!) })
  }

  /// Returns `true` iff the IR in `self` is well formed.
  public func isWellFormed() -> Bool {
    LLVMVerifyFunction(functionReference.raw, LLVMReturnStatusAction) == 0
  }
}

extension Function {

  /// The return value of a LLVM IR function.
  public struct Return: Hashable {

    /// The function defining the return value.
    public let parent: Function

    /// Creates an instance representing the return value of `parent`.
    fileprivate init(_ parent: Function) {
      self.parent = parent
    }

  }

  /// The return value of the function.
  public var returnValue: Return { .init(self) }

}

extension Function {

  /// A collection containing the parameters of a LLVM IR function.
  public struct Parameters: BidirectionalCollection {

    public typealias Index = Int

    public typealias Element = Parameter

    /// The function containing the elements of the collection.
    private let parent: Function

    /// Creates a collection containing the parameters of `f`.
    fileprivate init(of f: Function) {
      self.parent = f
    }

    /// The number of parameters in the collection.
    public var count: Int {
      Int(LLVMCountParams(parent.functionReference.raw))
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

    public subscript(position: Int) -> Parameter {
      precondition(position >= 0 && position < count, "index is out of bounds")
      return .init(
        wrappingTemporarily: LLVMGetParam(parent.functionReference.raw, UInt32(position)), position)
    }

  }

}
