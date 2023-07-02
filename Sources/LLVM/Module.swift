import llvmc
import llvmshims

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

  /// Runs standard optimization passes on `self` tuned for given `optimization` and `machine`.
  public mutating func runDefaultModulePasses(
    optimization: OptimitzationLevel = .none,
    for machine: TargetMachine? = nil
  ) {
    let o: SwiftyLLVMPassOptimizationLevel
    switch optimization {
    case .none:
      o = SwiftyLLVMPassOptimizationLevelO0
    case .less:
      o = SwiftyLLVMPassOptimizationLevelO1
    case .default:
      o = SwiftyLLVMPassOptimizationLevelO2
    case .aggressive:
      o = SwiftyLLVMPassOptimizationLevelO3
    }
    SwiftyLLVMRunDefaultModulePasses(llvm, machine?.llvm, o)
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

  /// Returns the global with given `name`, or `nil` if no such global exists.
  public func global(named name: String) -> GlobalVariable? {
    LLVMGetNamedGlobal(llvm, name).map(GlobalVariable.init(_:))
  }

  /// Returns the intrinsic with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(named name: String, for parameters: [IRType] = []) -> Intrinsic? {
    let i = name.withCString({ LLVMLookupIntrinsicID($0, name.utf8.count) })
    guard i != 0 else { return nil }

    let h = parameters.withHandles { (p) in
      LLVMGetIntrinsicDeclaration(llvm, i, p.baseAddress, parameters.count)
    }
    return h.map(Intrinsic.init(_:))
  }

  /// Returns the intrinsic with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(
    named name: Intrinsic.Name, for parameters: [IRType] = []
  ) -> Intrinsic? {
    intrinsic(named: name.value, for: parameters)
  }

  /// Creates and returns a global variable with given `name` and `type`.
  ///
  /// A unique name is generated if `name` is empty or if `self` already contains a global with
  /// the same name.
  public mutating func addGlobalVariable(
    _ name: String = "",
    _ type: IRType,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable {
    .init(LLVMAddGlobalInAddressSpace(llvm, type.llvm, name, s.llvm))
  }

  /// Returns a global variable with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareGlobalVariable(
    _ name: String,
    _ type: IRType,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable {
    if let g = global(named: name) {
      precondition(g.valueType == type)
      return g
    } else {
      return .init(LLVMAddGlobalInAddressSpace(llvm, type.llvm, name, s.llvm))
    }
  }

  /// Returns a function with given `name` and `type`, declaring it if it doesn't exist.
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

  /// Adds the attribute named `n` to `f` and returns it.
  @discardableResult
  public mutating func addAttribute(
    named n: Function.AttributeName, to f: Function
  ) -> Function.Attribute {
    let a = Function.Attribute(n, in: &self)
    addAttribute(a, to: f)
    return a
  }

  /// Adds attribute `a` to the return value of `f`.
  public mutating func addAttribute(_ a: Function.Return.Attribute, to r: Function.Return) {
    LLVMAddAttributeAtIndex(r.parent.llvm, 0, a.llvm)
  }

  /// Adds the attribute named `n` to the return value of `f` and returns it.
  @discardableResult
  public mutating func addAttribute(
    named n: Function.Return.AttributeName, to r: Function.Return
  ) -> Function.Return.Attribute {
    let a = Function.Return.Attribute(n, in: &self)
    addAttribute(a, to: r)
    return a
  }

  /// Adds attribute `a` to `p`.
  public mutating func addAttribute(_ a: Parameter.Attribute, to p: Parameter) {
    let i = UInt32(p.index + 1)
    LLVMAddAttributeAtIndex(p.parent.llvm, i, a.llvm)
  }

  /// Adds the attribute named `n` to `p` and returns it.
  @discardableResult
  public mutating func addAttribute(
    named n: Parameter.AttributeName, to p: Parameter
  ) -> Parameter.Attribute {
    let a = Parameter.Attribute(n, in: &self)
    addAttribute(a, to: p)
    return a
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

  /// Sets the name of `v` to `n`.
  public mutating func setName(_ n: String, for v: IRValue) {
    n.withCString({ LLVMSetValueName2(v.llvm, $0, n.utf8.count) })
  }

  /// Sets the linkage of `g` to `l`.
  public mutating func setLinkage(_ l: Linkage, for g: Global) {
    LLVMSetLinkage(g.llvm, l.llvm)
  }

  /// Configures whether `g` is a global constant.
  public mutating func setGlobalConstant(_ newValue: Bool, for g: GlobalVariable) {
    LLVMSetGlobalConstant(g.llvm, newValue ? 1 : 0)
  }

  /// Configures whether `g` is externally initialized.
  public mutating func setExternallyInitialized(_ newValue: Bool, for g: GlobalVariable) {
    LLVMSetExternallyInitialized(g.llvm, newValue ? 1 : 0)
  }

  /// Sets the initializer of `g` to `v`.
  public mutating func setInitializer(_ newValue: IRValue?, for g: GlobalVariable) {
    LLVMSetInitializer(g.llvm, newValue?.llvm)
  }

  /// Sets the preferred alignment of `v` to `a`.
  ///
  /// - Requires: `a` is whole power of 2.
  public mutating func setAlignment(_ a: Int, for v: Alloca) {
    LLVMSetAlignment(v.llvm, UInt32(a))
  }

  // MARK: Basic type instances

  /// The `void` type.
  public private(set) lazy var void: VoidType = .init(in: &self)

  /// The `ptr` type in the default address space.
  public private(set) lazy var ptr: PointerType = .init(inAddressSpace: .default, in: &self)

  /// The `half` type.
  public private(set) lazy var half: FloatingPointType = .half(in: &self)

  /// The `float` type.
  public private(set) lazy var float: FloatingPointType = .float(in: &self)

  /// The `double` type.
  public private(set) lazy var double: FloatingPointType = .double(in: &self)

  /// The `fp128` type.
  public private(set) lazy var fp128: FloatingPointType = .fp128(in: &self)

  /// The 1-bit integer type.
  public private(set) lazy var i1: IntegerType = .init(LLVMInt1TypeInContext(context))

  /// The 8-bit integer type.
  public private(set) lazy var i8: IntegerType = .init(LLVMInt8TypeInContext(context))

  /// The 16-bit integer type.
  public private(set) lazy var i16: IntegerType = .init(LLVMInt16TypeInContext(context))

  /// The 32-bit integer type.
  public private(set) lazy var i32: IntegerType = .init(LLVMInt32TypeInContext(context))

  /// The 64-bit integer type.
  public private(set) lazy var i64: IntegerType = .init(LLVMInt64TypeInContext(context))

  /// The 128-bit integer type.
  public private(set) lazy var i128: IntegerType = .init(LLVMInt128TypeInContext(context))

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

  public mutating func insertUnsignedRem(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildURem(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertSignedRem(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildSRem(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertFRem(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFRem(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertShl(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildShl(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertLShr(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildLShr(p.llvm, lhs.llvm, rhs.llvm, ""))
  }

  public mutating func insertAShr(
    _ lhs: IRValue, _ rhs: IRValue,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildAShr(p.llvm, lhs.llvm, rhs.llvm, ""))
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
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildSExt(p.llvm, source.llvm, target.llvm, ""))
  }

  public mutating func insertZeroExtend(
    _ source: IRValue, to target: IRType,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildZExt(p.llvm, source.llvm, target.llvm, ""))
  }

  public mutating func insertIntToPtr(
    _ source: IRValue, to target: IRType? = nil,
    at p: InsertionPoint
  ) -> Instruction {
    let t = target ?? PointerType(in: &self)
    return .init(LLVMBuildIntToPtr(p.llvm, source.llvm, t.llvm, ""))
  }

  public func insertPtrToInt(
    _ source: IRValue, to target: IRType,
    at p: InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildPtrToInt(p.llvm, source.llvm, target.llvm, ""))
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
