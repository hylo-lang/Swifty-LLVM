internal import llvmc

/// A constant struct in LLVM IR.
public struct StructConstant: Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// The number of elements in the struct.
  public let count: Int

  /// Creates a constant struct of `type` in `context` aggregating `elements`.
  ///
  /// - Requires: The type of `contents[i]` has the same type as the `i`-th element of `type`.
  public init<S: Sequence>(
    of type: StructType, aggregating elements: S, in context: inout Context
  ) where S.Element == IRValue {
    var values = elements.map({ $0.llvm.raw as Optional })
    self.llvm = .init(LLVMConstNamedStruct(type.llvm.raw, &values, UInt32(values.count)))
    self.count = values.count
  }

  /// Creates a constant struct in `context` aggregating `elements`, packing these elemnts them if
  /// `isPacked` is `true`.
  public init<S: Sequence>(
    aggregating elements: S, packed isPacked: Bool = false, in context: inout Context
  ) where S.Element == IRValue {
    var values = elements.map({ $0.llvm.raw as Optional })
    self.llvm = .init(LLVMConstStructInContext(
      context.llvm, &values, UInt32(values.count), isPacked ? 1 : 0))
    self.count = values.count
  }

}

extension StructConstant: AggregateConstant {

  public typealias Index = Int

  public typealias Element = IRValue

}
