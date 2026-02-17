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

extension LLVMIdentity<AnyType> {
  public init<Ty: IRType>(_ id: Ty.ID) {
    self.init(uncheckedFrom: id.raw)
  }
}
extension LLVMIdentity where T: IRType {
  public init(_ id: AnyType.ID) {
    self.init(uncheckedFrom: id.raw)
  }
}

extension LLVMIdentity<AnyValue> {
  public init<V: IRValue>(_ id: V.ID) {
    self.init(uncheckedFrom: id.raw)
  }
}
extension LLVMIdentity where T: IRValue {
  public init(_ id: AnyValue.ID) {
    self.init(uncheckedFrom: id.raw)
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

  /// Basic blocks of a function.
  ///
  /// Basic blocks are owned by their parent functions.
  /// Currently, functions cannot be removed without invalidating all existing IDs.
  public var basicBlocks = BidirectionalEntityStore<BasicBlock>()

  // /// Instructions of within basic blocks.
  // ///
  // /// Instructions are owned by their parent basic blocks. When removing a block, all
  // /// of its instructions are removed by LLVM, so we must also remove them from the store.
  // var instructions = BidirectionalEntityStore<Instruction>()

  public var types = BidirectionalEntityStore<AnyType>()
  public var values = BidirectionalEntityStore<AnyValue>()
  public var attributes = BidirectionalEntityStore<AnyAttribute>()

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
  public func type(named name: String) -> AnyType.ID? {
    LLVMGetTypeByName2(context, name).map { types.id(for: TypeRef($0))! }
  }

  /// Returns the reference to a function with given `name`, or `nil` if no such function exists.
  public func function(named name: String) -> Function.ID? {
    guard let f = LLVMGetNamedFunction(llvmModule.raw, name) else { return nil }

    return Function.ID(values.id(for: ValueRef(f))!)
  }

  /// Returns a the global with given `name`, or `nil` if no such global exists.
  public func global(named name: String) -> GlobalVariable.ID? {
    guard let ref = LLVMGetNamedGlobal(llvmModule.raw, name) else { return nil }
    return GlobalVariable.ID(values.id(for: ValueRef(ref))!)
  }

  /// Returns the intrinsic function with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(named name: String, for parameters: [AnyType.ID] = []) -> Intrinsic
    .ID?
  {
    let llvmId = name.withCString({ LLVMLookupIntrinsicID($0, name.utf8.count) })
    guard llvmId != 0 else { return nil }

    var p = parameters.map({ types[$0].llvm.raw as LLVMTypeRef? })
    let intrinsic = p.withUnsafeMutableBufferPointer { buffer in
      LLVMGetIntrinsicDeclaration(self.llvmModule.raw, llvmId, buffer.baseAddress, parameters.count)
    }!
    return Intrinsic.ID(values.insertIfAbsent(ValueRef(intrinsic)))
  }

  /// Returns the intrinsic with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(
    named name: Intrinsic.Name, for parameters: [AnyType.ID] = []
  ) -> Intrinsic.ID? {
    intrinsic(named: name.value, for: parameters)
  }

  /// Returns the intrinsic with given `name`, if any, specialized for `parameters`.
  ///
  /// Works when all parameters of the same type, otherwise pass AnyType.IDs directly.
  public mutating func intrinsic<T: IRType>(
    named name: Intrinsic.Name, for parameters: [T.ID]
  ) -> Intrinsic.ID? {
    intrinsic(named: name.value, for: parameters.map(AnyType.ID.init(_:)))
  }

