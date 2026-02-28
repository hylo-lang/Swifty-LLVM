internal import llvmc

/// A constant aggregate (e.g., a constant array) in LLVM IR.
public protocol AggregateConstant: IRValue, BidirectionalCollection {

  /// The number of elements in this value.
  var count: Int { get }

}

extension AggregateConstant where Index == Int, Element == AnyValue.UnsafeReference {

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

  /// The aggregate element at `position`.
  public subscript(position: Int) -> AnyValue.UnsafeReference {
    precondition(position >= 0 && position < count, "index is out of bounds")
    return .init(LLVMGetAggregateElement(llvm.raw, UInt32(position)))
  }

}

