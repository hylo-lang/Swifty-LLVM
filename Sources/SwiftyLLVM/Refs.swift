internal import llvmc

/// An LLVM type reference.
public struct TypeRef: Hashable {

  /// The underlying LLVM value.
  internal let raw: llvmc.LLVMTypeRef

  /// An instance whose underlying value is `raw`.
  internal init(_ raw: llvmc.LLVMTypeRef) { self.raw = raw }

}

/// An LLVM value reference.
public struct ValueRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid re-exporting llvmc.
  internal let raw: llvmc.LLVMValueRef

  /// An instance whose underlying value is `raw`.
  internal init(_ raw: llvmc.LLVMValueRef) { self.raw = raw }

}

/// An LLVM basic block reference.
public struct BasicBlockRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid re-exporting llvmc.
  internal let raw: llvmc.LLVMBasicBlockRef

  /// An instance whose underlying value is `raw`.
  internal init(_ raw: llvmc.LLVMBasicBlockRef) { self.raw = raw }

}

/// An LLVM module reference.
public struct ModuleRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid re-exporting llvmc.
  internal let raw: llvmc.LLVMModuleRef

  /// An instance whose underlying value is `raw`.
  internal init(_ raw: llvmc.LLVMModuleRef) { self.raw = raw }

}

/// An LLVM context reference.
public struct ContextRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid re-exporting llvmc.
  internal let raw: llvmc.LLVMContextRef

  /// An instance whose underlying value is `raw`.
  internal init(_ raw: llvmc.LLVMContextRef) { self.raw = raw }

}

/// An LLVM attribute reference.
public struct AttributeRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid re-exporting llvmc.
  internal let raw: llvmc.LLVMAttributeRef

  /// An instance whose underlying value is `raw`.
  internal init(_ raw: llvmc.LLVMAttributeRef) { self.raw = raw }

}

/// A temporary wrapper view around a native handle managed by LLVM.
public protocol LLVMEntity: ~Copyable {

  /// The native handle being wrapped by the entity, e.g. a pointer.
  associatedtype Handle: Hashable

  /// Wraps a handle for temporary use as an instance of `Self`.
  init(temporarilyWrapping handle: Handle)

}

extension LLVMEntity {

  /// A reference to Self. Pointees are owned by the LLVM module.
  public typealias UnsafeReference = SwiftyLLVM.UnsafeReference<Self>

}

/// A non-owning reference to an LLVM-backed entity.
///
/// The lifetime of the pointee is managed by LLVM; Users must ensure the underlying object
/// remains valid while accessing the pointee.
public struct UnsafeReference<T: LLVMEntity>: Hashable {

  /// The underlying native handle for the referenced entity.
  internal let llvm: T.Handle

  /// Creates a reference from a raw entity handle.
  internal init(_ llvm: T.Handle) { self.llvm = llvm }

  /// A semantically transparent struct that allows exposing a named subscript `ref.unsafe[]`.
  public struct SubscriptablePointee {

    /// The wrapped handle.
    internal let llvm: T.Handle

    /// Wraps a raw handle for temporary use.
    internal init(_ llvm: T.Handle) { self.llvm = llvm }

    /// Dereferences the handle by wrapping it into its container type.
    ///
    /// Acts as the [] call operator, allowing us to write `ref.unsafe[]`.
    public subscript() -> T {
      _read { yield T(temporarilyWrapping: llvm) }
      _modify {
        var pointee = T(temporarilyWrapping: llvm)
        yield &pointee
      }
    }

  }

  /// Creates a temporary wrapper for the type.
  ///
  /// The caller must ensure that the wrapper doesn't become a dangling reference.
  public var unsafe: SubscriptablePointee {
    _read { yield .init(llvm) }
    _modify {
      var s = SubscriptablePointee(llvm)
      yield &s
    }
  }

}

/// Unchecked downcasting from erased reference.
extension UnsafeReference {

  /// Downcasts an AnyType to the desired IRType.
  ///
  /// - Requires: The reference points to an IRType of the desired type.
  public init(uncheckedFrom reference: UnsafeReference<AnyType>) where T: IRType {
    self.init(reference.llvm)
  }

  /// Downcasts an AnyValue to the desired IRValue.
  ///
  /// - Requires: The reference points to an IRValue of the desired type.
  public init(uncheckedFrom reference: UnsafeReference<AnyValue>) where T: IRValue {
    self.init(reference.llvm)
  }