  /// Creates and returns a global variable with given `name` and `type`.
  ///
  /// A unique name is generated if `name` is empty or if `self` already contains a global with
  /// the same name.
  public mutating func addGlobalVariable<T: IRType>(
    _ name: String? = nil,
    _ type: T.ID,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable.ID {
    guard
      let handle = LLVMAddGlobalInAddressSpace(
        llvmModule.raw, types[type].llvm.raw, name ?? "", s.llvm)
    else {
      fatalError(
        "Failed to add global variable '\(name ?? "")' in address space '\(s)'.")
    }
    return GlobalVariable.ID(values.insert(ValueRef(handle)))
  }

  /// Returns a global variable with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareGlobalVariable<T: IRType>(
    _ name: String,
    _ type: T.ID,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable.ID {
    if let g = global(named: name) {  // todo avoid copy upon extraction. We may need switch.
      let existingType = values[g].valueType(in: &self)
      precondition(existingType == type.erased)
      return g
    } else {
      return addGlobalVariable(name, type, inAddressSpace: s)
    }
  }

  /// Returns a function with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareFunction(_ name: String, _ type: FunctionType.ID) -> Function.ID {
    if let existing = function(named: name) {
      let existingType = values[existing].valueType(in: &self)
      precondition(existingType == type.erased)
      return existing
    }

    guard let handle = LLVMAddFunction(llvmModule.raw, name, types[type].llvm.raw) else {
      fatalError("Failed to add function '\(name)'.")
    }
    let function = Function.ID(values.insert(ValueRef(handle)))
    registerFunctionParameters(function)
    return function
  }

