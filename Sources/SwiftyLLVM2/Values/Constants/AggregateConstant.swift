internal import llvmc

/// A constant aggregate (e.g., a constant array) in LLVM IR.
public protocol AggregateConstant: IRValue, BidirectionalCollection {

  /// The number of elements in this value.
  var count: Int { get }

}

extension AggregateConstant where Index == Int, Element == IRValue {

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
    return AnyValue(LLVMGetAggregateElement(llvm.raw, UInt32(position)))
  }

}

