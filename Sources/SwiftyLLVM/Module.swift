internal import llvmc
internal import llvmshims

public struct AnyAttribute: LLVMEntity {
  public init(wrappingTemporarily handle: AttributeRef) {
    precondition(LLVMIsEnumAttribute(handle.raw) != 0)
    self.llvm = handle
  }

  public typealias Handle = AttributeRef

  /// Exposes a view of `self` as an attribute of the given holder.
  public func assuming<T: AttributeHolder>(_: T.Type) -> Attribute<T> {
    return .targetIndependent(llvm: llvm)
  }

  /// A handle to the LLVM object wrapped by this instance.
  let llvm: AttributeRef
}

extension BidirectionalEntityStore where Entity == AnyType {
  public func id<T: IRType>(for type: T) -> T.ID? {
    return id(for: type.llvm).map { id in T.ID(uncheckedFrom: id.raw) }
  }

  public subscript<T: IRType>(_ id: T.ID) -> T where T.Handle == AnyType.Handle {
    mutating _read {
      let handle = unsafeExtract(id.erased)
      defer { unsafeRestore(id.erased, handle) }

      yield T(wrappingTemporarily: handle)
    }
    _modify {
      let handle = unsafeExtract(id.erased)
      defer { unsafeRestore(id.erased, handle) }

      var v = T(wrappingTemporarily: handle)
      yield &v
    }
  }
}

extension BidirectionalEntityStore where Entity == AnyValue {
  func id<T: IRValue>(for value: T) -> T.ID? {
    return id(for: value.llvm).map { id in T.ID(uncheckedFrom: id.raw) }
  }

  public subscript<T: IRValue>(_ id: T.ID) -> T where T.Handle == AnyValue.Handle {
    mutating _read {
      let handle = unsafeExtract(id.erased)
      defer { unsafeRestore(id.erased, handle) }

      yield T(wrappingTemporarily: handle)
    }
    _modify {
      let handle = unsafeExtract(id.erased)
      defer { unsafeRestore(id.erased, handle) }

      var v = T(wrappingTemporarily: handle)
      yield &v
    }
  }
}

extension LLVMIdentity<Attribute<Function>> {
  public init(_ id: AnyAttribute.ID) {
    self.init(uncheckedFrom: id.raw)
  }
}
extension LLVMIdentity<Attribute<Parameter>> {
  public init(_ id: AnyAttribute.ID) {
    self.init(uncheckedFrom: id.raw)
  }
}
extension LLVMIdentity<Attribute<Function.Return>> {
  public init(_ id: AnyAttribute.ID) {
    self.init(uncheckedFrom: id.raw)
  }
}

extension LLVMIdentity<AnyAttribute> {
  public init<Holder: AttributeHolder>(_ id: Attribute<Holder>.ID) {
    self.init(uncheckedFrom: id.raw)
  }
}

extension BidirectionalEntityStore where Entity == AnyAttribute {
  func id<T: AttributeHolder>(for value: Attribute<T>) -> Attribute<T>.ID? {
    id(for: value.llvm).map { id in Attribute<T>.ID(uncheckedFrom: id.raw) }
  }

