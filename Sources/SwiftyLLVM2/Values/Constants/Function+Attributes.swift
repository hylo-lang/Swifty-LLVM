internal import llvmc

extension Function: AttributeHolder {

  /// An attribute on a function in LLVM IR.
  public typealias Attribute = SwiftyLLVM.Attribute<Function>

  /// The name of an attribute on a function in LLVM IR.
  public enum AttributeName: String, AttributeNameProtocol, Sendable {

    /// Indicates that the inliner should attempt to inline this function into callers whenever
    /// possible, ignoring any active inlining size threshold for this caller.
    case alwaysinline

    /// Indicates that this function is rarely called.
    case cold

    /// Indicates that this function is a hot spot of the program execution.
    case hot

    /// Indicates that the inliner should never inline this function in any situation.
    ///
    /// - Note: This attribute may not be used together with the `alwaysinline` attribute.
    case noinline

    /// Indicates that the function never returns normally.
    ///
    /// If the function ever does dynamically return, its run-time behavior is undefined. Annotated
    /// functions may still raise an exception, i.e., `nounwind` is not implied.
    case noreturn

    /// Indicates that the function does not call itself either directly or indirectly down any
    /// possible call path.
    ///
    /// If the function ever does recurse, its run-time behavior is undefined.
    case norecurse

    /// Indicates that the function never raises an exception.
    ///
    /// If the function does raise an exception, its run-time behavior is undefined. However,
    /// functions marked nounwind may still trap or generate asynchronous exceptions. Exception
    /// handling schemes that are recognized by LLVM to handle asynchronous exceptions, such as
    /// `SEH`, will still provide their implementation defined semantics.
    case nounwind

  }

  /// The attributes of the function.
  public var attributes: [Attribute] {
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    let n = LLVMGetAttributeCountAtIndex(llvm.raw, i)
    var handles: [LLVMAttributeRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetAttributesAtIndex(llvm.raw, i, &handles)
    return handles.map(Attribute.init(_:))
  }

}

extension Function.Return: AttributeHolder {

  /// An attribute on a function in LLVM IR.
  public typealias Attribute = SwiftyLLVM.Attribute<Parameter>

  /// The name of an attribute on a return value in LLVM IR.
  public typealias AttributeName = Parameter.AttributeName

  /// The attributes of the return value.
  public var attributes: [Attribute] {
    let n = LLVMGetAttributeCountAtIndex(parent.llvm.raw, 0)
    var handles: [LLVMAttributeRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetAttributesAtIndex(parent.llvm.raw, 0, &handles)
    return handles.map(Attribute.init(_:))
  }

}
