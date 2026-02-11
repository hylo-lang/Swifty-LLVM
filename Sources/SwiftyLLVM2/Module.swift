internal import llvmc

/// A temporarily exposed view of an LLVM module.
public struct Module: LLVMEntity {
  /// A borrowed handle to the LLVM module object wrapped by this instance.
  internal let moduleReference: LLVMModuleRef

  /// True iff there is a live projection of the module's data layout.
  /// At any given time, there can be at most one live projection of the data layout.
  private var isDataLayoutBorrowed = false

  /// Constructs a `Module` for temporary use.
  internal init(wrappingTemporarily module: LLVMModuleRef) {
    self.moduleReference = module
  }

  /// The name of the module.
  public var name: String {
    get {
      String(from: moduleReference, readingWith: LLVMGetModuleIdentifier(_:_:))!
    }
    set {
      newValue.withCString({ LLVMSetModuleIdentifier(moduleReference, $0, newValue.utf8.count) })
    }
  }

  /// Projects out its data layout temporarily.
  ///
  /// - Requires: No projection of the data layout is live.
  public mutating func withDataLayout<R>(_ witness: (inout DataLayout) throws -> R) rethrows -> R {
    precondition(!isDataLayoutBorrowed, "`dataLayout` must not be already borrowed.")

    isDataLayoutBorrowed = true
    var layout = DataLayout(wrappingTemporarily: LLVMGetModuleDataLayout(moduleReference))

    defer {
      LLVMDisposeTargetData(layout.llvmDataLayout)
      isDataLayoutBorrowed = false
    }

    return try witness(&layout)
  }

  /// The target of the module.
  /// 
  /// Targets are immortal independent objects, so it is safe to escape them.
  public var target: Target? {
    get {
      guard let t = LLVMGetTarget(moduleReference) else { return nil }

      // Assuming this will succeed since the module has a target, and targets are immortal.
      return try! Target(triple: .init(cString: t))
    }
    set {
      LLVMSetTarget(moduleReference, newValue?.triple)
    }
  }

}
