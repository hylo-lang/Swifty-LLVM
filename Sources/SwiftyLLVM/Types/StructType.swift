internal import llvmc

/// A struct type in LLVM IR.
public struct StructType: IRType, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: TypeRef

  /// Creates an instance wrapping `llvm`.
  public init(wrappingTemporarily llvm: TypeRef) {
    self.llvm = llvm
  }

  /// Creates an instance with given `fields` in `module`, packed iff `packed` is `true`.
  @available(*, deprecated, message: "Use create(_:packed:in:) instead.")
  public init(_ fields: [any IRType], packed: Bool = false, in module: inout Module) {
    self.llvm = fields.withHandles { (f) in
      .init(LLVMStructTypeInContext(module.context, f.baseAddress, UInt32(f.count), packed ? 1 : 0))
    }
  }

  /// Returns the ID of a struct type with given `fields` in `module`, packed iff `packed` is `true`.
  public static func create(
    _ fields: [AnyType.ID],
    packed: Bool = false,
    in module: inout Module
  ) -> Self.ID {
    let f = fields.map({ module.types[$0] as any IRType })
    let handle = f.withHandles { (types) in
      TypeRef(
        LLVMStructTypeInContext(
          module.context, types.baseAddress, UInt32(types.count), packed ? 1 : 0))
    }
    return .init(module.types.insertIfAbsent(handle))
  }

  /// Creates a struct with given `name` and `fields` in `module`, packed iff `packed` is `true`.
  ///
  /// A unique name is generated if `name` is empty or if `module` already contains a struct with
  /// the same name.
  public init(
    named name: String, _ fields: [any IRType], packed: Bool = false, in module: inout Module
  ) {
    self.llvm = .init(LLVMStructCreateNamed(module.context, name))
    fields.withHandles { (f) in
      LLVMStructSetBody(self.llvm.raw, f.baseAddress, UInt32(f.count), packed ? 1 : 0)
    }
  }

  /// Returns the ID of a struct with given `name` and `fields` in `module`, packed iff `packed` is `true`.
  public static func create(
    named name: String,
    _ fields: [AnyType.ID],
    packed: Bool = false,
    in module: inout Module
  ) -> Self.ID {
    let handle = TypeRef(LLVMStructCreateNamed(module.context, name))
    let f = fields.map({ module.types[$0] as any IRType })
    f.withHandles { (types) in
      LLVMStructSetBody(handle.raw, types.baseAddress, UInt32(types.count), packed ? 1 : 0)
    }
    return .init(module.types.insertIfAbsent(handle))
  }

  /// Creates an instance with `t`, failing iff `t` isn't a struct type.
  public init?(_ t: any IRType) {
    if LLVMGetTypeKind(t.llvm.raw) == LLVMStructTypeKind {
      self.llvm = t.llvm
    } else {
      return nil
    }
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
  ) -> StructConstant where S.Element == any IRValue {
    .init(of: self, aggregating: elements, in: &module)
  }

}

extension StructType {

  /// A collection containing the fields of a struct type in LLVM IR.
  public struct Fields: BidirectionalCollection, Sendable {

    public typealias Index = Int

    public typealias Element = IRType

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

    public subscript(position: Int) -> any IRType {
      precondition(position >= 0 && position < count, "index is out of bounds")
      return AnyType(LLVMStructGetTypeAtIndex(parent.llvm.raw, UInt32(position)))
    }

  }

}
