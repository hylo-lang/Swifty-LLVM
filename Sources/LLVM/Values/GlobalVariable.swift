import llvmc

/// A global value in LLVM IR.
public struct GlobalVariable: Global {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = llvm
  }

  /// `true` if this value is constant.
  ///
  /// If this value is a global constant, its value is immutable throughout the runtime execution
  /// of the program. Assigning a value into it leads to undefined behavior.
  ///
  /// - Note: This property should not be confused with `IRValue.isConstant`, which indicates
  ///   whether a value is a constant user, as opposed to an instruction.
  public var isGlobalConstant: Bool {
    get { LLVMIsGlobalConstant(llvm) != 0 }
    set { LLVMSetGlobalConstant(llvm, newValue ? 1 : 0) }
  }

  /// `true` is this value is initialized externally.
  public var isExternallyInitialized: Bool {
    get { LLVMIsExternallyInitialized(llvm) != 0 }
    set { LLVMSetExternallyInitialized(llvm, newValue ? 1 : 0) }
  }

  /// The initial value of this global.
  public var initializer: IRValue? {
    get { LLVMGetInitializer(llvm).map(AnyValue.init(_:)) }
    set { LLVMSetInitializer(llvm, newValue?.llvm) }
  }

}
