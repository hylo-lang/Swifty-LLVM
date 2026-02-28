internal import llvmc

/// A struct type in LLVM IR.
public struct StructType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns a reference to a struct type with given `fields` in `module`, packed iff `packed` is `true`.
  public static func create(
    _ fields: [AnyType.UnsafeReference],
    packed: Bool = false,
    in module: inout Module
  ) -> StructType.UnsafeReference {
    var f = fields.map({ Optional.some($0.raw) })
    return f.withUnsafeMutableBufferPointer { p in
      StructType.UnsafeReference(
        LLVMStructTypeInContext(
          module.context, p.baseAddress, UInt32(p.count), packed ? 1 : 0))
    }
  }

  /// Returns a reference to a struct with given `name` and `fields` in `module`, packed iff `packed` is `true`.
  public static func create(
    named name: String,
    _ fields: [AnyType.UnsafeReference],
    packed: Bool = false,
    in module: inout Module
  ) -> Self.UnsafeReference {
    let s = StructType.UnsafeReference(LLVMStructCreateNamed(module.context, name))
    var f = fields.map { Optional.some($0.raw) }
    f.withUnsafeMutableBufferPointer { (types) in
      LLVMStructSetBody(s.raw, types.baseAddress, UInt32(types.count), packed ? 1 : 0)
    }
    return s
  }

  /// The name of the struct.
  public var name: String? {
    guard let s = LLVMGetStructName(llvm.raw) else { return nil }
    return String(cString: s)
  }

  /// `true` iff the fields of the struct are packed.
  public var isPacked: Bool { LLVMIsPackedStruct(llvm.raw) != 0 }

  /// `true` iff the struct is opaque.
  public var isOpaque: Bool { LLVMIsOpaqueStruct(llvm.raw) != 0 }

  /// `true` iff the struct is literal.
  public var isLiteral: Bool { LLVMIsLiteralStruct(llvm.raw) != 0 }

  /// The fields of the struct.
  public var fields: Fields { .init(of: self) }

  /// Returns a constant whose LLVM IR type is `self` and whose value aggregates `elements`.
  public func constant<S: Sequence>(
    aggregating elements: S, in module: inout Module
  ) -> StructConstant.UnsafeReference where S.Element == AnyValue.UnsafeReference {
    StructConstant.create(aggregating: elements, in: &module)
  }

}

extension UnsafeReference<StructType> {
  /// Creates an instance with `t`, failing iff `t` isn't a struct type.
  public init?(_ t: AnyType.UnsafeReference) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMStructTypeKind {
      self.init(t.llvm)
    } else {
      return nil
    }
  }
}

extension StructType {

  /// A collection containing the fields of a struct type in LLVM IR.
  public struct Fields: BidirectionalCollection {

    /// The collection index type.
    public typealias Index = Int

    /// The collection element type.
    public typealias Element = AnyType.UnsafeReference

    /// The struct type containing the elements of the collection.
    private let parent: StructType

    /// Creates a collection containing the fields of `t`.
    fileprivate init(of t: StructType) {
      self.parent = t
    }

    /// The number of fields in the collection.
    public var count: Int {
      Int(LLVMCountStructElementTypes(parent.llvm.raw))
    }

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

    /// The field type at `position`.
    public subscript(position: Int) -> AnyType.UnsafeReference {
      precondition(position >= 0 && position < count, "index is out of bounds")
      return .init(LLVMStructGetTypeAtIndex(parent.llvm.raw, UInt32(position)))
    }

  }

}
