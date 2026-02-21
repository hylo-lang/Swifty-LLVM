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
  /// A reference to Self. The poinees are owned by LLVM.
  public typealias Reference = SwiftyLLVM.Reference<Self>
}

public struct Reference<T: LLVMEntity>: Hashable {
  internal let llvm: T.Handle

  internal init(_ llvm: T.Handle) { self.llvm = llvm }

  /// Creates a temporary wrapper for the type.
  ///
  /// The caller must ensure that the wrapper doesn't become a dangling reference.
  public var unsafePointee: T { T(temporarilyWrapping: llvm) }

  public func with<R>(_ witness: (T) throws -> R) rethrows -> R {
    try witness(unsafePointee)
  }
}

/// Downcasting from erased reference.
extension Reference {
  /// Downcasts an AnyType reference to the desired IRType reference.
  public init(_ reference: Reference<AnyType>) where T: IRType {
    self.init(reference.llvm)
  }

  /// Downcasts an AnyValue reference to the desired IRValue reference.
  public init(_ reference: Reference<AnyValue>) where T: IRValue {
    self.init(reference.llvm)
  }

  // Downcasts an AnyAttribute reference to a function attribute.
  public init(_ reference: Reference<AnyAttribute>) where T: IRAttribute {
    self.init(reference.llvm)
  }
}

/// Downcasting from native handle to the desired reference type.
extension Reference {
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

extension Reference<BasicBlock> {
  /// Creates a BasicBlock reference from a native handle.
  init(_ reference: LLVMBasicBlockRef) {
    self.init(BasicBlockRef(reference))
  }
}

extension Reference where T: IRType {
  /// Type-erased reference to the IR type.
  public var erased: Reference<AnyType> { .init(llvm) }

  /// Native handle to the LLVM type reference.
  var raw: LLVMTypeRef { llvm.raw }
}

extension Reference where T: IRValue {
  /// Type-erased reference to the IR value.
  public var erased: Reference<AnyValue> { .init(llvm) }

  /// Native handle to the LLVM value reference.
  var raw: LLVMValueRef { llvm.raw }
}

extension Reference where T: IRAttribute {
  /// Type-erased reference to the IR attribute.
  public var erased: Reference<AnyAttribute> { .init(llvm) }

  /// Native handle to the LLVM attribute reference.
  var raw: LLVMAttributeRef { llvm.raw }
}

extension Reference where T == BasicBlock {
  /// Native handle to the LLVM basic block reference.
  var raw: LLVMBasicBlockRef { llvm.raw }
}
