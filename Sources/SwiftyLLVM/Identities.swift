/// A temporary wrapper view around a native handle managed by LLVM, tracked by an `EntityStore`.
public protocol LLVMEntity: ~Copyable {
  /// The native handle being wrapped by the entity, e.g. a pointer.
  associatedtype Handle: Equatable

  /// Wraps a handle for temporary use as an instance of `Self`.
  init(wrappingTemporarily handle: Handle)
}


public struct LLVMIdentity<T: LLVMEntity> {

  /// The type-erased value of this identity.
  public let raw: UInt

  /// Creates an identifying the same node as `erased`.
  public init(uncheckedFrom erased: UInt) {
    self.raw = erased
  }

}

extension LLVMEntity {
  public typealias ID = LLVMIdentity<Self>
}

extension LLVMIdentity where T: IRValue {
  public var erased: AnyValue.ID {
    AnyValue.ID(uncheckedFrom: self.raw)
  }
}

extension LLVMIdentity where T: IRType {
  public var erased: AnyType.ID {
    AnyType.ID(uncheckedFrom: self.raw)
  }
}