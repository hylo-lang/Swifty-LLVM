/// A temporary wrapper view around a native handle managed by LLVM, tracked by an `EntityStore`.
public protocol LLVMEntity: ~Copyable {
  /// The native handle being wrapped by the entity, e.g. a pointer.
  associatedtype Handle: Equatable

  /// Wraps a handle for temporary use as an instance of `Self`.
  init(temporarilyWrapping handle: Handle)
}

/// The identity of an LLVM entity.
public struct LLVMIdentity<T: LLVMEntity>: Hashable, Sendable {

  /// The type-erased value of this identity.
  public let raw: UInt

  /// Creates an identifying the same node as `erased`.
  public init(uncheckedFrom erased: UInt) {
    self.raw = erased
  }

}

extension LLVMEntity {
  public typealias Identity = LLVMIdentity<Self>
}

extension LLVMIdentity where T: IRValue {
  public var erased: AnyValue.Identity {
    AnyValue.Identity(uncheckedFrom: self.raw)
  }
}

extension LLVMIdentity where T: IRType {
  public var erased: AnyType.Identity {
    AnyType.Identity(uncheckedFrom: self.raw)
  }
}