  /// Creates a target-independent function attribute with given `name` and optional `value` in `module`.
  public mutating func createFunctionAttribute(
    _ name: Function.AttributeName, _ value: UInt64 = 0
  ) -> Function.Attribute.ID {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    return .init(attributes.insertIfAbsent(handle))
  }
  /// Creates a target-independent parameter attribute with given `name` and optional `value` in `module`.
  public mutating func createParameterAttribute(
    _ name: Parameter.AttributeName, _ value: UInt64 = 0
  ) -> Parameter.Attribute.ID {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    return .init(attributes.insertIfAbsent(handle))
  }
  /// Creates a target-independent return attribute with given `name` and optional `value` in `module`.
  public mutating func createReturnAttribute(
    _ name: Function.Return.AttributeName, _ value: UInt64 = 0
  ) -> Function.Return.Attribute.ID {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    return .init(attributes.insertIfAbsent(handle))
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
  public mutating func appendBlock(named n: String? = nil, to f: Function.ID) -> BasicBlock.ID {
    return basicBlocks.insert(
      .init(LLVMAppendBasicBlockInContext(context, values[f].llvm.raw, n ?? "")))
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
      return before(Instruction.ID(values.id(for: ValueRef(h))!))
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
  public mutating func setName<V: IRValue>(_ n: String, for v: V.ID) {
    n.withCString({ LLVMSetValueName2(values[v].llvm.raw, $0, n.utf8.count) })
  }

  /// Sets the linkage of `g` to `l`.
  public mutating func setLinkage<G: Global>(_ l: Linkage, for g: G.ID) {
    LLVMSetLinkage(values[g].llvm.raw, l.llvm)
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
  public mutating func setInitializer<V: IRValue>(_ newValue: V.ID, for g: GlobalVariable.ID) {
    LLVMSetInitializer(values[g].llvm.raw, values[newValue].llvm.raw)
  }

  /// Sets the preferred alignment of `v` to `a`.
  ///
  /// - Requires: `a` is whole power of 2.
  public mutating func setAlignment(_ a: Int, for v: Alloca) {
    LLVMSetAlignment(v.llvm.raw, UInt32(a))
  }

  // MARK: Basic type instances

  /// The `void` type.
  public private(set) lazy var void: VoidType.ID = VoidType.create(in: &self)

  /// The `ptr` type in the default address space.
  public private(set) lazy var ptr: PointerType.ID = PointerType.create(
    inAddressSpace: .default, in: &self)

  /// The `half` type.
  public private(set) lazy var half: FloatingPointType.ID = FloatingPointType.half(in: &self)

  /// The `float` type.
  public private(set) lazy var float: FloatingPointType.ID = FloatingPointType.float(in: &self)

  /// The `double` type.
  public private(set) lazy var double: FloatingPointType.ID = FloatingPointType.double(in: &self)

  /// The `fp128` type.
  public private(set) lazy var fp128: FloatingPointType.ID = FloatingPointType.fp128(in: &self)

  /// The 1-bit integer type.
  public private(set) lazy var i1: IntegerType.ID = IntegerType.create(1, in: &self)

  /// The 8-bit integer type.
  public private(set) lazy var i8: IntegerType.ID = IntegerType.create(8, in: &self)

  /// The 16-bit integer type.
  public private(set) lazy var i16: IntegerType.ID = IntegerType.create(16, in: &self)

  /// The 32-bit integer type.
  public private(set) lazy var i32: IntegerType.ID = IntegerType.create(32, in: &self)

  /// The 64-bit integer type.
  public private(set) lazy var i64: IntegerType.ID = IntegerType.create(64, in: &self)

  /// The 128-bit integer type.
  public private(set) lazy var i128: IntegerType.ID = IntegerType.create(128, in: &self)

  /// Registers the parameters of `function` in the ID system.
  ///
  /// Precondition: the `function`'s parameters are not yet registered.
  private mutating func registerFunctionParameters(_ function: Function.ID) {
    let functionHandle = values[function].llvm.raw
    let parameterCount = LLVMCountParams(functionHandle)

    for index in 0..<parameterCount {
      guard let parameterHandle = LLVMGetParam(functionHandle, index) else { continue }
      _ = values.insert(ValueRef(parameterHandle))
    }
  }

  // MARK: Arithmetics

  public mutating func insertAdd<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    switch overflow {
    case .ignore:  // todo test if this works when both operands are the same.
      let handle = LLVMBuildAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    case .nuw:
      let handle = LLVMBuildNUWAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    case .nsw:
      let handle = LLVMBuildNSWAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    }
  }

  public mutating func insertFAdd<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {  // todo test if this works when both operands are the same.
    let handle = LLVMBuildFAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertSub<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    switch overflow {
    case .ignore:
      let handle = LLVMBuildSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    case .nuw:
      let handle = LLVMBuildNUWSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    case .nsw:
      let handle = LLVMBuildNSWSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    }
  }

  public mutating func insertFSub<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildFSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertMul<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    switch overflow {
    case .ignore:
      let handle = LLVMBuildMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    case .nuw:
      let handle = LLVMBuildNUWMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    case .nsw:
      let handle = LLVMBuildNSWMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    }
  }

  public mutating func insertFMul<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildFMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertUnsignedDiv<U: IRValue, V: IRValue>(
    exact: Bool = false,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    if exact {
      let handle = LLVMBuildExactUDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    } else {
      let handle = LLVMBuildUDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    }
  }

  public mutating func insertSignedDiv<U: IRValue, V: IRValue>(
    exact: Bool = false,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    if exact {
      let handle = LLVMBuildExactSDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    } else {
      let handle = LLVMBuildSDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    }
  }

  public mutating func insertFDiv<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildFDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertUnsignedRem<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildURem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertSignedRem<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildSRem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertFRem<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildFRem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertShl<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildShl(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertLShr<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildLShr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertAShr<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildAShr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertBitwiseAnd<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildAnd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertBitwiseOr<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildOr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertBitwiseXor<U: IRValue, V: IRValue>(
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildXor(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Memory

  public mutating func insertAlloca<T: IRType>(_ type: T.ID, at p: borrowing InsertionPoint)
    -> Alloca
  {
    let handle = LLVMBuildAlloca(p.llvm, types[type].llvm.raw, "")!
    let id = Instruction.ID(values.insert(ValueRef(handle)))
    return .init(wrappingTemporarily: values[id].llvm)
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

  public mutating func insertGetElementPointer<V: IRValue, T: IRType>(
    of base: V.ID,
    typed baseType: T.ID,
    indices: [AnyValue.ID],
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    var i = indices.map({ values[$0].llvm.raw as Optional })
    let handle = LLVMBuildGEP2(
      p.llvm, types[baseType].llvm.raw, values[base].llvm.raw, &i, UInt32(i.count), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertGetElementPointerInBounds<V: IRValue, T: IRType>(
    of base: V.ID,
    typed baseType: T.ID,
    indices: [AnyValue.ID],
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    var i = indices.map({ values[$0].llvm.raw as Optional })
    let handle = LLVMBuildInBoundsGEP2(
      p.llvm, types[baseType].llvm.raw, values[base].llvm.raw, &i, UInt32(i.count), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertGetStructElementPointer<V: IRValue>(
    of base: V.ID,
    typed baseType: StructType.ID,
    index: Int,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildStructGEP2(
      p.llvm, types[baseType].llvm.raw, values[base].llvm.raw, UInt32(index), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertLoad<T: IRType, V: IRValue>(
    _ type: T.ID, from source: V.ID, at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    .init(
      values.insert(
        ValueRef(LLVMBuildLoad2(p.llvm, types[type].llvm.raw, values[source].llvm.raw, ""))))
  }

  @discardableResult
  public mutating func insertStore<V1: IRValue, V2: IRValue>(
    _ value: V1.ID, to location: V2.ID, at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let r = LLVMBuildStore(p.llvm, values[value].llvm.raw, values[location].llvm.raw)!
    LLVMSetAlignment(r, UInt32(layout.preferredAlignment(of: values[value].type)))
    return .init(values.insert(ValueRef(r)))
  }

  // MARK: Atomics

  public mutating func setOrdering(_ ordering: AtomicOrdering, for i: Instruction.ID) {
    LLVMSetOrdering(values[i].llvm.raw, ordering.llvm)
  }

  public mutating func setCmpXchgSuccessOrdering(_ ordering: AtomicOrdering, for i: Instruction.ID)
  {
    LLVMSetCmpXchgSuccessOrdering(values[i].llvm.raw, ordering.llvm)
  }

  public mutating func setCmpXchgFailureOrdering(_ ordering: AtomicOrdering, for i: Instruction.ID)
  {
    LLVMSetCmpXchgFailureOrdering(values[i].llvm.raw, ordering.llvm)
  }

  public mutating func setAtomicRMWBinOp(_ binOp: AtomicRMWBinOp, for i: Instruction.ID) {
    LLVMSetAtomicRMWBinOp(values[i].llvm.raw, binOp.llvm)
  }

  public mutating func setAtomicSingleThread(for i: Instruction.ID) {
    LLVMSetAtomicSingleThread(values[i].llvm.raw, 1)
  }

  public mutating func insertAtomicCmpXchg<V1: IRValue, V2: IRValue, V3: IRValue>(
    _ atomic: V1.ID,
    old: V2.ID,
    new: V3.ID,
    successOrdering: AtomicOrdering,
    failureOrdering: AtomicOrdering,
    weak: Bool,
    singleThread: Bool,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildAtomicCmpXchg(
      p.llvm, values[atomic].llvm.raw, values[old].llvm.raw, values[new].llvm.raw,
      successOrdering.llvm,
      failureOrdering.llvm, singleThread ? 1 : 0)!
    let i = Instruction.ID(values.insert(ValueRef(handle)))
    if weak {
      LLVMSetWeak(values[i].llvm.raw, 1)
    }
    return i
  }

  public mutating func insertAtomicRMW<V1: IRValue, V2: IRValue>(
    _ atomic: V1.ID,
    operation: AtomicRMWBinOp,
    value: V2.ID,
    ordering: AtomicOrdering,
    singleThread: Bool,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildAtomicRMW(
      p.llvm, operation.llvm, values[atomic].llvm.raw, values[value].llvm.raw, ordering.llvm,
      singleThread ? 1 : 0
    )!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertFence(
    _ ordering: AtomicOrdering, singleThread: Bool, at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildFence(p.llvm, ordering.llvm, singleThread ? 1 : 0, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Terminators

  @discardableResult
  public mutating func insertBr(to destination: BasicBlock.ID, at p: borrowing InsertionPoint)
    -> Instruction.ID
  {
    let handle = LLVMBuildBr(p.llvm, basicBlocks[destination].llvm.raw)!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertCondBr<V: IRValue>(
    if condition: V.ID, then t: BasicBlock.ID, else e: BasicBlock.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildCondBr(
      p.llvm, values[condition].llvm.raw, basicBlocks[t].llvm.raw, basicBlocks[e].llvm.raw)!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertSwitch<V: IRValue, C: Collection<(AnyValue.ID, BasicBlock.ID)>>(
    on value: V.ID, cases: C, default defaultCase: BasicBlock.ID, at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let s = LLVMBuildSwitch(
      p.llvm, values[value].llvm.raw, basicBlocks[defaultCase].llvm.raw, UInt32(cases.count))!
    for (caseValue, destination) in cases {
      LLVMAddCase(s, values[caseValue].llvm.raw, basicBlocks[destination].llvm.raw)
    }
    return .init(values.insert(ValueRef(s)))
  }

  @discardableResult
  public mutating func insertReturn(at p: borrowing InsertionPoint) -> Instruction.ID {
    let handle = LLVMBuildRetVoid(p.llvm)!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertReturn<V: IRValue>(_ value: V.ID, at p: borrowing InsertionPoint)
    -> Instruction.ID
  {
    let handle = LLVMBuildRet(p.llvm, values[value].llvm.raw)!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertUnreachable(at p: borrowing InsertionPoint) -> Instruction.ID {
    let handle = LLVMBuildUnreachable(p.llvm)!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Aggregate operations

  public mutating func insertExtractValue<V: IRValue>(
    from whole: V.ID,
    at index: Int,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildExtractValue(p.llvm, values[whole].llvm.raw, UInt32(index), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertInsertValue<V1: IRValue, V2: IRValue>(
    _ part: V1.ID,
    at index: Int,
    into whole: V2.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildInsertValue(
      p.llvm, values[whole].llvm.raw, values[part].llvm.raw, UInt32(index), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Conversions

  public mutating func insertTrunc<V: IRValue, T: IRType>(
    _ source: V.ID, to target: T.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildTrunc(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertSignExtend<V: IRValue, T: IRType>(
    _ source: V.ID, to target: T.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildSExt(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertZeroExtend<V: IRValue, T: IRType>(
    _ source: V.ID, to target: T.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildZExt(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertIntToPtr<V: IRValue>(
    _ source: V.ID, to target: AnyType.ID? = nil,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let typeHandle =
      if let t = target {
        types[t].llvm.raw
      } else {
        types[ptr].llvm.raw
      }
    let handle = LLVMBuildIntToPtr(p.llvm, values[source].llvm.raw, typeHandle, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertPtrToInt<V: IRValue, T: IRType>(
    _ source: V.ID, to target: T.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildPtrToInt(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertFPTrunc<V: IRValue, T: IRType>(
    _ source: V.ID, to target: T.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildFPTrunc(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertFPExtend<V: IRValue, T: IRType>(
    _ source: V.ID, to target: T.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let handle = LLVMBuildFPExt(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Others

  public mutating func insertCall<C: Callable>(
    _ callee: C.ID,
    on arguments: [AnyValue.ID],
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    let calleeTypeID = values[callee].valueType(in: &self)
    return insertCall(callee.erased, typed: calleeTypeID, on: arguments, at: p)
  }

  public mutating func insertCall<T: IRType>(
    _ callee: AnyValue.ID,
    typed calleeType: T.ID,
    on arguments: [AnyValue.ID],
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    var a = arguments.map({ values[$0].llvm.raw as Optional })

    // Debug: Print function type and arguments
    let calleeTypeWrapper = types[calleeType]
    if let funcType = FunctionType(calleeTypeWrapper) {
      // Check if this is a problematic call (mismatched number of parameters when not vararg)
      if funcType.parameters.count != arguments.count && !funcType.isVarArg {
        let functionName = values[Function.ID(callee)].name
        var debugInfo = "Parameter count mismatch on LLVM function call: \(functionName)\n"
        debugInfo += "Expected parameters: \(funcType.parameters.count)\n"
        debugInfo += "Provided arguments: \(arguments.count)\n"
        preconditionFailure(debugInfo)
      }
    }

    let h = LLVMBuildCall2(
      p.llvm, types[calleeType].llvm.raw, values[callee].llvm.raw, &a, UInt32(a.count), "")!
    return .init(values.insert(ValueRef(h)))
  }

  public mutating func insertIntegerComparison<U: IRValue, V: IRValue>(
    _ predicate: IntegerPredicate,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    precondition(values[lhs].type == values[rhs].type)
    let handle = LLVMBuildICmp(
      p.llvm, predicate.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertFloatingPointComparison<U: IRValue, V: IRValue>(
    _ predicate: FloatingPointPredicate,
    _ lhs: U.ID, _ rhs: V.ID,
    at p: borrowing InsertionPoint
  ) -> Instruction.ID {
    precondition(values[lhs].type == values[rhs].type)
    let handle = LLVMBuildFCmp(
      p.llvm, predicate.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

}

extension Module: NCCustomStringConvertible {

  public var description: String {
    guard let s = LLVMPrintModuleToString(llvmModule.raw) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return String(cString: s)
  }

}
