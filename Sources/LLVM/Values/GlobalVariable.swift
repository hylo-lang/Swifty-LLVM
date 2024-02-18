import llvmc

/// A global value in LLVM IR.
public struct GlobalVariable: Global {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: LLVMValueRef

  public let context: ContextHandle

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef, in context: ContextHandle) {
    self.llvm = llvm
    self.context = context
  }

  /// `true` if this value is constant.
  ///
  /// If this value is a global constant, its value is immutable throughout the runtime execution
  /// of the program. Assigning a value into it leads to undefined behavior.
  ///
  /// - Note: This property should not be confused with `IRValue.isConstant`, which indicates
  ///   whether a value is a constant user, as opposed to an instruction.
  public var isGlobalConstant: Bool { LLVMIsGlobalConstant(llvm) != 0 }

  /// `true` is this value is initialized externally.
  public var isExternallyInitialized: Bool { LLVMIsExternallyInitialized(llvm) != 0 }

  /// The initial value of this global.
  public var initializer: IRValue? { LLVMGetInitializer(llvm).map { AnyValue($0, in: context) } }

}