  public subscript<T: AttributeHolder>(_ id: Attribute<T>.ID) -> Attribute<T> {
    mutating _read {
      let handle = unsafeExtract(AnyAttribute.ID(id))
      defer { unsafeRestore(AnyAttribute.ID(id), handle) }

      yield Attribute<T>(wrappingTemporarily: handle)
    }
    _modify {
      let handle = unsafeExtract(AnyAttribute.ID(id))
      defer { unsafeRestore(AnyAttribute.ID(id), handle) }

      var v = Attribute<T>(wrappingTemporarily: handle)
      yield &v
    }
  }
}

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

  // /// Functions in the module.
  // var functions = BidirectionalEntityStore<Function>()

  // /// Global variables in the module.
  // var globals = BidirectionalEntityStore<GlobalVariable>()

  // /// Attributes on functions/parameters/return values.
  // ///
  // /// Attributes are uniqued and stored in the context.
  // var attributes = BidirectionalEntityStore<AnyAttribute>()

  /// Basic blocks of a function.
  ///
  /// Basic blocks are owned by their parent functions. When removing a function, all
  /// of its blocks are removed by LLVM, so we must also remove them from the store.
  var basicBlocks = BidirectionalEntityStore<BasicBlock>()

  // /// Instructions of within basic blocks.
  // ///
  // /// Instructions are owned by their parent basic blocks. When removing a block, all
  // /// of its instructions are removed by LLVM, so we must also remove them from the store.
  // var instructions = BidirectionalEntityStore<Instruction>()

  var types = BidirectionalEntityStore<AnyType>()
  var values = BidirectionalEntityStore<AnyValue>()
  var attributes = BidirectionalEntityStore<AnyAttribute>()

  /// Creates an instance with given `name`.
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
    optimization: OptimizationLevel = .none,
    for machine: borrowing TargetMachine? = nil
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

    // https://forums.swift.org/t/how-can-i-borrow-with-conditional-binding/78759
    switch machine {
    case .some(let m):
      SwiftyLLVMRunDefaultModulePasses(llvmModule.raw, m.llvm, o)
    case .none:
      SwiftyLLVMRunDefaultModulePasses(llvmModule.raw, nil, o)
      break
    }
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
  public func type(named name: String) -> (any IRType)? {
    LLVMGetTypeByName2(context, name).map(AnyType.init(_:))
  }

  public func functionId(for f: ValueRef) -> Function.ID? {
    values.id(for: f).map { id in Function.ID(uncheckedFrom: id.raw) }
  }

  public func globalVariableId(for g: ValueRef) -> GlobalVariable.ID? {
    values.id(for: g).map { id in GlobalVariable.ID(uncheckedFrom: id.raw) }
  }

  /// Returns the reference to a function with given `name`, or `nil` if no such function exists.
  public func function(named name: String) -> Function.ID? {
    guard let f = LLVMGetNamedFunction(llvmModule.raw, name) else { return nil }

    return functionId(for: ValueRef(f))
  }

  /// Returns a the global with given `name`, or `nil` if no such global exists.
  public func global(named name: String) -> GlobalVariable.ID? {
    guard let ref = LLVMGetNamedGlobal(llvmModule.raw, name) else { return nil }
    return globalVariableId(for: ValueRef(ref))
  }

  /// Returns the intrinsic function with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(named name: String, for parameters: [any IRType] = []) -> Function
    .ID?
  {
    let llvmId = name.withCString({ LLVMLookupIntrinsicID($0, name.utf8.count) })
    guard llvmId != 0 else { return nil }

    let intrinsic = parameters.withHandles { (p) in
      LLVMGetIntrinsicDeclaration(self.llvmModule.raw, llvmId, p.baseAddress, parameters.count)
    }!
    return functionId(for: ValueRef(intrinsic))
  }

  /// Returns the intrinsic with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(
    named name: Intrinsic.Name, for parameters: [any IRType] = []
  ) -> Function.ID? {
    intrinsic(named: name.value, for: parameters)
  }

  /// Creates and returns a global variable with given `name` and `type`.
  ///
  /// A unique name is generated if `name` is empty or if `self` already contains a global with
  /// the same name.
  public mutating func addGlobalVariable(
    _ name: String? = nil,
    _ type: any IRType,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable.ID {
    guard
      let handle = LLVMAddGlobalInAddressSpace(llvmModule.raw, type.llvm.raw, name ?? "", s.llvm)
    else {
      fatalError(
        "Failed to add global variable '\(name ?? "")' of type '\(type)' in address space '\(s)'.")
    }
    return GlobalVariable.ID(uncheckedFrom: values.insert(ValueRef(handle)).raw)
  }

  /// Returns a global variable with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareGlobalVariable(
    _ name: String,
    _ type: any IRType,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable.ID {
    if let g = global(named: name) {  // todo avoid copy upon extraction. We may need switch.
      precondition(values[g].valueType == type)
      return g
    } else {
      return addGlobalVariable(name, type, inAddressSpace: s)
    }
  }

  /// Returns a function with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareFunction(_ name: String, _ type: FunctionType) -> Function.ID {
    if let existing = function(named: name) {
      precondition(values[existing].valueType == type)
      return existing
    }

    guard let handle = LLVMAddFunction(llvmModule.raw, name, type.llvm.raw) else {
      fatalError("Failed to add function '\(name)' of type '\(type)'.")
    }
    return Function.ID(uncheckedFrom: values.insert(ValueRef(handle)).raw)
  }

  /// Creates a target-independent function attribute with given `name` and optional `value` in `module`.
  public mutating func createFunctionAttribute(
    _ name: Function.AttributeName, _ value: UInt64 = 0
  ) -> Function.Attribute.ID {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    if let existing = attributes.id(for: handle) {
      return Function.Attribute.ID(uncheckedFrom: existing.raw)
    }
    return Function.Attribute.ID(uncheckedFrom: attributes.insert(handle).raw)
  }
  /// Creates a target-independent parameter attribute with given `name` and optional `value` in `module`.
  public mutating func createParameterAttribute(
    _ name: Parameter.AttributeName, _ value: UInt64 = 0
  ) -> Parameter.Attribute.ID {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    if let existing = attributes.id(for: handle) {
      return .init(existing)
    }
    return .init(attributes.insert(handle))
  }
  /// Creates a target-independent return attribute with given `name` and optional `value` in `module`.
  public mutating func createReturnAttribute(
    _ name: Function.Return.AttributeName, _ value: UInt64 = 0
  ) -> Function.Return.Attribute.ID {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    if let existing = attributes.id(for: handle) {
      return .init(existing)
    }
    return .init(attributes.insert(handle))
  }

  /// Adds attribute `a` to `f`.
  public mutating func addFunctionAttribute(_ a: Function.Attribute.ID, to f: Function.ID) {
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    LLVMAddAttributeAtIndex(values[f].llvm.raw, i, attributes[a].llvm.raw)
  }

  /// Adds attribute `a` to the return value of `f`.
  public mutating func addReturnAttribute(_ a: Function.Return.Attribute.ID, to r: Function.ID) {
    let i = UInt32(LLVMAttributeReturnIndex)
    LLVMAddAttributeAtIndex(values[r].llvm.raw, i, attributes[a].llvm.raw)
  }

  /// Adds attribute `a` to `p`.
  public mutating func addParameterAttribute(_ a: Parameter.Attribute.ID, to p: Parameter.ID) {
    read(values[p]) { parameter in
      let i = UInt32(parameter.index + 1)
      LLVMAddAttributeAtIndex(parameter.parent.llvm.raw, i, attributes[a].llvm.raw)
    }
  }

  /// Adds the attribute named `n` to function `f`, and returns it.
  @discardableResult
  public mutating func addFunctionAttribute(
    named n: Function.AttributeName, to f: Function.ID
  ) -> Function.Attribute.ID {
    let a = createFunctionAttribute(n)
    addFunctionAttribute(a, to: f)
    return a
  }

  /// Adds the attribute named `n` to the return value of function `f`, and returns it.
  @discardableResult
  public mutating func addReturnAttribute(
    named n: Function.Return.AttributeName, to f: Function.ID
  ) -> Function.Return.Attribute.ID {
    let a = createReturnAttribute(n)
    addReturnAttribute(a, to: f)
    return a
  }

  /// Adds the attribute named `n` to `p`, and returns it.
  @discardableResult
  public mutating func addParameterAttribute(
    named n: Parameter.AttributeName, to p: Parameter.ID
  ) -> Parameter.Attribute.ID {
    let a = createParameterAttribute(n)
    addParameterAttribute(a, to: p)
    return a
  }

  /// Removes `a` from `f` without destroying the attribute.
  public mutating func removeFunctionAttribute(_ a: Function.Attribute.ID, from f: Function.ID) {
    let k = LLVMGetEnumAttributeKind(attributes[a].llvm.raw)
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    LLVMRemoveEnumAttributeAtIndex(values[f].llvm.raw, i, k)
  }

  /// Removes `a` from `p` without destroying the attribute.
  public mutating func removeParameterAttribute(_ a: Parameter.Attribute.ID, from p: Parameter.ID) {
    let k = LLVMGetEnumAttributeKind(attributes[a].llvm.raw)
    read(values[p]) { parameter in
      let i = UInt32(parameter.index + 1)
      LLVMRemoveEnumAttributeAtIndex(parameter.parent.llvm.raw, i, k)
    }
  }

  /// Removes `a` from `r` without destroying the attribute.
  public mutating func removeReturnAttribute(
    _ a: Function.Return.Attribute.ID, from r: Function.Return
  ) {
    let k = LLVMGetEnumAttributeKind(attributes[a].llvm.raw)
    LLVMRemoveEnumAttributeAtIndex(r.parent.llvm.raw, 0, k)
  }

  /// Appends a basic block named `n` to `f` and returns it.
  ///
  /// A unique name is generated if `n` is empty or if `f` already contains a block named `n`.
  @discardableResult
  public mutating func appendBlock(named n: String? = nil, to f: Function) -> BasicBlock.ID {
    return basicBlocks.insert(.init(LLVMAppendBasicBlockInContext(context, f.llvm.raw, n ?? "")))
  }

  /// Returns an insertion pointing before `i`.
  public mutating func before(_ i: Instruction.ID) -> InsertionPoint {
    let h = LLVMCreateBuilderInContext(context)!
    LLVMPositionBuilderBefore(h, values[i].llvm.raw)
    return InsertionPoint(h)
  }

  /// Returns an insertion point at the start of `b`.
  public mutating func startOf(_ b: BasicBlock.ID) -> InsertionPoint {
    if let h = LLVMGetFirstInstruction(basicBlocks[b].llvm.raw) {
      return before(Instruction.ID(uncheckedFrom: values.id(for: ValueRef(h))!.raw))
    } else {
      return endOf(b)
    }
  }

  /// Returns an insertion point at the end of `b`.
  public mutating func endOf(_ b: BasicBlock.ID) -> InsertionPoint {
    let h = LLVMCreateBuilderInContext(context)!
    LLVMPositionBuilderAtEnd(h, basicBlocks[b].llvm.raw)
    return InsertionPoint(h)
  }

  /// Sets the name of `v` to `n`.
  public mutating func setName(_ n: String, for v: any IRValue) {
    n.withCString({ LLVMSetValueName2(v.llvm.raw, $0, n.utf8.count) })
  }

  /// Sets the linkage of `g` to `l`.
  public mutating func setLinkage(_ l: Linkage, for g: any Global) {
    LLVMSetLinkage(g.llvm.raw, l.llvm)
  }

  /// Configures whether `g` is a global constant.
  public mutating func setGlobalConstant(_ newValue: Bool, for g: GlobalVariable.ID) {
    LLVMSetGlobalConstant(values[g].llvm.raw, newValue ? 1 : 0)
  }

  /// Configures whether `g` is externally initialized.
  public mutating func setExternallyInitialized(_ newValue: Bool, for g: GlobalVariable.ID) {
    LLVMSetExternallyInitialized(values[g].llvm.raw, newValue ? 1 : 0)
  }

  /// Sets the initializer of `g` to `v`.
  ///
  /// - Precondition: if `g` has type pointer-to-`T`, the `newValue`
  ///   must have type `T`.
  public mutating func setInitializer(_ newValue: any IRValue, for g: GlobalVariable.ID) {
    LLVMSetInitializer(values[g].llvm.raw, newValue.llvm.raw)
  }

  /// Sets the preferred alignment of `v` to `a`.
  ///
  /// - Requires: `a` is whole power of 2.
  public mutating func setAlignment(_ a: Int, for v: Alloca) {
    LLVMSetAlignment(v.llvm.raw, UInt32(a))
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

  public mutating func insertAdd<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    switch overflow {
    case .ignore: // todo test if this works when both operands are the same.
      return .init(LLVMBuildAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    case .nuw:
      return .init(LLVMBuildNUWAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    case .nsw:
      return .init(LLVMBuildNSWAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    }
  }

  public mutating func insertFAdd<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction { // todo test if this works when both operands are the same.
    .init(LLVMBuildFAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertSub<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    switch overflow {
    case .ignore:
      return .init(LLVMBuildSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    case .nuw:
      return .init(LLVMBuildNUWSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    case .nsw:
      return .init(LLVMBuildNSWSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    }
  }

  public mutating func insertFSub<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertMul<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    switch overflow {
    case .ignore:
      return .init(LLVMBuildMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    case .nuw:
      return .init(LLVMBuildNUWMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    case .nsw:
      return .init(LLVMBuildNSWMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    }
  }

  public mutating func insertFMul<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertUnsignedDiv<U: IRValue, V: IRValue>(
    exact: Bool = false,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    if exact {
      return .init(LLVMBuildExactUDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    } else {
      return .init(LLVMBuildUDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    }
  }

  public mutating func insertSignedDiv<U: IRValue, V: IRValue>(
    exact: Bool = false,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    if exact {
      return .init(LLVMBuildExactSDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    } else {
      return .init(LLVMBuildSDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
    }
  }

  public mutating func insertFDiv<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertUnsignedRem<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildURem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertSignedRem<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildSRem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertFRem<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFRem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertShl<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildShl(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertLShr<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildLShr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertAShr<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildAShr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertBitwiseAnd<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildAnd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertBitwiseOr<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildOr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  public mutating func insertBitwiseXor<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildXor(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, ""))
  }

  // MARK: Memory

  public mutating func insertAlloca<T: IRType>(_ type: T.ID, at p: borrowing InsertionPoint) -> Alloca {
    .init(LLVMBuildAlloca(p.llvm, types[type].llvm.raw, ""))
  }

  /// Returns the entry block of `f`, if any.
  public mutating func entryOf(
    _ f: Function.ID
  ) -> BasicBlock.ID? {
    guard let e = values[f].entry else { return nil }
    return basicBlocks.id(for: e.llvm)!
  }
  /// Inerts an `alloca` allocating memory on the stack a value of `type`, at the entry of `f`.
  ///
  /// - Requires: `f` has an entry block.
  public mutating func insertAlloca<T: IRType>(_ type: T.ID, atEntryOf f: Function.ID) -> Alloca {
    insertAlloca(type, at: startOf(entryOf(f)!))
  }

  public mutating func insertGetElementPointer(
    of base: any IRValue,
    typed baseType: any IRType,
    indices: [any IRValue],
    at p: borrowing InsertionPoint
  ) -> Instruction {
    var i = indices.map({ $0.llvm.raw as Optional })
    let h = LLVMBuildGEP2(p.llvm, baseType.llvm.raw, base.llvm.raw, &i, UInt32(i.count), "")!
    return .init(h)
  }

  public mutating func insertGetElementPointerInBounds(
    of base: any IRValue,
    typed baseType: any IRType,
    indices: [any IRValue],
    at p: borrowing InsertionPoint
  ) -> Instruction {
    var i = indices.map({ $0.llvm.raw as Optional })
    let h = LLVMBuildInBoundsGEP2(
      p.llvm, baseType.llvm.raw, base.llvm.raw, &i, UInt32(i.count), "")!
    return .init(h)
  }

  public mutating func insertGetStructElementPointer(
    of base: any IRValue,
    typed baseType: StructType,
    index: Int,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildStructGEP2(p.llvm, baseType.llvm.raw, base.llvm.raw, UInt32(index), ""))
  }

  public mutating func insertLoad(
    _ type: any IRType, from source: any IRValue, at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildLoad2(p.llvm, type.llvm.raw, source.llvm.raw, ""))
  }

  @discardableResult
  public mutating func insertStore(
    _ value: any IRValue, to location: any IRValue, at p: borrowing InsertionPoint
  ) -> Instruction {
    let r = LLVMBuildStore(p.llvm, value.llvm.raw, location.llvm.raw)
    LLVMSetAlignment(r, UInt32(layout.preferredAlignment(of: value.type)))
    return .init(r!)
  }

  // MARK: Atomics

  public mutating func setOrdering(_ ordering: AtomicOrdering, for i: Instruction) {
    LLVMSetOrdering(i.llvm.raw, ordering.llvm)
  }

  public mutating func setCmpXchgSuccessOrdering(_ ordering: AtomicOrdering, for i: Instruction) {
    LLVMSetCmpXchgSuccessOrdering(i.llvm.raw, ordering.llvm)
  }

  public mutating func setCmpXchgFailureOrdering(_ ordering: AtomicOrdering, for i: Instruction) {
    LLVMSetCmpXchgFailureOrdering(i.llvm.raw, ordering.llvm)
  }

  public mutating func setAtomicRMWBinOp(_ binOp: AtomicRMWBinOp, for i: Instruction) {
    LLVMSetAtomicRMWBinOp(i.llvm.raw, binOp.llvm)
  }

  public mutating func setAtomicSingleThread(for i: Instruction) {
    LLVMSetAtomicSingleThread(i.llvm.raw, 1)
  }

  public mutating func insertAtomicCmpXchg(
    _ atomic: any IRValue,
    old: any IRValue,
    new: any IRValue,
    successOrdering: AtomicOrdering,
    failureOrdering: AtomicOrdering,
    weak: Bool,
    singleThread: Bool,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    let i = Instruction(
      LLVMBuildAtomicCmpXchg(
        p.llvm, atomic.llvm.raw, old.llvm.raw, new.llvm.raw, successOrdering.llvm,
        failureOrdering.llvm, singleThread ? 1 : 0))
    if weak {
      LLVMSetWeak(i.llvm.raw, 1)
    }
    return i
  }

  public mutating func insertAtomicRMW(
    _ atomic: any IRValue,
    operation: AtomicRMWBinOp,
    value: any IRValue,
    ordering: AtomicOrdering,
    singleThread: Bool,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(
      LLVMBuildAtomicRMW(
        p.llvm, operation.llvm, atomic.llvm.raw, value.llvm.raw, ordering.llvm, singleThread ? 1 : 0
      ))
  }

  @discardableResult
  public mutating func insertFence(
    _ ordering: AtomicOrdering, singleThread: Bool, at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFence(p.llvm, ordering.llvm, singleThread ? 1 : 0, ""))
  }

  // MARK: Terminators

  @discardableResult
  public mutating func insertBr(to destination: BasicBlock, at p: borrowing InsertionPoint)
    -> Instruction
  {
    .init(LLVMBuildBr(p.llvm, destination.llvm.raw))
  }

  @discardableResult
  public mutating func insertCondBr(
    if condition: any IRValue, then t: BasicBlock, else e: BasicBlock,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildCondBr(p.llvm, condition.llvm.raw, t.llvm.raw, e.llvm.raw))
  }

  @discardableResult
  public mutating func insertSwitch<C: Collection<(any IRValue, BasicBlock)>>(
    on value: any IRValue, cases: C, default defaultCase: BasicBlock, at p: borrowing InsertionPoint
  ) -> Instruction {
    let s = LLVMBuildSwitch(p.llvm, value.llvm.raw, defaultCase.llvm.raw, UInt32(cases.count))
    for (value, destination) in cases {
      LLVMAddCase(s, value.llvm.raw, destination.llvm.raw)
    }
    return .init(s!)
  }

  @discardableResult
  public mutating func insertReturn(at p: borrowing InsertionPoint) -> Instruction {
    .init(LLVMBuildRetVoid(p.llvm))
  }

  @discardableResult
  public mutating func insertReturn(_ value: any IRValue, at p: borrowing InsertionPoint)
    -> Instruction
  {
    .init(LLVMBuildRet(p.llvm, value.llvm.raw))
  }

  @discardableResult
  public mutating func insertUnreachable(at p: borrowing InsertionPoint) -> Instruction {
    .init(LLVMBuildUnreachable(p.llvm))
  }

  // MARK: Aggregate operations

  public mutating func insertExtractValue(
    from whole: any IRValue,
    at index: Int,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildExtractValue(p.llvm, whole.llvm.raw, UInt32(index), ""))
  }

  public mutating func insertInsertValue(
    _ part: any IRValue,
    at index: Int,
    into whole: any IRValue,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildInsertValue(p.llvm, whole.llvm.raw, part.llvm.raw, UInt32(index), ""))
  }

  // MARK: Conversions

  public mutating func insertTrunc(
    _ source: any IRValue, to target: any IRType,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildTrunc(p.llvm, source.llvm.raw, target.llvm.raw, ""))
  }

  public mutating func insertSignExtend(
    _ source: any IRValue, to target: any IRType,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildSExt(p.llvm, source.llvm.raw, target.llvm.raw, ""))
  }

  public mutating func insertZeroExtend(
    _ source: any IRValue, to target: any IRType,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildZExt(p.llvm, source.llvm.raw, target.llvm.raw, ""))
  }

  public mutating func insertIntToPtr(
    _ source: any IRValue, to target: (any IRType)? = nil,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    let t = target ?? PointerType(in: &self)
    return .init(LLVMBuildIntToPtr(p.llvm, source.llvm.raw, t.llvm.raw, ""))
  }

  public func insertPtrToInt(
    _ source: any IRValue, to target: any IRType,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildPtrToInt(p.llvm, source.llvm.raw, target.llvm.raw, ""))
  }

  public mutating func insertFPTrunc(
    _ source: any IRValue, to target: any IRType,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFPTrunc(p.llvm, source.llvm.raw, target.llvm.raw, ""))
  }

  public mutating func insertFPExtend(
    _ source: any IRValue, to target: any IRType,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    .init(LLVMBuildFPExt(p.llvm, source.llvm.raw, target.llvm.raw, ""))
  }

  // MARK: Others

  public mutating func insertCall(
    _ callee: Function,
    on arguments: [any IRValue],
    at p: borrowing InsertionPoint
  ) -> Instruction {
    insertCall(callee, typed: callee.valueType, on: arguments, at: p)
  }

  public mutating func insertCall(
    _ callee: any IRValue,
    typed calleeType: any IRType,
    on arguments: [any IRValue],
    at p: borrowing InsertionPoint
  ) -> Instruction {
    var a = arguments.map({ $0.llvm.raw as Optional })

    // Debug: Print function type and arguments
    if let funcType = FunctionType(calleeType) {
      // Check if this is a problematic call (mismatched number of parameters when not vararg)
      if funcType.parameters.count != arguments.count && !funcType.isVarArg {
        let functionName = Function(callee)?.name ?? "unknown"
        var debugInfo = "Parameter count mismatch on LLVM function call: \(functionName)\n"
        debugInfo += "Expected parameters: \(funcType.parameters.count)\n"
        debugInfo += "Provided arguments: \(arguments.count)\n"
        preconditionFailure(debugInfo)
      }
    }

    return .init(
      LLVMBuildCall2(p.llvm, calleeType.llvm.raw, callee.llvm.raw, &a, UInt32(a.count), ""))
  }

  public mutating func insertIntegerComparison(
    _ predicate: IntegerPredicate,
    _ lhs: any IRValue, _ rhs: any IRValue,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    precondition(lhs.type == rhs.type)
    return .init(LLVMBuildICmp(p.llvm, predicate.llvm, lhs.llvm.raw, rhs.llvm.raw, ""))
  }

  public mutating func insertFloatingPointComparison(
    _ predicate: FloatingPointPredicate,
    _ lhs: any IRValue, _ rhs: any IRValue,
    at p: borrowing InsertionPoint
  ) -> Instruction {
    precondition(lhs.type == rhs.type)
    return .init(LLVMBuildFCmp(p.llvm, predicate.llvm, lhs.llvm.raw, rhs.llvm.raw, ""))
  }

}

extension Module: NCCustomStringConvertible {

  public var description: String {
    guard let s = LLVMPrintModuleToString(llvmModule.raw) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return String(cString: s)
  }

}
