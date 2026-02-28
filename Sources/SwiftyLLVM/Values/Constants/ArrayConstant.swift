internal import llvmc

/// A constant array in LLVM IR.
public struct ArrayConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: ValueRef) {
    self.llvm = llvm
  }

  /// Creates a constant array of `type` in `module`, filled with the contents of `elements`.
  ///
  /// - Requires: The type of each element in `elements` is `type`.
  public static func create<T: IRType, S: Sequence>(
    of type: T.UnsafeReference, containing elements: S, in module: inout Module
  ) -> ArrayConstant.UnsafeReference where S.Element == AnyValue.UnsafeReference {
    var values = elements.map({ Optional.some($0.raw) })
    return .init(LLVMConstArray(type.raw, &values, UInt32(values.count)))
  }

  public var count: Int {
    let type = LLVMTypeOf(self.llvm.raw)
    return Int(LLVMGetArrayLength(type))
  }

  /// Creates a constant array of `i8` in `module`, filled with the contents of `bytes`.
  public static func create<S: Sequence>(bytes: S, in module: inout Module)
    -> ArrayConstant.UnsafeReference where S.Element == UInt8
  {
    let i8 = module.i8
    let byteConstants = bytes.map({ i8.pointee.constant($0).erased })
    return ArrayConstant.create(of: i8, containing: byteConstants, in: &module)
  }

}

extension ArrayConstant: AggregateConstant {

  public typealias Index = Int

  public typealias Element = AnyValue.UnsafeReference

}
