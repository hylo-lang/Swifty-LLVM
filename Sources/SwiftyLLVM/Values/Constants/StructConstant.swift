internal import llvmc

/// A constant struct in LLVM IR.
public struct StructConstant: IRValue, Hashable, Sendable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: ValueRef) {
    self.llvm = llvm
  }

  /// Creates a constant struct of `type` in `module` aggregating `elements`.
  ///
  /// - Requires: The type of `contents[i]` has the same type as the `i`-th element of `type`.
  public init<S: Sequence>(
    of type: StructType, aggregating elements: S, in module: inout Module
  ) where S.Element == any IRValue {
    var values = elements.map({ $0.llvm.raw as Optional })
    self.llvm = .init(LLVMConstNamedStruct(type.llvm.raw, &values, UInt32(values.count)))
  }

  /// Creates a constant struct in `module` aggregating `elements`, packing these elemnts them if
  /// `isPacked` is `true`.
  public init<S: Sequence>(
    aggregating elements: S, packed isPacked: Bool = false, in module: inout Module
  ) where S.Element == any IRValue {
    var values = elements.map({ $0.llvm.raw as Optional })
    self.llvm = .init(
      LLVMConstStructInContext(
        module.context, &values, UInt32(values.count), isPacked ? 1 : 0))
  }

  /// The number of elements in the struct.
  public var count: Int { Int(LLVMGetNumOperands(llvm.raw)) }

}

extension StructConstant: AggregateConstant {

  public typealias Index = Int

  public typealias Element = IRValue

}