  /// Downcasts an AnyAttribute to a function attribute.
  ///
  /// - Requires: The reference points to an IRAttribute of the desired type.
  public init(uncheckedFrom reference: UnsafeReference<AnyAttribute>) where T: IRAttribute {
    self.init(reference.llvm)
  }

}

/// Downcasting from native handle to the desired reference type.
extension UnsafeReference {

  /// Downcasts a native handle to the desired IRType reference.
  internal init(_ reference: LLVMTypeRef) where T: IRType {
    self.init(TypeRef(reference))
  }

  /// Downcasts a native handle to the desired IRValue reference.
  internal init(_ reference: LLVMValueRef) where T: IRValue {
    self.init(ValueRef(reference))
  }

  /// Downcasts a native handle to the desired IRAttribute reference.
  internal init(_ reference: LLVMAttributeRef) where T: IRAttribute {
    self.init(AttributeRef(reference))
  }

}

extension UnsafeReference<BasicBlock> {

  /// Creates a BasicBlock reference from a native handle.
  internal init(_ reference: LLVMBasicBlockRef) {
    self.init(BasicBlockRef(reference))
  }

}

extension UnsafeReference where T: IRType {

  /// Type-erased reference to the IR type.
  public var t: UnsafeReference<AnyType> { .init(llvm) }

  /// Native handle to the LLVM type reference.
  internal var raw: LLVMTypeRef { llvm.raw }

}

extension UnsafeReference where T: IRValue {

  /// Type-erased reference to the IR value.
  public var v: UnsafeReference<AnyValue> { .init(llvm) }

  /// Native handle to the LLVM value reference.
  internal var raw: LLVMValueRef { llvm.raw }

}

extension UnsafeReference where T: IRInstruction {

  /// Type-erased reference to the instruction.
  public var i: UnsafeReference<AnyInstruction> { .init(llvm) }

}

extension UnsafeReference where T: IRAttribute {

  /// Type-erased reference to the IR attribute.
  public var erased: UnsafeReference<AnyAttribute> { .init(llvm) }

  /// Native handle to the LLVM attribute reference.
  internal var raw: LLVMAttributeRef { llvm.raw }

}

extension UnsafeReference where T == BasicBlock {

  /// Native handle to the LLVM basic block reference.
  internal var raw: LLVMBasicBlockRef { llvm.raw }

}

/// Returns `true` iff `l` and `r` refer to the same object.
public func == <T: IRType, U: IRType>(l: UnsafeReference<T>, r: UnsafeReference<U>) -> Bool {
  l.llvm == r.llvm
}

/// Returns `true` iff `l` and `r` refer to the same object.
public func != <T: IRType, U: IRType>(l: UnsafeReference<T>, r: UnsafeReference<U>) -> Bool {
  l.llvm != r.llvm
}

/// Returns `true` iff `l` and `r` refer to the same object.
public func == <T: IRValue, U: IRValue>(l: UnsafeReference<T>, r: UnsafeReference<U>) -> Bool {
  l.llvm == r.llvm
}

/// Returns `true` iff `l` and `r` refer to different objects.
public func != <T: IRValue, U: IRValue>(l: UnsafeReference<T>, r: UnsafeReference<U>) -> Bool {
  l.llvm != r.llvm
}

/// Returns `true` iff `l` and `r` refer to the same object.
public func == <T: IRAttribute>(l: UnsafeReference<T>, r: AnyAttribute.UnsafeReference) -> Bool {
  l.llvm == r.llvm
}

/// Returns `true` iff `l` and `r` refer to different objects.
public func != <T: IRAttribute>(l: UnsafeReference<T>, r: AnyAttribute.UnsafeReference) -> Bool {
  l.llvm != r.llvm
}

/// Returns `true` iff `l` and `r` refer to the same object.
public func == <T: IRAttribute>(l: AnyAttribute.UnsafeReference, r: UnsafeReference<T>) -> Bool {
  l.llvm == r.llvm
}

/// Returns `true` iff `l` and `r` refer to different objects.
public func != <T: IRAttribute>(l: AnyAttribute.UnsafeReference, r: UnsafeReference<T>) -> Bool {
  l.llvm != r.llvm
}

/// Returns `true` iff `l` and `r` refer to the same object.
public func == (l: AnyAttribute.UnsafeReference, r: AnyAttribute.UnsafeReference) -> Bool {
  l.llvm == r.llvm
}

/// Returns `true` iff `l` and `r` refer to different objects.
public func != (l: AnyAttribute.UnsafeReference, r: AnyAttribute.UnsafeReference) -> Bool {
  l.llvm != r.llvm
}
