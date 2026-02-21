internal import llvmc

/// A constant struct in LLVM IR.
public struct StructConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: ValueRef) {
    self.llvm = llvm
  }

  /// Creates a constant struct of `type` in `module` aggregating `elements`.
  ///
  /// - Requires: The type of `contents[i]` has the same type as the `i`-th element of `type`.
  public static func create<S: Sequence>(
    of type: StructType.Reference, aggregating elements: S, in module: inout Module
  ) -> StructConstant.Reference where S.Element == AnyValue.Reference {
    var values = elements.map({ Optional.some($0.raw) })
    return .init(LLVMConstNamedStruct(type.llvm.raw, &values, UInt32(values.count)))
  }

  /// Creates a constant struct in `module` aggregating `elements`, packing them if
  /// `isPacked` is `true`.
  public static func create<S: Sequence>(
    aggregating elements: S, packed isPacked: Bool = false, in module: inout Module
  ) -> StructConstant.Reference where S.Element == AnyValue.Reference {
    var values = elements.map({ Optional.some($0.raw) })
    return .init(
      LLVMConstStructInContext(
        module.context, &values, UInt32(values.count), isPacked ? 1 : 0))
  }

  /// The number of elements in the struct.
  public var count: Int { Int(LLVMGetNumOperands(llvm.raw)) }

}

extension StructConstant: AggregateConstant {

  public typealias Index = Int

  public typealias Element = AnyValue.Reference

}
