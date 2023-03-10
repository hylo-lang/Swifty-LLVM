import llvmc

/// The top-level structure in an LLVM program.
public struct Module {

  /// The resources wrapped by an instance of `Module`.
  private final class Handles {

    /// The context owning the contents of the LLVM module.
    let context: LLVMContextRef

    /// The LLVM module.
    let module: LLVMModuleRef

    /// Creates an instance with given properties.
    init(context: LLVMContextRef, module: LLVMModuleRef) {
      self.context = context
      self.module = module
    }

    /// Dispose of the managed resources.
    deinit {
      LLVMDisposeModule(module)
      LLVMContextDispose(context)
    }

  }

  /// Handles to the resources wrapped by this instance.
  private let handles: Handles

  /// Creates an instance with given `name`.
  public init(_ name: String) {
    let c = LLVMContextCreate()!
    let m = LLVMModuleCreateWithNameInContext(name, c)!
    self.handles = .init(context: c, module: m)
  }

  /// A handle to the LLVM object wrapped by this instance.
  public var llvm: LLVMModuleRef { handles.module }

  /// A handle to the LLVM context associated to this module.
  internal var context: LLVMContextRef { handles.context }

  /// The name of the module.
  public var name: String {
    get {
      String(from: llvm, readingWith: LLVMGetModuleIdentifier(_:_:)) ?? ""
    }
    set {
      newValue.withCString({ LLVMSetModuleIdentifier(llvm, $0, newValue.utf8.count) })
    }
  }

  /// Verifies if the IR in `self` is well formed and throws an error if it isn't.
  public func verify() throws {
    var message: UnsafeMutablePointer<CChar>? = nil
    defer { LLVMDisposeMessage(message) }
    let status = withUnsafeMutablePointer(to: &message, { (m) in
      LLVMVerifyModule(llvm, LLVMReturnStatusAction, m)
    })

    if status != 0 {
      throw VerificationError(description: String(cString: message!))
    }
  }

  /// Returns the with given `name`, or `nil` if no such type exists.
  public func type(named name: String) -> IRType? {
    LLVMGetTypeByName2(context, name).map(AnyType.init(_:))
  }

  /// Returns an a function with given `name` and `type`, declaring it in `self` if it doesn't
  /// exist yet.
  public mutating func declareFunction(_ name: String, _ type: FunctionType) -> Function {
    if let h = LLVMGetNamedFunction(llvm, name) {
      let f = Function(h)
      precondition(f.valueType == type)
      return f
    } else {
      return .init(LLVMAddFunction(llvm, name, type.llvm))
    }
  }

  /// Adds a target-independent attribute with given `name` and optional `value` to `f`.
  @discardableResult
  public mutating func addAttribute(
    _ name: Function.AttributeName, _ value: UInt64 = 0, to f: Function
  ) -> Attribute {
    let a = LLVMCreateEnumAttribute(context, name.id, value)!
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    LLVMAddAttributeAtIndex(f.llvm, i, a)
    return .targetIndependent(llvm: a)
  }

  /// Removes `a` from `f`.
  public mutating func removeAttribute(_ a: Attribute, from f: Function) {
    switch a {
    case .targetIndependent(let h):
      let k = LLVMGetEnumAttributeKind(h)
      let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
      LLVMRemoveEnumAttributeAtIndex(f.llvm, i, k)
    }
  }

  /// Appends a basic block named `n` to `f` and returns it.
  ///
  /// A unique name is generated if `n` is empty or if `f` already contains a block named `n`.
  @discardableResult
  public mutating func appendBlock(named n: String = "", to f: Function) -> BasicBlock {
    .init(LLVMAppendBasicBlockInContext(context, f.llvm, n))
  }

  /// Returns an insertion pointing before `i`.
  public func before(_ i: Instruction) -> InsertionPoint {
    let h = LLVMCreateBuilderInContext(context)!
    LLVMPositionBuilderBefore(h, i.llvm)
    return .init(h)
  }

