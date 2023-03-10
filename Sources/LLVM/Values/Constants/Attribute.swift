import llvmc

/// An entity capable of holding attributes.
///
/// Do not declare new conformances to `AttributeHolder`. Only the `Function` and `Parameter` in
/// are valid conforming types.
public protocol AttributeHolder {

  /// The name of targe-independent attributes for this holder.
  associatedtype AttributeName: AttributeNameProtocol

}

/// A target-independent attribute name.
public protocol AttributeNameProtocol: RawRepresentable where RawValue == String {}

extension AttributeNameProtocol {

  /// The unique kind identifier corresponding to this name.
  internal var id: UInt32 {
    return LLVMGetEnumAttributeKindForName(rawValue, rawValue.count)
  }

}

/// An attribute on a function, return value, or parameter in LLVM IR.
public enum Attribute<T: AttributeHolder>: Hashable {

  /// A target-independent attribute.
  case targetIndependent(llvm: LLVMAttributeRef)

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMAttributeRef?) {
    if LLVMIsEnumAttribute(llvm) != 0 {
      self = .targetIndependent(llvm: llvm!)
    } else {
      fatalError()
    }
  }

  /// Creates a target-independent attribute with given `name` and optional `value` in `module`.
  public init(_ name: T.AttributeName, _ value: UInt64 = 0, in module: inout Module) {
    self = .targetIndependent(llvm: LLVMCreateEnumAttribute(module.context, name.id, value)!)
  }

  /// A handle to the LLVM object wrapped by this instance.
  internal var llvm: LLVMAttributeRef {
    switch self {
    case .targetIndependent(let h):
      return h
    }
  }

}
