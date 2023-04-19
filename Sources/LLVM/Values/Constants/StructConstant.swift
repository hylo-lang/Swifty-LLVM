import llvmc

/// A constant struct in LLVM IR.
public struct StructConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  /// The number of elements in the struct.
  public let count: Int

  /// Creates a constant struct of `type` in `module` aggregating `elements`.
  ///
  /// - Requires: The type of `contents[i]` has the same type as the `i`-th element of `type`.
  public init<S: Sequence>(
    of type: StructType, aggregating elements: S, in module: inout Module
  ) where S.Element == IRValue {
    var values = elements.map({ $0.llvm as Optional })
    self.llvm = LLVMConstNamedStruct(type.llvm, &values, UInt32(values.count))
    self.count = values.count
  }

  /// Creates a constant struct in `module` aggregating `elements`, packing these elemnts them if
  /// `isPacked` is `true`.
  public init<S: Sequence>(
    aggregating elements: S, packed isPacked: Bool = false, in module: inout Module
  ) where S.Element == IRValue {
    var values = elements.map({ $0.llvm as Optional })
    self.llvm = LLVMConstStructInContext(
      module.context, &values, UInt32(values.count), isPacked ? 1 : 0)
    self.count = values.count
  }

}

extension StructConstant: BidirectionalCollection {

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
