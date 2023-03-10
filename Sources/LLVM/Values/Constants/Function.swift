import llvmc

/// A function in LLVM IR.
public struct Function: Global, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// Creates an instance with `v`, failing iff `v` isn't a function.
  public init?(_ v: IRValue) {
    if let h = LLVMIsAFunction(v.llvm) {
      self.llvm = h
    } else {
      return nil
    }
  }

  /// The parameters of the function.
  public var parameters: Parameters { .init(of: self) }

  /// Returns `true` iff the IR in `self` is well formed.
  public func isWellFormed() -> Bool {
    LLVMVerifyFunction(llvm, LLVMReturnStatusAction) == 0
  }

}

extension Function {

  /// A collection containing the parameters of a LLVM IR function.
  public struct Parameters: Collection {

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
      Int(LLVMCountParams(parent.llvm))
    }

    public var startIndex: Int { 0 }

    public var endIndex: Int { count }

    public func index(after position: Int) -> Int {
      position + 1
    }

    public subscript(position: Int) -> Parameter {
      Parameter(LLVMGetParam(parent.llvm, UInt32(position)), position)
    }

  }

}
