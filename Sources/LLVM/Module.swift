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

  /// A handle to the LLVM context associated with this module.
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

  /// The data layout of the module.
  public var layout: DataLayout {
    get {
      let s = LLVMGetDataLayoutStr(llvm)
      let h = LLVMCreateTargetData(s)
      return .init(h!)
    }
    set {
      LLVMSetDataLayout(llvm, newValue.description)
    }
  }

  /// The target of the module.
  public var target: Target? {
    get {
      guard let t = LLVMGetTarget(llvm) else { return nil }
      return try? Target(triple: .init(cString: t))
    }
    set {
      LLVMSetTarget(llvm, newValue?.triple)
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
      throw LLVMError(.init(cString: message!))
    }
  }

  /// Writes the LLVM bitcode of this module to `filepath`.
  public func writeBitcode(to filepath: String) throws {
    guard LLVMWriteBitcodeToFile(llvm, filepath) == 0 else {
      throw LLVMError("write failure")
    }
  }

  /// Returns the LLVM bitcode of this module.
  public func bitcode() -> MemoryBuffer {
    .init(LLVMWriteBitcodeToMemoryBuffer(llvm), owned: true)
  }

  /// Compiles this module for given `machine` and writes a result of kind `type` to `filepath`.
  public func write(
    _ type: CodeGenerationResultType,
    for machine:TargetMachine,
    to filepath: String
  ) throws {
    var error: UnsafeMutablePointer<CChar>? = nil
    LLVMTargetMachineEmitToFile(machine.llvm, llvm, filepath, type.llvm, &error)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw LLVMError(.init(cString: e))
    }
  }

  /// Compiles this module for given `machine` and returns a result of kind `type`.
  public func compile(
    _ type: CodeGenerationResultType,
    for machine: TargetMachine
  ) throws -> MemoryBuffer {
    var output: LLVMMemoryBufferRef? = nil
    var error: UnsafeMutablePointer<CChar>? = nil
    LLVMTargetMachineEmitToMemoryBuffer(machine.llvm, llvm, type.llvm, &error, &output)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw LLVMError(.init(cString: e))
    }

    return .init(output!, owned: true)
  }

  /// Returns the type with given `name`, or `nil` if no such type exists.
  public func type(named name: String) -> IRType? {
    LLVMGetTypeByName2(context, name).map(AnyType.init(_:))
  }

  /// Returns the function with given `name`, or `nil` if no such function exists.
  public func function(named name: String) -> Function? {
    LLVMGetNamedFunction(llvm, name).map(Function.init(_:))
  }

  /// Returns a function with given `name` and `type`, declaring it in `self` if it doesn't exist.
  public mutating func declareFunction(_ name: String, _ type: FunctionType) -> Function {
    if let f = function(named: name) {
      precondition(f.valueType == type)
      return f
    } else {
      return .init(LLVMAddFunction(llvm, name, type.llvm))
    }
  }

  /// Adds attribute `a` to `f`.
  public mutating func addAttribute(_ a: Function.Attribute, to f: Function) {
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    LLVMAddAttributeAtIndex(f.llvm, i, a.llvm)
  }

  /// Adds attribute `a` to the return value of `r`.
  public mutating func addAttribute(_ a: Function.Return.Attribute, to r: Function.Return) {
    LLVMAddAttributeAtIndex(r.parent.llvm, 0, a.llvm)
  }

  /// Adds attribute `a` to `p`.
  public mutating func addAttribute(_ a: Parameter.Attribute, to p: Parameter) {
    let i = UInt32(p.index + 1)
    LLVMAddAttributeAtIndex(p.parent.llvm, i, a.llvm)
  }

  /// Removes `a` from `f`.
  public mutating func removeAttribute(_ a: Function.Attribute, from f: Function) {
    switch a {
    case .targetIndependent(let h):
      let k = LLVMGetEnumAttributeKind(h)
      let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
      LLVMRemoveEnumAttributeAtIndex(f.llvm, i, k)
    }
  }

  /// Removes `a` from `p`.
  public mutating func removeAttribute(_ a: Parameter.Attribute, from p: Parameter) {
    switch a {
    case .targetIndependent(let h):
      let k = LLVMGetEnumAttributeKind(h)
      let i = UInt32(p.index + 1)
      LLVMRemoveEnumAttributeAtIndex(p.parent.llvm, i, k)
    }
  }

  /// Removes `a` from `r`.
  public mutating func removeAttribute(_ a: Function.Return.Attribute, from r: Function.Return) {
    switch a {
    case .targetIndependent(let h):
      let k = LLVMGetEnumAttributeKind(h)
      LLVMRemoveEnumAttributeAtIndex(r.parent.llvm, 0, k)
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

  /// Returns an insertion point at the start of `b`.
  public func startOf(_ b: BasicBlock) -> InsertionPoint {
    if let h = LLVMGetFirstInstruction(b.llvm) {
      return before(Instruction(h))
    } else {
      return endOf(b)
    }
  }

  /// Returns an insertion point at the end of `b`.
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

  /// Inerts an `alloca` allocating memory on the stack a value of `type`, at the entry of `f`.
  ///
  /// - Requires: `f` has an entry block.
  public mutating func insertAlloca(_ type: IRType, atEntryOf f: Function) -> Alloca {
    insertAlloca(type, at: startOf(f.entry!))
  }

  public mutating func insertGetElementPointer(
    of base: IRValue,
    typed baseType: IRType,
    indices: [IRValue],
    at p: InsertionPoint
  ) -> Instruction {
    var i = indices.map({ $0.llvm as Optional })
    let h = LLVMBuildGEP2(p.llvm, baseType.llvm, base.llvm, &i, UInt32(i.count), "")!
    return .init(h)
  }

  public mutating func insertGetElementPointerInBounds(
    of base: IRValue,
    typed baseType: IRType,
    indices: [IRValue],
    at p: InsertionPoint
  ) -> Instruction {
    var i = indices.map({ $0.llvm as Optional })
    let h = LLVMBuildInBoundsGEP2(p.llvm, baseType.llvm, base.llvm, &i, UInt32(i.count), "")!
    return .init(h)
  }

  public mutating func insertGetStructElementPointer(
    of base: IRValue,
    typed baseType: StructType,
    index: Int,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildStructGEP2(p.llvm, baseType.llvm, base.llvm, UInt32(index), ""))
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

  // MARK: Terminators

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

  @discardableResult
  public mutating func insertUnreachable(at p: InsertionPoint) -> Instruction {
    .init(LLVMBuildUnreachable(p.llvm))
  }

  // MARK: Aggregate operations

  public mutating func insertExtractValue(
    from whole: IRValue,
    at index: Int,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildExtractValue(p.llvm, whole.llvm, UInt32(index), ""))
  }

  public mutating func insertInsertValue(
    _ part: IRValue,
    at index: Int,
    into whole: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildInsertValue(p.llvm, whole.llvm, part.llvm, UInt32(index), ""))
  }

  // MARK: Conversions

  public mutating func insertTrunc(
    _ source: IRValue, to target: IRType,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildTrunc(p.llvm, source.llvm, target.llvm, ""))
  }

  public mutating func insertSignExtend(
    _ source: IRValue, to target: IRType,
    at p: Instruction
  ) -> Instruction {
    .init(LLVMBuildSExt(p.llvm, source.llvm, target.llvm, ""))
  }

  public mutating func insertZeroExtend(
    _ source: IRValue, to target: IRType,
    at p: Instruction
  ) -> Instruction {
    .init(LLVMBuildZExt(p.llvm, source.llvm, target.llvm, ""))
  }

  public mutating func insertFPTrunc(
    _ source: IRValue, to target: IRType,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFPTrunc(p.llvm, source.llvm, target.llvm, ""))
  }

  public mutating func insertFPExtend(
    _ source: IRValue, to target: IRType,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFPExt(p.llvm, source.llvm, target.llvm, ""))
  }

  // MARK: Others

  public mutating func insertCall(
    _ callee: Function,
    on arguments: [IRValue],
    at p: InsertionPoint
  ) -> Instruction {
    insertCall(callee, typed: callee.valueType, on: arguments, at: p)
  }

  public mutating func insertCall(
    _ callee: IRValue,
    typed calleeType: IRType,
    on arguments: [IRValue],
    at p: InsertionPoint
  ) -> Instruction {
    var a = arguments.map({ $0.llvm as Optional })
    return .init(LLVMBuildCall2(p.llvm, calleeType.llvm, callee.llvm, &a, UInt32(a.count), ""))
  }

  public mutating func insertIntegerComparison(
    _ predicate: IntegerPredicate,
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    precondition(lhs.type == rhs.type)
    return .init(LLVMBuildICmp(p.llvm, predicate.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertFloatingPointComparison(
    _ predicate: FloatingPointPredicate,
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    precondition(lhs.type == rhs.type)
    return .init(LLVMBuildFCmp(p.llvm, predicate.llvm, lhs.llvm, rhs.llvm, ""))
  }

}

extension Module: CustomStringConvertible {

  public var description: String {
    guard let s = LLVMPrintModuleToString(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return String(cString: s)
  }

}
