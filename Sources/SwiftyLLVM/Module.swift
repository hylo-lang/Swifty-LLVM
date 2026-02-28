internal import llvmc
internal import llvmshims

/// The top-level structure in an LLVM program.
public struct Module: ~Copyable {

  /// The context owning the contents of the LLVM module.
  let context: LLVMContextRef

  /// The LLVM module.
  let module: LLVMModuleRef

  /// Creates an instance by taking ownership of `context` and `module`.
  private init(context: LLVMContextRef, module: LLVMModuleRef) {
    self.context = context
    self.module = module
  }

  /// Dispose of the managed resources.
  deinit {
    LLVMDisposeModule(module)
    LLVMContextDispose(context)
  }

  /// Creates an instance with `name`.
  public init(_ name: String) {
    let c = LLVMContextCreate()!
    let m = LLVMModuleCreateWithNameInContext(name, c)!
    self.init(context: c, module: m)
  }

  /// A handle to the LLVM object wrapped by this instance.
  public var llvmModule: ModuleRef { .init(module) }

  /// The name of the module.
  public var name: String {
    get {
      String(from: llvmModule.raw, readingWith: LLVMGetModuleIdentifier(_:_:)) ?? ""
    }
    set {
      newValue.withCString({ LLVMSetModuleIdentifier(llvmModule.raw, $0, newValue.utf8.count) })
    }
  }

  /// The data layout of the module.
  public var layout: DataLayout {
    get {
      let s = LLVMGetDataLayoutStr(llvmModule.raw)
      let h = LLVMCreateTargetData(s)
      return .init(h!)
    }
    set {
      LLVMSetDataLayout(llvmModule.raw, newValue.description)
    }
  }

  /// The target of the module.
  public var target: Target? {
    get {
      guard let t = LLVMGetTarget(llvmModule.raw) else { return nil }
      return try? Target(triple: .init(cString: t))
    }
    set {
      LLVMSetTarget(llvmModule.raw, newValue?.triple)
    }
  }

  /// Verifies if the IR in `self` is well formed and throws an error if it isn't.
  public func verify() throws {
    var message: UnsafeMutablePointer<CChar>? = nil
    defer { LLVMDisposeMessage(message) }
    let status = withUnsafeMutablePointer(
      to: &message,
      { (m) in
        LLVMVerifyModule(llvmModule.raw, LLVMReturnStatusAction, m)
      })

    if status != 0 {
      throw LLVMError(.init(cString: message!))
    }
  }

  /// Runs standard optimization passes on `self` tuned for given `optimization` and `machine`.
  public mutating func runDefaultModulePasses(
    optimization: OptimizationLevel = .none
  ) {
    SwiftyLLVMRunDefaultModulePasses(llvmModule.raw, nil, optimization.swiftyLLVM)
  }

  public mutating func runDefaultModulePasses(
    optimization: OptimizationLevel = .none,
    for machine: borrowing TargetMachine
  ) {
    SwiftyLLVMRunDefaultModulePasses(llvmModule.raw, machine.llvm, optimization.swiftyLLVM)
  }

  /// Writes the LLVM bitcode of this module to `filepath`.
  public func writeBitcode(to filepath: String) throws {
    guard LLVMWriteBitcodeToFile(llvmModule.raw, filepath) == 0 else {
      throw LLVMError("write failure")
    }
  }

  /// Returns the LLVM bitcode of this module.
  public func bitcode() -> MemoryBuffer {
    .init(LLVMWriteBitcodeToMemoryBuffer(llvmModule.raw), owned: true)
  }

  /// Returns the string representation of this module in LL code.
  public func llCode() -> String {
    let s = LLVMPrintModuleToString(llvmModule.raw)
    defer { LLVMDisposeMessage(s) }
    return String(cString: s!)
  }

