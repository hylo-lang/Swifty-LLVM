import llvmc

/// A constant array in LLVM IR.
public struct ArrayConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  /// The number of elements in the array.
  public let count: Int

  /// Creates an constant array of `type` in `module`, filled with the contents of `elements`.
  ///
  /// - Requires: The type of each element in `contents` is `type`.
  public init<S: Sequence>(
    of type: IRType, containing contents: S, in module: inout Module
  ) where S.Element == IRValue {
    var values = contents.map({ $0.llvm as Optional })
    self.llvm = LLVMConstArray(type.llvm, &values, UInt32(values.count))
    self.count = values.count
  }

}

extension ArrayConstant: BidirectionalCollection {

  public typealias Index = Int

  public typealias Element = IRValue

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

  public subscript(position: Int) -> IRValue {
    precondition(position >= 0 && position < count, "index is out of bounds")
    return AnyValue(LLVMGetAggregateElement(llvm, UInt32(position)))
  }

}
