internal import llvmc

extension Parameter: AttributeHolder {

  /// An attribute on a parameter in LLVM IR.
  public typealias Attribute = SwiftyLLVM.Attribute<Parameter>

  /// The name of an attribute on a parameter in LLVM IR.
  public enum AttributeName: String, AttributeNameProtocol, Sendable {

    /// Indicates to the code generator that the parameter or return value should be sign-extended
    /// to the extent required by the target’s ABI (which is usually 32-bits) by the caller (for a
    /// parameter) or the callee (for a return value).
    case signext

    /// Indicates to the code generator that the parameter or return value should be zero-extended
    /// to the extent required by the target’s ABI by the caller (for a parameter) or the callee
    /// (for a return value).
    case zeroext

    /// Indicates that this parameter or return value should be treated in a special
    /// target-dependent fashion while emitting code for a function call or return (usually, by
    /// putting it in a register as opposed to memory, though some targets use it to distinguish
    /// between two different kinds of registers). Use of this attribute is target-specific.
    case inreg

    /// Indicates that the pointer value or vector of pointers has the specified alignment.
    case align

    /// Indicates that the alignment that should be considered by the backend when assigning this
    /// parameter to a stack slot during calling convention lowering
    case alignstack

    /// Indicates that the function parameter marked with this attribute is is the alignment in
    /// bytes of the newly allocated block returned by this function.
    case allocalign

    /// Indicates that the function parameter marked with this attribute is the pointer that will
    /// be manipulated by the allocator.
    case allocptr

    /// Indicates that memory locations accessed via pointer values based on the argument or return
    /// value are not also accessed, during the execution of the function, via pointer values not
    /// *based* on the argument or return value.
    case noalias

    /// Indicates that the callee does not capture the pointer. This is not a valid attribute for
    /// return values.
    case nocapture

    /// Indicates that callee does not free the pointer argument.
    ///
    /// This attribute is not valid for return values.
    case nofree

    /// Indicates that the function always returns the argument as its return value.
    case returned

    /// Indicates that the parameter or return pointer is not null. This attribute may only be
    /// applied to pointer typed parameters
    case nonnull

    /// Indicates that the parameter or return value is not undefined.
    case noundef

    /// Indicates that the function does not dereference that pointer argument, even though it may
    /// read or write the memory that the pointer points to if accessed through other pointers.
    case readnone

    /// Indicates that the function does not write through this pointer argument, even though it
    /// may write to the memory that the pointer points to.
    case readonly

    /// Indicates that the function may write to, but does not read through this pointer argument
    /// (even though it may read from the memory that the pointer points to).
    case writeonly

    /// Indicates that the parameter or return pointer is dereferenceable.
    case dereferenceable

    /// Indicates that the parameter or return value isn’t both non-null and non-dereferenceable
    /// (up to *n* bytes) at the same time.
    case dereferenceable_or_null

    /// Indicates that the parameter is required to be an immediate value.
    case immarg

  }

  /// The attributes of the parameter.
  public var attributes: [Attribute.Reference] {
    let i = UInt32(index + 1)
    let n = LLVMGetAttributeCountAtIndex(parent.llvm.raw, i)
    var handles: [LLVMAttributeRef?] = .init(repeating: nil, count: Int(n))
    LLVMGetAttributesAtIndex(parent.llvm.raw, i, &handles)
    return handles.map { Attribute.Reference($0!) }
  }

}
