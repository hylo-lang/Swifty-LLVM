internal import llvmc

/// A struct type in LLVM IR.
public struct StructType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(temporarilyWrapping llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Returns the ID of a struct type with given `fields` in `module`, packed iff `packed` is `true`.
  public static func create(
    _ fields: [AnyType.Reference],
    packed: Bool = false,
    in module: inout Module
  ) -> StructType.Reference {
    var f = fields.map({ Optional.some($0.raw) })
    return f.withUnsafeMutableBufferPointer { p in
      StructType.Reference(
        LLVMStructTypeInContext(
          module.context, p.baseAddress, UInt32(p.count), packed ? 1 : 0))
    }
  }

  /// Returns the ID of a struct with given `name` and `fields` in `module`, packed iff `packed` is `true`.
  public static func create(
    named name: String,
    _ fields: [AnyType.Reference],
    packed: Bool = false,
    in module: inout Module
  ) -> Self.Reference {
    let s = StructType.Reference(LLVMStructCreateNamed(module.context, name))
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

  /// Returns a constant whose LLVM IR type is `self` and whose value is aggregating `parts`.
  public func constant<S: Sequence>(
    aggregating elements: S, in module: inout Module
  ) -> StructConstant.Reference where S.Element == AnyValue.Reference {
    StructConstant.create(aggregating: elements, in: &module)
  }

}

extension Reference<StructType> {
  /// Creates an instance with `t`, failing iff `t` isn't a struct type.
  public init?(_ t: AnyType.Reference) {
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

    public typealias Index = Int

    public typealias Element = AnyType.Reference

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

    public subscript(position: Int) -> AnyType.Reference {
      precondition(position >= 0 && position < count, "index is out of bounds")
      return .init(LLVMStructGetTypeAtIndex(parent.llvm.raw, UInt32(position)))
    }

  }

}
