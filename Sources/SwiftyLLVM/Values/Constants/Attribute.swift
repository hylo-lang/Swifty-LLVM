internal import llvmc

/// An entity capable of holding attributes.
///
/// Do not declare new conformances to `AttributeHolder`. Only `Function`, `Function.Return`, and
/// `Parameter` are valid conforming types.
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
public enum Attribute<T: AttributeHolder>: Hashable, Sendable, LLVMEntity {
  public typealias Handle = AttributeRef

  /// Creates a target-independent attribute wrapping `llvm`.
  public init(temporarilyWrapping handle: AttributeRef) {
    self = .targetIndependent(llvm: handle)
  }

  /// A target-independent attribute.
  case targetIndependent(llvm: AttributeRef)

  /// Creates a target-independent attribute wrapping `llvm`.
  private init(_ llvm: LLVMAttributeRef?) {
    precondition(LLVMIsEnumAttribute(llvm) != 0)
    self = .targetIndependent(llvm: .init(llvm!))
  }

  /// Creates a target-independent attribute wrapping `llvm`.
  static func wrapTargetIndependent(_ llvm: LLVMAttributeRef?) -> Self {
    return Self(llvm)
  }

  /// The value of the attribute if it is target-independent.
  public var value: UInt64? {
    if case .targetIndependent(let h) = self {
      return LLVMGetEnumAttributeValue(h.raw)
    } else {
      return nil
    }
  }

  /// A handle to the LLVM object wrapped by this instance.
  internal var llvm: AttributeRef {
    switch self {
    case .targetIndependent(let h):
      return h
    }
  }

}
