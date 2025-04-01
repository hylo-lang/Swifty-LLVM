internal import llvmc

/// A constant array in LLVM IR.
public struct ArrayConstant: Hashable, Sendable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// The number of elements in the array.
  public let count: Int

  /// Creates a constant array of `type` in `module`, filled with the contents of `elements`.
  ///
  /// - Requires: The type of each element in `contents` is `type`.
  public init<S: Sequence>(
    of type: IRType, containing elements: S, in module: inout Module
  ) where S.Element == IRValue {
    var values = elements.map({ $0.llvm.raw as Optional })
    self.llvm = .init(LLVMConstArray(type.llvm.raw, &values, UInt32(values.count)))
    self.count = values.count
  }

  /// Creates a constant array of `i8` in `module`, filled with the contents of `bytes`.
  public init<S: Sequence>(bytes: S, in module: inout Module) where S.Element == UInt8 {
    let i8 = IntegerType(8, in: &module)
    self.init(of: i8, containing: bytes.map({ i8.constant($0) }), in: &module)
  }

}

extension ArrayConstant: AggregateConstant {

  public typealias Index = Int

  public typealias Element = IRValue

}