  /// Compiles this module for given `machine` and writes a result of kind `type` to `filepath`.
  public func write(
    _ type: CodeGenerationResultType,
    for machine: borrowing TargetMachine,
    to filepath: String
  ) throws {
    var error: UnsafeMutablePointer<CChar>? = nil
    LLVMTargetMachineEmitToFile(machine.llvm, llvmModule.raw, filepath, type.llvm, &error)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw LLVMError(.init(cString: e))
    }
  }

  /// Compiles this module for given `machine` and returns a result of kind `type`.
  public func compile(
    _ type: CodeGenerationResultType,
    for machine: borrowing TargetMachine
  ) throws -> MemoryBuffer {
    var output: LLVMMemoryBufferRef? = nil
    var error: UnsafeMutablePointer<CChar>? = nil
    LLVMTargetMachineEmitToMemoryBuffer(machine.llvm, llvmModule.raw, type.llvm, &error, &output)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw LLVMError(.init(cString: e))
    }

    return .init(output!, owned: true)
  }

  /// Returns the type with given `name`, or `nil` if no such type exists.
  public func type(named name: String) -> AnyType.UnsafeReference? {
    LLVMGetTypeByName2(context, name).map { AnyType.UnsafeReference($0) }
  }

  /// Returns the reference to a function with given `name`, or `nil` if no such function exists.
  public func function(named name: String) -> Function.UnsafeReference? {
    LLVMGetNamedFunction(llvmModule.raw, name).map { Function.UnsafeReference($0) }
  }

  /// Returns the global with given `name`, or `nil` if no such global exists.
  public func global(named name: String) -> GlobalVariable.UnsafeReference? {
    LLVMGetNamedGlobal(llvmModule.raw, name).map { GlobalVariable.UnsafeReference($0) }
  }

  /// Returns the intrinsic with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(
    named name: IntrinsicFunction.Name, for parameters: [AnyType.UnsafeReference] = []
  ) -> IntrinsicFunction.UnsafeReference? {
    let llvmId = name.value.withCString({ LLVMLookupIntrinsicID($0, name.value.utf8.count) })
    guard llvmId != 0 else { return nil }

    var p = parameters.map({ Optional.some($0.raw) })
    return p.withUnsafeMutableBufferPointer { buffer in
      LLVMGetIntrinsicDeclaration(self.llvmModule.raw, llvmId, buffer.baseAddress, parameters.count)
        .map { IntrinsicFunction.UnsafeReference($0) }
    }
  }

  /// Returns the intrinsic with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  ///
  /// You can call this with a tuple of typed references.
  public mutating func intrinsic<each T: IRType>(
    named name: IntrinsicFunction.Name, for parameters: (repeat UnsafeReference<each T>)
  ) -> IntrinsicFunction.UnsafeReference? {
    var erased = [AnyType.UnsafeReference]()
    for p in repeat each parameters {
      erased.append(p.erased)
    }
    return intrinsic(named: name, for: erased)
  }

  /// Creates and returns a global variable with given `name` and `type`.
  ///
  /// A unique name is generated if `name` is empty or if `self` already contains a global with
  /// the same name.
  public mutating func addGlobalVariable<T: IRType>(
    _ name: String? = nil,
    _ type: T.UnsafeReference,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable.UnsafeReference {
    guard let handle = LLVMAddGlobalInAddressSpace(llvmModule.raw, type.raw, name ?? "", s.llvm)
    else {
      fatalError("Failed to add global variable '\(name ?? "")' in address space '\(s)'.")
    }
    return GlobalVariable.UnsafeReference(handle)
  }

  /// Returns a global variable with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareGlobalVariable<T: IRType>(
    _ name: String,
    _ type: T.UnsafeReference,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable.UnsafeReference {
    if let g = global(named: name) {
      let existingType = g.pointee.valueType
      precondition(existingType == type.erased)
      return g
    } else {
      return addGlobalVariable(name, type, inAddressSpace: s)
    }
  }

  /// Returns a function with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareFunction(_ name: String, _ type: FunctionType.UnsafeReference)
    -> Function.UnsafeReference
  {
    if let existing = function(named: name) {
      let existingType = existing.pointee.valueType
      precondition(existingType == type.erased)
      return existing
    }

    return Function.UnsafeReference(LLVMAddFunction(llvmModule.raw, name, type.raw)!)
  }

  /// Creates a target-independent function attribute with given `name` and optional `value` in `module`.
  public mutating func functionAttribute(
    _ name: Function.AttributeName, _ value: UInt64 = 0
  ) -> Function.Attribute.UnsafeReference {
    .init(LLVMCreateEnumAttribute(context, name.id, value))
  }
  /// Creates a target-independent parameter attribute with given `name` and optional `value` in `module`.
  public mutating func parameterAttribute(
    _ name: Parameter.AttributeName, _ value: UInt64 = 0
  ) -> Parameter.Attribute.UnsafeReference {
    .init(LLVMCreateEnumAttribute(context, name.id, value))
  }
  /// Creates a target-independent return attribute with given `name` and optional `value` in `module`.
  public mutating func returnAttribute(
    _ name: Function.Return.AttributeName, _ value: UInt64 = 0
  ) -> Function.Return.Attribute.UnsafeReference {
    .init(LLVMCreateEnumAttribute(context, name.id, value))
  }

  /// Adds attribute `a` to `f`.
  public mutating func addFunctionAttribute(
    _ a: Function.Attribute.UnsafeReference, to f: Function.UnsafeReference
  ) {
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    LLVMAddAttributeAtIndex(f.raw, i, a.raw)
  }
  /// Adds attribute `a` to the return value of `f`.
  public mutating func addReturnAttribute(
    _ a: Function.Return.Attribute.UnsafeReference, to f: Function.UnsafeReference
  ) {
    let i = UInt32(LLVMAttributeReturnIndex)
    LLVMAddAttributeAtIndex(f.raw, i, a.raw)
  }
  /// Adds attribute `a` to parameter `p`.
  public mutating func addParameterAttribute(
    _ a: Parameter.Attribute.UnsafeReference, to p: Parameter.UnsafeReference
  ) {
    let parameter = p.pointee
    let i = UInt32(parameter.index + 1)
    LLVMAddAttributeAtIndex(parameter.parent.llvm.raw, i, a.raw)
  }

  /// Adds the attribute named `n` to function `f`, and returns it.
  @discardableResult
  public mutating func addFunctionAttribute(
    named n: Function.AttributeName, to f: Function.UnsafeReference
  ) -> Function.Attribute.UnsafeReference {
    let a = functionAttribute(n)
    addFunctionAttribute(a, to: f)
    return a
  }
  /// Adds the attribute named `n` to the return value of function `f`, and returns it.
  @discardableResult
  public mutating func addReturnAttribute(
    named n: Function.Return.AttributeName, to f: Function.UnsafeReference
  ) -> Function.Return.Attribute.UnsafeReference {
    let a = returnAttribute(n)
    addReturnAttribute(a, to: f)
    return a
  }
  /// Adds the attribute named `n` to `p`, and returns it.
  @discardableResult
  public mutating func addParameterAttribute(
    named n: Parameter.AttributeName, to p: Parameter.UnsafeReference
  ) -> Parameter.Attribute.UnsafeReference {
    let a = parameterAttribute(n)
    addParameterAttribute(a, to: p)
    return a
  }

  /// Removes `a` from `f` without destroying the attribute.
  public mutating func removeFunctionAttribute(
    _ a: Function.Attribute.UnsafeReference, from f: Function.UnsafeReference
  ) {
    let k = LLVMGetEnumAttributeKind(a.raw)
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    LLVMRemoveEnumAttributeAtIndex(f.raw, i, k)
  }

  /// Removes `attribute` from `parameter`, without destroying the attribute.
  public mutating func removeParameterAttribute(
    _ attribute: Parameter.Attribute.UnsafeReference, from parameter: Parameter.UnsafeReference
  ) {
    let k = LLVMGetEnumAttributeKind(attribute.raw)
    let p = parameter.pointee
    let i = UInt32(p.index + 1)
    LLVMRemoveEnumAttributeAtIndex(p.parent.llvm.raw, i, k)
  }

  /// Removes `attribute` from `r` without destroying the attribute.
  public mutating func removeReturnAttribute(
    _ attribute: Function.Return.Attribute.UnsafeReference, from r: Function.Return
  ) {
    let k = LLVMGetEnumAttributeKind(attribute.raw)
    LLVMRemoveEnumAttributeAtIndex(r.parent.llvm.raw, 0, k)
  }

  /// Appends a basic block named `n` to `f` and returns it.
  ///
  /// A unique name is generated if `n` is empty or if `f` already contains a block named `n`.
  @discardableResult
  public mutating func appendBlock(named n: String? = nil, to f: Function.UnsafeReference)
    -> BasicBlock.UnsafeReference
  {
    return .init(LLVMAppendBasicBlockInContext(context, f.raw, n ?? ""))
  }

  /// Returns an insertion pointing before `i`.
  public mutating func before(_ i: Instruction.UnsafeReference) -> InsertionPoint {
    let h = LLVMCreateBuilderInContext(context)!
    LLVMPositionBuilderBefore(h, i.raw)
    return InsertionPoint(sinking: h)
  }

  /// Returns an insertion point at the start of `b`.
  public mutating func startOf(_ b: BasicBlock.UnsafeReference) -> InsertionPoint {
    if let h = LLVMGetFirstInstruction(b.raw) {
      return before(Instruction.UnsafeReference(h))
    } else {
      return endOf(b)
    }
  }

  /// Returns an insertion point at the end of `b`.
  public mutating func endOf(_ b: BasicBlock.UnsafeReference) -> InsertionPoint {
    let h = LLVMCreateBuilderInContext(context)!
    LLVMPositionBuilderAtEnd(h, b.raw)
    return InsertionPoint(sinking: h)
  }

  /// Sets the name of `v` to `n`.
  public mutating func setName<V: IRValue>(_ n: String, for v: V.UnsafeReference) {
    n.withCString({ LLVMSetValueName2(v.raw, $0, n.utf8.count) })
  }

  /// Sets the linkage of `g` to `l`.
  public mutating func setLinkage<G: Global>(_ l: Linkage, for g: G.UnsafeReference) {
    LLVMSetLinkage(g.raw, l.llvm)
  }

  /// Configures whether `g` is a global constant.
  public mutating func setGlobalConstant(_ newValue: Bool, for g: GlobalVariable.UnsafeReference) {
    LLVMSetGlobalConstant(g.raw, newValue ? 1 : 0)
  }

  /// Configures whether `g` is externally initialized.
  public mutating func setExternallyInitialized(_ newValue: Bool, for g: GlobalVariable.UnsafeReference) {
    LLVMSetExternallyInitialized(g.raw, newValue ? 1 : 0)
  }

  /// Sets the initializer of `g` to `v`.
  ///
  /// - Requires: if `g` has type pointer-to-`T`, the `newValue`
  ///   must have type `T`.
  public mutating func setInitializer<V: IRValue>(
    _ newValue: V.UnsafeReference, for g: GlobalVariable.UnsafeReference
  ) {
    LLVMSetInitializer(g.raw, newValue.raw)
  }

  /// Sets the preferred alignment of `v` to `a`.
  ///
  /// - Requires: `a` is a power of two.
  public mutating func setAlignment(_ a: Int, for v: Alloca.UnsafeReference) {
    LLVMSetAlignment(v.raw, UInt32(a))
  }

  // MARK: Basic type instances

  /// The `void` type.
  public private(set) lazy var void: VoidType.UnsafeReference = voidType()

  /// The `ptr` type in the default address space.
  public private(set) lazy var ptr: PointerType.UnsafeReference = pointerType(inAddressSpace: .default)

  /// The `half` type.
  public private(set) lazy var half: FloatingPointType.UnsafeReference = FloatingPointType.half(in: &self)

  /// The `float` type.
  public private(set) lazy var float: FloatingPointType.UnsafeReference = FloatingPointType.float(
    in: &self)

  /// The `double` type.
  public private(set) lazy var double: FloatingPointType.UnsafeReference = FloatingPointType.double(
    in: &self)

  /// The `fp128` type.
  public private(set) lazy var fp128: FloatingPointType.UnsafeReference = FloatingPointType.fp128(
    in: &self)

  /// The 1-bit integer type.
  public private(set) lazy var i1: IntegerType.UnsafeReference = integerType(1)

  /// The 8-bit integer type.
  public private(set) lazy var i8: IntegerType.UnsafeReference = integerType(8)

  /// The 16-bit integer type.
  public private(set) lazy var i16: IntegerType.UnsafeReference = integerType(16)

  /// The 32-bit integer type.
  public private(set) lazy var i32: IntegerType.UnsafeReference = integerType(32)

  /// The 64-bit integer type.
  public private(set) lazy var i64: IntegerType.UnsafeReference = integerType(64)

  /// The 128-bit integer type.
  public private(set) lazy var i128: IntegerType.UnsafeReference = integerType(128)

  // MARK: Arithmetics

  public mutating func insertAdd<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    switch overflow {
    case .ignore:
      .init(LLVMBuildAdd(p.llvm, lhs.raw, rhs.raw, "")!)
    case .nuw:
      .init(LLVMBuildNUWAdd(p.llvm, lhs.raw, rhs.raw, "")!)
    case .nsw:
      .init(LLVMBuildNSWAdd(p.llvm, lhs.raw, rhs.raw, "")!)
    }
  }

  public mutating func insertFAdd<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildFAdd(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertSub<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    switch overflow {
    case .ignore:
      .init(LLVMBuildSub(p.llvm, lhs.raw, rhs.raw, "")!)
    case .nuw:
      .init(LLVMBuildNUWSub(p.llvm, lhs.raw, rhs.raw, "")!)
    case .nsw:
      .init(LLVMBuildNSWSub(p.llvm, lhs.raw, rhs.raw, "")!)
    }
  }

  public mutating func insertFSub<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildFSub(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertMul<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    switch overflow {
    case .ignore:
      .init(LLVMBuildMul(p.llvm, lhs.raw, rhs.raw, "")!)
    case .nuw:
      .init(LLVMBuildNUWMul(p.llvm, lhs.raw, rhs.raw, "")!)
    case .nsw:
      .init(LLVMBuildNSWMul(p.llvm, lhs.raw, rhs.raw, "")!)
    }
  }

  public mutating func insertFMul<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildFMul(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertUnsignedDiv<U: IRValue, V: IRValue>(
    exact: Bool = false,
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    if exact {
      .init(LLVMBuildExactUDiv(p.llvm, lhs.raw, rhs.raw, "")!)
    } else {
      .init(LLVMBuildUDiv(p.llvm, lhs.raw, rhs.raw, "")!)
    }
  }

  public mutating func insertSignedDiv<U: IRValue, V: IRValue>(
    exact: Bool = false,
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    if exact {
      .init(LLVMBuildExactSDiv(p.llvm, lhs.raw, rhs.raw, "")!)
    } else {
      .init(LLVMBuildSDiv(p.llvm, lhs.raw, rhs.raw, "")!)
    }
  }

  public mutating func insertFDiv<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildFDiv(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertUnsignedRem<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    return .init(LLVMBuildURem(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertSignedRem<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildSRem(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertFRem<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildFRem(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertShl<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildShl(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertLShr<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildLShr(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertAShr<U: IRValue, V: IRValue>(
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildAShr(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertBitwiseAnd(
    _ lhs: UnsafeReference<some IRValue>, _ rhs: UnsafeReference<some IRValue>,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildAnd(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertBitwiseOr(
    _ lhs: UnsafeReference<some IRValue>, _ rhs: UnsafeReference<some IRValue>,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildOr(p.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertBitwiseXor(
    _ lhs: UnsafeReference<some IRValue>, _ rhs: UnsafeReference<some IRValue>,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    let handle = LLVMBuildXor(p.llvm, lhs.raw, rhs.raw, "")!
    return .init(handle)
  }

  // MARK: Memory

  public mutating func insertAlloca(
    _ type: UnsafeReference<some IRType>, at p: borrowing InsertionPoint
  )
    -> Alloca.UnsafeReference
  {
    Alloca.insert(type, at: p, in: &self)
  }

  /// Returns the entry block of `f`, if any.
  public mutating func entryOf(
    _ f: Function.UnsafeReference
  ) -> BasicBlock.UnsafeReference? {
    LLVMGetFirstBasicBlock(f.raw).map { BasicBlock.UnsafeReference($0) }
  }
  /// Inserts an `alloca` that allocates stack memory for a value of `type`, at the entry of `f`.
  ///
  /// - Requires: `f` has an entry block.
  public mutating func insertAlloca<T: IRType>(_ type: T.UnsafeReference, atEntryOf f: Function.UnsafeReference)
    -> Alloca.UnsafeReference
  {
    insertAlloca(type, at: startOf(entryOf(f)!))
  }

  public mutating func insertGetElementPointer<V: IRValue, T: IRType>(
    of base: V.UnsafeReference,
    typed baseType: T.UnsafeReference,
    indices: [AnyValue.UnsafeReference],
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    var i = indices.map({ Optional.some($0.raw) })
    let handle = LLVMBuildGEP2(p.llvm, baseType.raw, base.raw, &i, UInt32(i.count), "")!
    return .init(handle)
  }

  public mutating func insertGetElementPointer<V: IRValue, T: IRType, each I: IRValue>(
    of base: V.UnsafeReference,
    typed baseType: T.UnsafeReference,
    indices: (repeat UnsafeReference<each I>),
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    var erased = [AnyValue.UnsafeReference]()
    for i in repeat each indices {
      erased.append(i.erased)
    }
    return insertGetElementPointer(of: base, typed: baseType, indices: erased, at: p)
  }

  public mutating func insertGetElementPointerInBounds<V: IRValue, T: IRType>(
    of base: V.UnsafeReference,
    typed baseType: T.UnsafeReference,
    indices: [AnyValue.UnsafeReference],
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    var i = indices.map({ Optional.some($0.raw) })
    let handle = LLVMBuildInBoundsGEP2(
      p.llvm, baseType.raw, base.raw, &i, UInt32(i.count), "")!
    return .init(handle)
  }

  public mutating func insertGetElementPointerInBounds<V: IRValue, T: IRType, each I: IRValue>(
    of base: V.UnsafeReference,
    typed baseType: T.UnsafeReference,
    indices: (repeat UnsafeReference<each I>),
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    var erased = [AnyValue.UnsafeReference]()
    for i in repeat each indices {
      erased.append(i.erased)
    }
    return insertGetElementPointerInBounds(
      of: base, typed: baseType, indices: erased, at: p)
  }

  public mutating func insertGetStructElementPointer<V: IRValue>(
    of base: V.UnsafeReference,
    typed baseType: StructType.UnsafeReference,
    index: Int,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    let handle = LLVMBuildStructGEP2(
      p.llvm, baseType.raw, base.raw, UInt32(index), "")!
    return .init(handle)
  }

  public mutating func insertLoad<T: IRType, V: IRValue>(
    _ type: T.UnsafeReference, from source: V.UnsafeReference, at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildLoad2(p.llvm, type.raw, source.raw, "")!)
  }

  @discardableResult
  public mutating func insertStore<V1: IRValue, V2: IRValue>(
    _ value: V1.UnsafeReference, to location: V2.UnsafeReference, at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    let r = LLVMBuildStore(p.llvm, value.raw, location.raw)!
    LLVMSetAlignment(
      r, UInt32(layout.preferredAlignment(of: value.with { $0.type })))
    return .init(r)
  }

  // MARK: Atomics

  public mutating func setOrdering(_ ordering: AtomicOrdering, for i: Instruction.UnsafeReference) {
    LLVMSetOrdering(i.raw, ordering.llvm)
  }

  public mutating func setCmpXchgSuccessOrdering(
    _ ordering: AtomicOrdering, for i: Instruction.UnsafeReference
  ) {
    LLVMSetCmpXchgSuccessOrdering(i.raw, ordering.llvm)
  }

  public mutating func setCmpXchgFailureOrdering(
    _ ordering: AtomicOrdering, for i: Instruction.UnsafeReference
  ) {
    LLVMSetCmpXchgFailureOrdering(i.raw, ordering.llvm)
  }

  public mutating func setAtomicRMWBinOp(_ binOp: AtomicRMWBinOp, for i: Instruction.UnsafeReference) {
    LLVMSetAtomicRMWBinOp(i.raw, binOp.llvm)
  }

  public mutating func setAtomicSingleThread(for i: Instruction.UnsafeReference) {
    LLVMSetAtomicSingleThread(i.raw, 1)
  }

  public mutating func insertAtomicCmpXchg<V1: IRValue, V2: IRValue, V3: IRValue>(
    _ atomic: V1.UnsafeReference,
    old: V2.UnsafeReference,
    new: V3.UnsafeReference,
    successOrdering: AtomicOrdering,
    failureOrdering: AtomicOrdering,
    weak: Bool,
    singleThread: Bool,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    let handle = LLVMBuildAtomicCmpXchg(
      p.llvm, atomic.raw, old.raw, new.raw,
      successOrdering.llvm,
      failureOrdering.llvm, singleThread ? 1 : 0)!
    let i = Instruction.UnsafeReference(handle)
    if weak {
      LLVMSetWeak(i.raw, 1)
    }
    return i
  }

  public mutating func insertAtomicRMW<V1: IRValue, V2: IRValue>(
    _ atomic: V1.UnsafeReference,
    operation: AtomicRMWBinOp,
    value: V2.UnsafeReference,
    ordering: AtomicOrdering,
    singleThread: Bool,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(
      LLVMBuildAtomicRMW(
        p.llvm, operation.llvm, atomic.raw, value.raw, ordering.llvm,
        singleThread ? 1 : 0
      )!)
  }

  @discardableResult
  public mutating func insertFence(
    _ ordering: AtomicOrdering, singleThread: Bool, at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildFence(p.llvm, ordering.llvm, singleThread ? 1 : 0, "")!)
  }

  // MARK: Terminators

  @discardableResult
  public mutating func insertBr(
    to destination: BasicBlock.UnsafeReference, at p: borrowing InsertionPoint
  )
    -> Instruction.UnsafeReference
  {
    .init(LLVMBuildBr(p.llvm, destination.raw)!)
  }

  @discardableResult
  public mutating func insertCondBr<V: IRValue>(
    if condition: V.UnsafeReference, then t: BasicBlock.UnsafeReference, else e: BasicBlock.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(
      LLVMBuildCondBr(
        p.llvm, condition.raw, t.raw, e.raw)!)
  }

  @discardableResult
  public mutating func insertSwitch<
    V: IRValue, C: Collection<(AnyValue.UnsafeReference, BasicBlock.UnsafeReference)>
  >(
    on value: V.UnsafeReference, cases: C, default defaultCase: BasicBlock.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    let s = LLVMBuildSwitch(
      p.llvm, value.raw, defaultCase.raw, UInt32(cases.count))!
    for (caseValue, destination) in cases {
      LLVMAddCase(s, caseValue.raw, destination.raw)
    }
    return .init(s)
  }

  @discardableResult
  public mutating func insertSwitch<
    V: IRValue, each C: IRValue
  >(
    on value: V.UnsafeReference,
    cases: (repeat (UnsafeReference<each C>, BasicBlock.UnsafeReference)),
    default defaultCase: BasicBlock.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    var erased = [(AnyValue.UnsafeReference, BasicBlock.UnsafeReference)]()
    for (caseValue, destination) in repeat each cases {
      erased.append((caseValue.erased, destination))
    }
    return insertSwitch(on: value, cases: erased, default: defaultCase, at: p)
  }

  @discardableResult
  public mutating func insertReturn(at p: borrowing InsertionPoint) -> Instruction.UnsafeReference {
    .init(LLVMBuildRetVoid(p.llvm)!)
  }

  @discardableResult
  public mutating func insertReturn<V: IRValue>(
    _ value: V.UnsafeReference, at p: borrowing InsertionPoint
  )
    -> Instruction.UnsafeReference
  {
    .init(LLVMBuildRet(p.llvm, value.raw)!)
  }

  @discardableResult
  public mutating func insertUnreachable(at p: borrowing InsertionPoint) -> Instruction.UnsafeReference {
    .init(LLVMBuildUnreachable(p.llvm)!)
  }

  // MARK: Aggregate operations

  public mutating func insertExtractValue<V: IRValue>(
    from whole: V.UnsafeReference,
    at index: Int,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildExtractValue(p.llvm, whole.raw, UInt32(index), "")!)
  }

  public mutating func insertInsertValue<V1: IRValue, V2: IRValue>(
    _ part: V1.UnsafeReference,
    at index: Int,
    into whole: V2.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildInsertValue(p.llvm, whole.raw, part.raw, UInt32(index), "")!)
  }

  // MARK: Conversions

  public mutating func insertTrunc<V: IRValue, T: IRType>(
    _ source: V.UnsafeReference, to target: T.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildTrunc(p.llvm, source.raw, target.raw, "")!)
  }

  public mutating func insertSignExtend<V: IRValue, T: IRType>(
    _ source: V.UnsafeReference, to target: T.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildSExt(p.llvm, source.raw, target.raw, "")!)
  }

  public mutating func insertZeroExtend<V: IRValue, T: IRType>(
    _ source: V.UnsafeReference, to target: T.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildZExt(p.llvm, source.raw, target.raw, "")!)
  }

  public mutating func insertIntToPtr<V: IRValue, T: IRType>(
    _ source: V.UnsafeReference, to target: T.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    return .init(LLVMBuildIntToPtr(p.llvm, source.raw, target.raw, "")!)
  }
  public mutating func insertIntToPtr<V: IRValue>(
    _ source: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    return insertIntToPtr(source, to: ptr, at: p)
  }

  public mutating func insertPtrToInt<V: IRValue, T: IRType>(
    _ source: V.UnsafeReference, to target: T.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildPtrToInt(p.llvm, source.raw, target.raw, "")!)
  }

  public mutating func insertFPTrunc<V: IRValue, T: IRType>(
    _ source: V.UnsafeReference, to target: T.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildFPTrunc(p.llvm, source.raw, target.raw, "")!)
  }

  public mutating func insertFPExtend<V: IRValue, T: IRType>(
    _ source: V.UnsafeReference, to target: T.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    .init(LLVMBuildFPExt(p.llvm, source.raw, target.raw, "")!)
  }

  // MARK: Others

  public mutating func insertCall<C: Callable>(
    _ callee: C.UnsafeReference,
    on arguments: [AnyValue.UnsafeReference],
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    let calleeTypeID = callee.pointee.valueType
    return insertCall(callee.erased, typed: calleeTypeID, on: arguments, at: p)
  }

  public mutating func insertCall<C: Callable, each A: IRValue>(
    _ callee: C.UnsafeReference,
    on arguments: (repeat UnsafeReference<each A>),
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    var erased = [AnyValue.UnsafeReference]()
    for a in repeat each arguments {
      erased.append(a.erased)
    }
    return insertCall(callee, on: erased, at: p)
  }

  public mutating func insertCall(
    _ callee: AnyValue.UnsafeReference,
    typed calleeType: AnyType.UnsafeReference,
    on arguments: [AnyValue.UnsafeReference],
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    var a = arguments.map({ $0.raw as Optional })

    // Debug: Print function type and arguments
    if let ft = FunctionType.UnsafeReference(calleeType) {
      let funcType = ft.pointee

      // Check if this is a problematic call (mismatched number of parameters when not vararg)
      if funcType.parameters.count != arguments.count && !funcType.isVarArg {
        let functionName = Function.UnsafeReference(callee.raw).pointee.name
        var debugInfo = "Parameter count mismatch on LLVM function call: \(functionName)\n"
        debugInfo += "Expected parameters: \(funcType.parameters.count)\n"
        debugInfo += "Provided arguments: \(arguments.count)\n"
        preconditionFailure(debugInfo)
      }
    }

    return .init(LLVMBuildCall2(p.llvm, calleeType.raw, callee.raw, &a, UInt32(a.count), "")!)
  }

  public mutating func insertCall<T: IRType, each A: IRValue>(
    _ callee: AnyValue.UnsafeReference,
    typed calleeType: T.UnsafeReference,
    on arguments: (repeat UnsafeReference<each A>),
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    var erased = [AnyValue.UnsafeReference]()
    for a in repeat each arguments {
      erased.append(a.erased)
    }
    return insertCall(callee, typed: calleeType.erased, on: erased, at: p)
  }

  public mutating func insertIntegerComparison<U: IRValue, V: IRValue>(
    _ predicate: IntegerPredicate,
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    precondition(lhs.pointee.type == rhs.pointee.type)
    return .init(LLVMBuildICmp(p.llvm, predicate.llvm, lhs.raw, rhs.raw, "")!)
  }

  public mutating func insertFloatingPointComparison<U: IRValue, V: IRValue>(
    _ predicate: FloatingPointPredicate,
    _ lhs: U.UnsafeReference, _ rhs: V.UnsafeReference,
    at p: borrowing InsertionPoint
  ) -> Instruction.UnsafeReference {
    precondition(lhs.pointee.type == rhs.pointee.type)
    return .init(LLVMBuildFCmp(p.llvm, predicate.llvm, lhs.raw, rhs.raw, "")!)
  }

  // MARK: Type constructors

  public mutating func integerType(_ bitWidth: Int) -> IntegerType.UnsafeReference {
    return IntegerType.create(bitWidth, in: &self)
  }

  /// Creates an opaque pointer type in the given address space.
  public mutating func pointerType(inAddressSpace s: AddressSpace = .default)
    -> PointerType.UnsafeReference
  {
    PointerType.create(inAddressSpace: s, in: &self)
  }

  /// Creates a function type with given parameter and return types.
  ///
  /// - Example: `functionType(from: [i64.erased, i8.erased], to: i8.erased)` creates the function type `(i64, i8) -> i8`.
  public mutating func functionType(from: [AnyType.UnsafeReference], to: UnsafeReference<some IRType>)
    -> FunctionType.UnsafeReference
  {
    FunctionType.create(from: from, to: to.erased, in: &self)
  }
  /// Creates a function type with given parameter and return types.
  ///
  /// - Example: `functionType(from: [i64.erased, i8.erased], to: i8.erased)` creates the function type `(i64, i8) -> i8`.
  public mutating func functionType(from: [AnyType.UnsafeReference])
    -> FunctionType.UnsafeReference
  {
    FunctionType.create(from: from, to: nil, in: &self)
  }

  /// Creates a function type with given parameter and return types.
  ///
  /// - Example: `functionType(from: (i64, i8), to: i32)` creates the function type `(i64, i8) -> i32`.
  public mutating func functionType<each T: IRType, R: IRType>(
    from parameters: (repeat UnsafeReference<each T>), to returnType: R.UnsafeReference
  ) -> FunctionType.UnsafeReference {
    var erased = [AnyType.UnsafeReference]()
    for p in repeat each parameters {
      erased.append(p.erased)
    }
    return functionType(from: erased, to: returnType.erased)
  }

  /// Creates a function type with given parameter types and void as return type.
  ///
  /// - Example: `functionType(from: (i64, i8))` creates the function type `(i64, i8) -> void`.
  public mutating func functionType<each T: IRType>(from parameters: (repeat UnsafeReference<each T>))
    -> FunctionType.UnsafeReference
  {
    var erased = [AnyType.UnsafeReference]()
    for p in repeat each parameters {
      erased.append(p.erased)
    }
    return functionType(from: erased, to: void.erased)
  }

  /// Creates an array type of `count` elements of `element`.
  public mutating func arrayType<T: IRType>(_ count: Int, _ element: T.UnsafeReference)
    -> ArrayType.UnsafeReference
  {
    ArrayType.create(count, element, in: &self)
  }

  /// Creates or retrieves the `void` type, returning a reference to it.
  public mutating func voidType() -> VoidType.UnsafeReference {
    return VoidType.create(in: &self)
  }

  /// Creates a struct type with given field types.
  public mutating func structType(_ fields: [AnyType.UnsafeReference], packed: Bool = false)
    -> StructType.UnsafeReference
  {
    StructType.create(fields, packed: packed, in: &self)
  }

  /// Creates a struct type with given field types.
  ///
  /// Callable with a tuple of typed references: `structType((i64, i8, float))`.
  public mutating func structType<each T: IRType>(_ fields: (repeat UnsafeReference<each T>), packed: Bool = false)
    -> StructType.UnsafeReference
  {
    var erased = [AnyType.UnsafeReference]()
    for f in repeat each fields {
      erased.append(f.erased)
    }
    return structType(erased, packed: packed)
  }

  /// Creates a named struct type with given field types.
  public mutating func structType(
    named name: String, _ fields: [AnyType.UnsafeReference], packed: Bool = false
  )
    -> StructType.UnsafeReference
  {
    StructType.create(named: name, fields, packed: packed, in: &self)
  }

  /// Creates a named struct type with given field types.
  ///
  /// Callable with a tuple of typed references: `structType(named: "S", (i64, i8, float))`.
  public mutating func structType<each T: IRType>(
    named name: String, _ fields: (repeat UnsafeReference<each T>), packed: Bool = false
  ) -> StructType.UnsafeReference {
    var erased = [AnyType.UnsafeReference]()
    for f in repeat each fields {
      erased.append(f.erased)
    }
    return structType(named: name, erased, packed: packed)
  }

  

  /// Creates an instruction representing an undefined value of type `type`.
  public mutating func undefinedValue<T: IRType>(of type: T.UnsafeReference) -> Undefined.UnsafeReference {
    Undefined.create(of: type, in: &self)
  }

  /// Creates an instruction representing a poison value of type `type`.
  public mutating func poisonValue<T: IRType>(of type: T.UnsafeReference) -> Poison.UnsafeReference {
    return Poison.create(of: type, in: &self)
  }

  /// Creates a constant struct of `type` in `module` aggregating `elements`.
  ///
  /// - Requires: The type of `elements[i]` is the same as the `i`-th field type of `type`.
  public mutating func structConstant<S: Sequence>(
    of type: StructType.UnsafeReference, aggregating elements: S
  ) -> StructConstant.UnsafeReference where S.Element == AnyValue.UnsafeReference {
    StructConstant.create(of: type, aggregating: elements, in: &self)
  }

  /// Creates a constant struct of `type` in `module` aggregating `elements`.
  public mutating func structConstant<each T: IRValue>(
    of type: StructType.UnsafeReference, aggregating elements: (repeat UnsafeReference<each T>)
  ) -> StructConstant.UnsafeReference {
    var erased = [AnyValue.UnsafeReference]()
    for e in repeat each elements {
      erased.append(e.erased)
    }
    return structConstant(of: type, aggregating: erased)
  }

  /// Creates a constant struct in `module` aggregating `elements`, packing them if
  /// `isPacked` is `true`.
  public mutating func structConstant<S: Sequence>(
    aggregating elements: S, packed isPacked: Bool = false
  ) -> StructConstant.UnsafeReference where S.Element == AnyValue.UnsafeReference {
    StructConstant.create(aggregating: elements, packed: isPacked, in: &self)
  }

  /// Creates a constant struct in `module` aggregating `elements`, packing them if
  /// `isPacked` is `true`.
  public mutating func structConstant<each T: IRValue>(
    aggregating elements: (repeat UnsafeReference<each T>), packed isPacked: Bool = false
  ) -> StructConstant.UnsafeReference {
    var erased = [AnyValue.UnsafeReference]()
    for e in repeat each elements {
      erased.append(e.erased)
    }
    return structConstant(aggregating: erased, packed: isPacked)
  }

  /// Creates a constant array of `type`, filled with the contents of `elements`.
  ///
  /// - Requires: The type of each value in `elements` is `type`.
  public mutating func arrayConstant<T: IRType, S: Sequence>(
    of type: T.UnsafeReference, containing elements: S
  ) -> ArrayConstant.UnsafeReference where S.Element == AnyValue.UnsafeReference {
    ArrayConstant.create(of: type, containing: elements, in: &self)
  }

  /// Creates a constant array of `type`, filled with the contents of `elements`.
  public mutating func arrayConstant<T: IRType, each U: IRValue>(
    of type: T.UnsafeReference, containing elements: (repeat UnsafeReference<each U>)
  ) -> ArrayConstant.UnsafeReference {
    var erased = [AnyValue.UnsafeReference]()
    for e in repeat each elements {
      erased.append(e.erased)
    }
    return arrayConstant(of: type, containing: erased)
  }

  /// Creates a constant array of `i8` in `module`, filled with the contents of `bytes`.
  public mutating func arrayConstant<S: Sequence>(bytes: S) -> ArrayConstant.UnsafeReference
  where S.Element == UInt8 {
    ArrayConstant.create(bytes: bytes, in: &self)
  }

  /// Creates a string constant from `text` in `module`, appending a null terminator iff
  /// `nullTerminated` is `true`.
  public mutating func stringConstant(_ text: String, nullTerminated: Bool = true)
    -> StringConstant.UnsafeReference
  {
    StringConstant.create(text, nullTerminated: nullTerminated, in: &self)
  }

  /// The LLVM IR string representation of this module.
  public var description: String { llCode() }
}