  /// Returns an insertion point at the ebd of `b`.
  public func endOf(_ b: BasicBlock) -> InsertionPoint {
    let h = LLVMCreateBuilderInContext(context)!
    LLVMPositionBuilderAtEnd(h, b.llvm)
    return .init(h)
  }

  // MARK: Arithmetics

  public mutating func insertAdd(
    overflow: OverflowBehavior = .ignore,
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    switch overflow {
    case .ignore:
      return .init(LLVMBuildAdd(p.llvm, lhs.llvm, rhs.llvm, ""))
    case .nuw:
      return .init(LLVMBuildNUWAdd(p.llvm, lhs.llvm, rhs.llvm, ""))
    case .nsw:
      return .init(LLVMBuildNSWAdd(p.llvm, lhs.llvm, rhs.llvm, ""))
    }
  }

  public mutating func insertFAdd(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFAdd(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertSub(
    overflow: OverflowBehavior = .ignore,
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    switch overflow {
    case .ignore:
      return .init(LLVMBuildSub(p.llvm, lhs.llvm, rhs.llvm, ""))
    case .nuw:
      return .init(LLVMBuildNUWSub(p.llvm, lhs.llvm, rhs.llvm, ""))
    case .nsw:
      return .init(LLVMBuildNSWSub(p.llvm, lhs.llvm, rhs.llvm, ""))
    }
  }

  public mutating func insertFSub(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFSub(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertMul(
    overflow: OverflowBehavior = .ignore,
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    switch overflow {
    case .ignore:
      return .init(LLVMBuildMul(p.llvm, lhs.llvm, rhs.llvm, ""))
    case .nuw:
      return .init(LLVMBuildNUWMul(p.llvm, lhs.llvm, rhs.llvm, ""))
    case .nsw:
      return .init(LLVMBuildNSWMul(p.llvm, lhs.llvm, rhs.llvm, ""))
    }
  }

  public mutating func insertFMul(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFMul(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertUnsignedDiv(
    exact: Bool = false,
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    if exact {
      return .init(LLVMBuildExactUDiv(p.llvm, lhs.llvm, rhs.llvm, ""))
    } else {
      return .init(LLVMBuildUDiv(p.llvm, lhs.llvm, rhs.llvm, ""))
    }
  }

  public mutating func insertSignedDiv(
    exact: Bool = false,
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    if exact {
      return .init(LLVMBuildExactSDiv(p.llvm, lhs.llvm, rhs.llvm, ""))
    } else {
      return .init(LLVMBuildSDiv(p.llvm, lhs.llvm, rhs.llvm, ""))
    }
  }

  public mutating func insertFDiv(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
     .init(LLVMBuildFDiv(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  // MARK: Memory

  public mutating func insertAlloca(_ type: IRType, at p: InsertionPoint) -> Alloca {
    .init(LLVMBuildAlloca(p.llvm, type.llvm, ""))
  }

  public mutating func insertLoad(
    _ type: IRType, from source: IRValue, at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildLoad2(p.llvm, type.llvm, source.llvm, ""))
  }

  @discardableResult
  public mutating func insertStore(
    _ value: IRValue, to location: IRValue, at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildStore(p.llvm, value.llvm, location.llvm))
  }

  // MARK: Control flow

  @discardableResult
  public mutating func insertBr(to destination: BasicBlock, at p: InsertionPoint) -> Instruction {
    .init(LLVMBuildBr(p.llvm, destination.llvm))
  }

  @discardableResult
  public mutating func insertCondBr(
    if condition: IRValue, then t: BasicBlock, else e: BasicBlock,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildCondBr(p.llvm, condition.llvm, t.llvm, e.llvm))
  }

  @discardableResult
  public mutating func insertReturn(at p: InsertionPoint) -> Instruction {
    .init(LLVMBuildRetVoid(p.llvm))
  }

  @discardableResult
  public mutating func insertReturn(_ value: IRValue, at p: InsertionPoint) -> Instruction {
    .init(LLVMBuildRet(p.llvm, value.llvm))
  }

}

extension Module: CustomStringConvertible {

  public var description: String {
    guard let s = LLVMPrintModuleToString(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return String(cString: s)
  }

}
