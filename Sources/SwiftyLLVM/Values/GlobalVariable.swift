internal import llvmc

/// A global value in LLVM IR.
public struct GlobalVariable: Global {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

  /// `true` if this value is constant.
  ///
  /// If this value is a global constant, its value is immutable throughout the runtime execution
  /// of the program. Assigning a value into it leads to undefined behavior.
  ///
  /// - Note: This property should not be confused with `IRValue.isConstant`, which indicates
  ///   whether a value is a constant user, as opposed to an instruction.
  public var isGlobalConstant: Bool { LLVMIsGlobalConstant(llvm.raw) != 0 }

  /// `true` is this value is initialized externally.
  public var isExternallyInitialized: Bool { LLVMIsExternallyInitialized(llvm.raw) != 0 }

  /// The initial value of this global.
  public var initializer: AnyValue.Reference? {
    LLVMGetInitializer(llvm.raw).map(AnyValue.Reference.init(_:))
  }

}
