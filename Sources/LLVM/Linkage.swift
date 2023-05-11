import llvmc

/// How names can or cannot be referred to.
///
/// - Note: It is illegal for a global variable or function declaration to have any linkage type
///   other than `external` or `extern_weak`.
public enum Linkage {

  /// The name is externally visible; it participates in linkage and can be used to resolve
  /// external symbol references.
  case external

  /// The name is never emitted into the object file corresponding to the LLVM module
  ///
  /// Globals with `available_externally` linkage are allowed to be discarded at will, and allow
  /// inlining and other optimizations. This linkage type is only allowed on definitions, not
  /// declarations.
  case availableExternally

  /// The name is merged with other globals of the same name when linkage occurs.
  ///
  /// This linkage can be used to implement some forms of inline functions, templates, or other
  /// code which must be generated in each translation unit that uses it, but where the body may
  /// be overridden with a more definitive definition later. Unreferenced `linkonce` globals are
  /// allowed to be discarded.
  ///
  /// Note that linkonce linkage does not actually allow the optimizer to inline the body of this
  /// function into callers because it doesn’t know if this definition of the function is the
  /// definitive definition within the program or whether it will be overridden by a stronger
  /// definition. To enable inlining and other optimizations, use `linkonce_odr` linkage.
  case linkOnceAny

  /// The name is merged with other globals of the same name when linkage occurs.
  ///
  /// Some languages allow differing globals to be merged, such as two functions with different
  /// semantics. Other languages, such as C++, ensure that only equivalent globals are ever merged
  /// (the "one definition rule" — "ODR"). Such languages can use the `linkonce_odr` and `weak_odr`
  /// linkage types to indicate that the global will only be merged with equivalent globals. These
  /// linkage types are otherwise the same as their non-odr versions.
  case linkOnceODR

  /// Same as `linkonce`, except that unreferenced globals with weak linkage may not be discarded.
  case weak

  /// Same as `linkonce`, except that unreferenced globals with weak linkage may not be discarded.
  ///
  /// Some languages allow differing globals to be merged, such as two functions with different
  /// semantics. Other languages, such as C++, ensure that only equivalent globals are ever merged
  /// (the "one definition rule" — "ODR"). Such languages can use the `linkonce_odr` and `weak_odr`
  /// linkage types to indicate that the global will only be merged with equivalent globals. These
  /// linkage types are otherwise the same as their non-odr versions.
  case weakODR

  /// The value of the names are appended.
  ///
  /// Only applies to global variables of pointer to array type.
  case appending

  /// Similar to `private`, but the value shows as a local symbol (`STB_LOCAL` in the case of
  /// `ELF`) in the object file.
  case `internal`

  /// The name is only accessible by objects in the current module.
  ///
  /// Linking code into a module with a private global value may cause the private to be renamed as
  /// necessary to avoid collisions. Because the symbol is private to the module, all references
  /// can be updated. This doesn’t show up in any symbol table in the object file.
  case `private`

  /// The semantics of this linkage follow the ELF object file model: the symbol is weak until
  /// linked, if not linked, the symbol becomes null instead of being an undefined reference.
  case externWeak

  /// Creates an instance from its LLVM representation.
  internal init(llvm: LLVMLinkage) {
    switch llvm {
    case LLVMExternalLinkage:
      self = .external
    case LLVMAvailableExternallyLinkage:
      self = .availableExternally
    case LLVMLinkOnceAnyLinkage:
      self = .linkOnceAny
    case LLVMLinkOnceODRLinkage:
      self = .linkOnceODR
    case LLVMWeakAnyLinkage:
      self = .weak
    case LLVMWeakODRLinkage:
      self = .weakODR
    case LLVMAppendingLinkage:
      self = .appending
    case LLVMInternalLinkage:
      self = .internal
    case LLVMPrivateLinkage:
      self = .private
    case LLVMExternalWeakLinkage:
      self = .externWeak
    default:
      fatalError("unsupported linkage type")
    }
  }

  /// The LLVM representation of this instance.
  internal var llvm: LLVMLinkage {
    switch self {
    case .external:
      return LLVMExternalLinkage
    case .availableExternally:
      return LLVMAvailableExternallyLinkage
    case .linkOnceAny:
      return LLVMLinkOnceAnyLinkage
    case .linkOnceODR:
      return LLVMLinkOnceODRLinkage
    case .weak:
      return LLVMWeakAnyLinkage
    case .weakODR:
      return LLVMWeakODRLinkage
    case .appending:
      return LLVMAppendingLinkage
    case .internal:
      return LLVMInternalLinkage
    case .private:
      return LLVMPrivateLinkage
    case .externWeak:
      return LLVMExternalWeakLinkage
    }
  }

}
