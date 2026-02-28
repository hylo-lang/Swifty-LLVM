import Foundation
internal import llvmc

/// An LLVM type reference.
public struct TypeRef: Hashable {

  /// The underlying LLVM value.
  let raw: llvmc.LLVMTypeRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMTypeRef) { self.raw = raw }

}

/// An LLVM value reference.
public struct ValueRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid rexporting llvmc
  let raw: llvmc.LLVMValueRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMValueRef) { self.raw = raw }

}

/// An LLVM basic block reference.
public struct BasicBlockRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid rexporting llvmc
  let raw: llvmc.LLVMBasicBlockRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMBasicBlockRef) { self.raw = raw }

}

/// An LLVM module reference.
public struct ModuleRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid rexporting llvmc
  let raw: llvmc.LLVMModuleRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMModuleRef) { self.raw = raw }

}

/// An LLVM attribute reference.
public struct AttributeRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid rexporting llvmc
  let raw: llvmc.LLVMAttributeRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMAttributeRef) { self.raw = raw }

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

public struct UnsafeReference<T: LLVMEntity>: Hashable {
  internal let llvm: T.Handle

  internal init(_ llvm: T.Handle) { self.llvm = llvm }

  /// Creates a temporary wrapper for the type.
  ///
  /// The caller must ensure that the wrapper doesn't become a dangling reference.
  public var pointee: T { T(temporarilyWrapping: llvm) }

  public func with<R>(_ witness: (T) throws -> R) rethrows -> R {
    try witness(pointee)
  }
}

/// Downcasting from erased reference.
extension UnsafeReference {
  /// Downcasts an AnyType reference to the desired IRType reference.
  public init(uncheckedFrom reference: UnsafeReference<AnyType>) where T: IRType {
    self.init(reference.llvm)
  }

  /// Downcasts an AnyValue reference to the desired IRValue reference.
  public init(uncheckedFrom reference: UnsafeReference<AnyValue>) where T: IRValue {
    self.init(reference.llvm)
  }

  // Downcasts an AnyAttribute reference to a function attribute.
  public init(uncheckedFrom reference: UnsafeReference<AnyAttribute>) where T: IRAttribute {
    self.init(reference.llvm)
  }
}

/// Downcasting from native handle to the desired reference type.
extension UnsafeReference {
  /// Downcasts a native handle to the desired IRType reference.
  init(_ reference: LLVMTypeRef) where T: IRType {
    self.init(TypeRef(reference))
  }

  /// Downcasts a native handle to the desired IRValue reference.
  init(_ reference: LLVMValueRef) where T: IRValue {
    self.init(ValueRef(reference))
  }

  /// Downcasts a native handle to the desired IRAttribute reference.
  init(_ reference: LLVMAttributeRef) where T: IRAttribute {
    self.init(AttributeRef(reference))
  }
}

extension UnsafeReference<BasicBlock> {
  /// Creates a BasicBlock reference from a native handle.
  init(_ reference: LLVMBasicBlockRef) {
    self.init(BasicBlockRef(reference))
  }
}

extension UnsafeReference where T: IRType {
  /// Type-erased reference to the IR type.
  public var erased: UnsafeReference<AnyType> { .init(llvm) }

  /// Native handle to the LLVM type reference.
  var raw: LLVMTypeRef { llvm.raw }
}

extension UnsafeReference where T: IRValue {
  /// Type-erased reference to the IR value.
  public var erased: UnsafeReference<AnyValue> { .init(llvm) }

  /// Native handle to the LLVM value reference.
  var raw: LLVMValueRef { llvm.raw }
}

extension UnsafeReference where T: IRAttribute {
  /// Type-erased reference to the IR attribute.
  public var erased: UnsafeReference<AnyAttribute> { .init(llvm) }

  /// Native handle to the LLVM attribute reference.
  var raw: LLVMAttributeRef { llvm.raw }
}

extension UnsafeReference where T == BasicBlock {
  /// Native handle to the LLVM basic block reference.
  var raw: LLVMBasicBlockRef { llvm.raw }
}


/// Returns `true` iff the given type references are equal.
public func == (lhs: UnsafeReference<some IRType>, rhs: AnyType.UnsafeReference) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given type references are not equal.
public func != (lhs: UnsafeReference<some IRType>, rhs: AnyType.UnsafeReference) -> Bool {
  lhs.llvm != rhs.llvm
}
/// Returns `true` iff the given type references are equal.
public func == (lhs: AnyType.UnsafeReference, rhs: UnsafeReference<some IRType>) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given type references are not equal.
public func != (lhs: AnyType.UnsafeReference, rhs: UnsafeReference<some IRType>) -> Bool {
  lhs.llvm != rhs.llvm
}
/// Returns `true` iff the given type references are equal.
public func == (lhs: AnyType.UnsafeReference, rhs: AnyType.UnsafeReference) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given type references are not equal.
public func != (lhs: AnyType.UnsafeReference, rhs: AnyType.UnsafeReference) -> Bool {
  lhs.llvm != rhs.llvm
}

/// Returns `true` iff the given type references are equal.
public func == (lhs: UnsafeReference<some IRValue>, rhs: AnyValue.UnsafeReference) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given value references are not equal.
public func != (lhs: UnsafeReference<some IRValue>, rhs: AnyValue.UnsafeReference) -> Bool {
  lhs.llvm != rhs.llvm
}
/// Returns `true` iff the given type references are equal.
public func == (lhs: AnyValue.UnsafeReference, rhs: UnsafeReference<some IRValue>) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given value references are not equal.
public func != (lhs: AnyValue.UnsafeReference, rhs: UnsafeReference<some IRValue>) -> Bool {
  lhs.llvm != rhs.llvm
}
/// Returns `true` iff the given type references are equal.
public func == (lhs: AnyValue.UnsafeReference, rhs: AnyValue.UnsafeReference) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given value references are not equal.
public func != (lhs: AnyValue.UnsafeReference, rhs: AnyValue.UnsafeReference) -> Bool {
  lhs.llvm != rhs.llvm
}


/// Returns `true` iff the given attribute references are equal.
public func == (lhs: UnsafeReference<some IRAttribute>, rhs: AnyAttribute.UnsafeReference) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given attribute references are not equal.
public func != (lhs: UnsafeReference<some IRAttribute>, rhs: AnyAttribute.UnsafeReference) -> Bool {
  lhs.llvm != rhs.llvm
}
/// Returns `true` iff the given attribute references are equal.
public func == (lhs: AnyAttribute.UnsafeReference, rhs: UnsafeReference<some IRAttribute>) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given attribute references are not equal.
public func != (lhs: AnyAttribute.UnsafeReference, rhs: UnsafeReference<some IRAttribute>) -> Bool {
  lhs.llvm != rhs.llvm
}
/// Returns `true` iff the given attribute references are equal.
public func == (lhs: AnyAttribute.UnsafeReference, rhs: AnyAttribute.UnsafeReference) -> Bool {
  lhs.llvm == rhs.llvm
}
/// Returns `true` iff the given attribute references are not equal.
public func != (lhs: AnyAttribute.UnsafeReference, rhs: AnyAttribute.UnsafeReference) -> Bool {
  lhs.llvm != rhs.llvm
}
