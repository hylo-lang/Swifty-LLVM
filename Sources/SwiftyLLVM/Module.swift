internal import llvmc
internal import llvmshims

public struct AnyAttribute: LLVMEntity {
  public init(temporarilyWrapping handle: AttributeRef) {
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
  public func id<T: IRType>(for type: T) -> T.Identity? {
    return id(for: type.llvm).map { id in T.Identity(uncheckedFrom: id.raw) }
  }

  public subscript<T: IRType>(_ id: T.Identity) -> T where T.Handle == AnyType.Handle {
    mutating _read {
      let handle = unsafeExtract(id.erased)
      defer { unsafeRestore(id.erased, handle) }

      yield T(temporarilyWrapping: handle)
    }
    _modify {
      let handle = unsafeExtract(id.erased)
      defer { unsafeRestore(id.erased, handle) }

      var v = T(temporarilyWrapping: handle)
      yield &v
    }
  }
}

extension BidirectionalEntityStore where Entity == AnyValue {
  func id<T: IRValue>(for value: T) -> T.Identity? {
    return id(for: value.llvm).map { id in T.Identity(uncheckedFrom: id.raw) }
  }

  public subscript<T: IRValue>(_ id: T.Identity) -> T where T.Handle == AnyValue.Handle {
    mutating _read {
      let handle = unsafeExtract(id.erased)
      defer { unsafeRestore(id.erased, handle) }

      yield T(temporarilyWrapping: handle)
    }
    _modify {
      let handle = unsafeExtract(id.erased)
      defer { unsafeRestore(id.erased, handle) }

      var v = T(temporarilyWrapping: handle)
      yield &v
    }
  }
}

extension LLVMIdentity<Attribute<Function>> {
  public init(_ id: AnyAttribute.Identity) {
    self.init(uncheckedFrom: id.raw)
  }
}
extension LLVMIdentity<Attribute<Parameter>> {
  public init(_ id: AnyAttribute.Identity) {
    self.init(uncheckedFrom: id.raw)
  }
}
extension LLVMIdentity<Attribute<Function.Return>> {
  public init(_ id: AnyAttribute.Identity) {
    self.init(uncheckedFrom: id.raw)
  }
}

extension LLVMIdentity<AnyAttribute> {
  public init<Holder: AttributeHolder>(_ id: Attribute<Holder>.Identity) {
    self.init(uncheckedFrom: id.raw)
  }
}

extension BidirectionalEntityStore where Entity == AnyAttribute {
  func id<T: AttributeHolder>(for value: Attribute<T>) -> Attribute<T>.Identity? {
    id(for: value.llvm).map { id in Attribute<T>.Identity(uncheckedFrom: id.raw) }
  }

  public subscript<T: AttributeHolder>(_ id: Attribute<T>.Identity) -> Attribute<T> {
    mutating _read {
      let handle = unsafeExtract(AnyAttribute.Identity(id))
      defer { unsafeRestore(AnyAttribute.Identity(id), handle) }

      yield Attribute<T>(temporarilyWrapping: handle)
    }
    _modify {
      let handle = unsafeExtract(AnyAttribute.Identity(id))
      defer { unsafeRestore(AnyAttribute.Identity(id), handle) }

      var v = Attribute<T>(temporarilyWrapping: handle)
      yield &v
    }
  }
}

extension LLVMIdentity<AnyType> {
  public init<Ty: IRType>(_ id: Ty.Identity) {
    self.init(uncheckedFrom: id.raw)
  }
}
extension LLVMIdentity where T: IRType {
  public init(_ id: AnyType.Identity) {
    self.init(uncheckedFrom: id.raw)
  }
}

extension LLVMIdentity<AnyValue> {
  public init<V: IRValue>(_ id: V.Identity) {
    self.init(uncheckedFrom: id.raw)
  }
}
extension LLVMIdentity where T: IRValue {
  public init(_ id: AnyValue.Identity) {
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
  public func type(named name: String) -> AnyType.Identity? {
    LLVMGetTypeByName2(context, name).map { types.id(for: TypeRef($0))! }
  }

  /// Returns the reference to a function with given `name`, or `nil` if no such function exists.
  public func function(named name: String) -> Function.Identity? {
    guard let f = LLVMGetNamedFunction(llvmModule.raw, name) else { return nil }

    return Function.Identity(values.id(for: ValueRef(f))!)
  }

  /// Returns a the global with given `name`, or `nil` if no such global exists.
  public func global(named name: String) -> GlobalVariable.Identity? {
    guard let ref = LLVMGetNamedGlobal(llvmModule.raw, name) else { return nil }
    return GlobalVariable.Identity(values.id(for: ValueRef(ref))!)
  }

  /// Returns the intrinsic function with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(named name: String, for parameters: [AnyType.Identity] = [])
    -> Intrinsic
    .Identity?
  {
    let llvmId = name.withCString({ LLVMLookupIntrinsicID($0, name.utf8.count) })
    guard llvmId != 0 else { return nil }

    var p = parameters.map({ types[$0].llvm.raw as LLVMTypeRef? })
    let intrinsic = p.withUnsafeMutableBufferPointer { buffer in
      LLVMGetIntrinsicDeclaration(self.llvmModule.raw, llvmId, buffer.baseAddress, parameters.count)
    }!
    return Intrinsic.Identity(values.demandId(for: ValueRef(intrinsic)))
  }

  /// Returns the intrinsic with given `name`, specialized for `parameters`, or `nil` if no such
  /// intrinsic exists.
  public mutating func intrinsic(
    named name: Intrinsic.Name, for parameters: [AnyType.Identity] = []
  ) -> Intrinsic.Identity? {
    intrinsic(named: name.value, for: parameters)
  }

  /// Returns the intrinsic with given `name`, if any, specialized for `parameters`.
  ///
  /// Works when all parameters of the same type, otherwise pass AnyType.IDs directly.
  public mutating func intrinsic<T: IRType>(
    named name: Intrinsic.Name, for parameters: [T.Identity]
  ) -> Intrinsic.Identity? {
    intrinsic(named: name.value, for: parameters.map(AnyType.Identity.init(_:)))
  }

  /// Creates and returns a global variable with given `name` and `type`.
  ///
  /// A unique name is generated if `name` is empty or if `self` already contains a global with
  /// the same name.
  public mutating func addGlobalVariable<T: IRType>(
    _ name: String? = nil,
    _ type: T.Identity,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable.Identity {
    guard
      let handle = LLVMAddGlobalInAddressSpace(
        llvmModule.raw, types[type].llvm.raw, name ?? "", s.llvm)
    else {
      fatalError(
        "Failed to add global variable '\(name ?? "")' in address space '\(s)'.")
    }
    return GlobalVariable.Identity(values.insert(ValueRef(handle)))
  }

  /// Returns a global variable with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareGlobalVariable<T: IRType>(
    _ name: String,
    _ type: T.Identity,
    inAddressSpace s: AddressSpace = .default
  ) -> GlobalVariable.Identity {
    if let g = global(named: name) {  // todo avoid copy upon extraction. We may need switch.
      let existingType = values[g].valueType(in: &self)
      precondition(existingType == type.erased)
      return g
    } else {
      return addGlobalVariable(name, type, inAddressSpace: s)
    }
  }

  /// Returns a function with given `name` and `type`, declaring it if it doesn't exist.
  public mutating func declareFunction(_ name: String, _ type: FunctionType.Identity)
    -> Function.Identity
  {
    if let existing = function(named: name) {
      let existingType = values[existing].valueType(in: &self)
      precondition(existingType == type.erased)
      return existing
    }

    guard let handle = LLVMAddFunction(llvmModule.raw, name, types[type].llvm.raw) else {
      fatalError("Failed to add function '\(name)'.")
    }
    let function = Function.Identity(values.insert(ValueRef(handle)))
    registerFunctionParameters(function)
    return function
  }

  /// Creates a target-independent function attribute with given `name` and optional `value` in `module`.
  public mutating func functionAttribute(
    _ name: Function.AttributeName, _ value: UInt64 = 0
  ) -> Function.Attribute.Identity {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    return .init(attributes.demandId(for: handle))
  }
  /// Creates a target-independent parameter attribute with given `name` and optional `value` in `module`.
  public mutating func parameterAttribute(
    _ name: Parameter.AttributeName, _ value: UInt64 = 0
  ) -> Parameter.Attribute.Identity {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    return .init(attributes.demandId(for: handle))
  }
  /// Creates a target-independent return attribute with given `name` and optional `value` in `module`.
  public mutating func returnAttribute(
    _ name: Function.Return.AttributeName, _ value: UInt64 = 0
  ) -> Function.Return.Attribute.Identity {
    let handle = AttributeRef(LLVMCreateEnumAttribute(context, name.id, value))
    return .init(attributes.demandId(for: handle))
  }

  /// Adds attribute `a` to `f`.
  public mutating func addFunctionAttribute(
    _ a: Function.Attribute.Identity, to f: Function.Identity
  ) {
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    LLVMAddAttributeAtIndex(values[f].llvm.raw, i, attributes[a].llvm.raw)
  }
  /// Adds attribute `a` to the return value of `f`.
  public mutating func addReturnAttribute(
    _ a: Function.Return.Attribute.Identity, to f: Function.Identity
  ) {
    let i = UInt32(LLVMAttributeReturnIndex)
    LLVMAddAttributeAtIndex(values[f].llvm.raw, i, attributes[a].llvm.raw)
  }
  /// Adds attribute `a` to parameter `p`.
  public mutating func addParameterAttribute(
    _ a: Parameter.Attribute.Identity, to p: Parameter.Identity
  ) {
    read(values[p]) { parameter in
      let i = UInt32(parameter.index + 1)
      LLVMAddAttributeAtIndex(parameter.parent.llvm.raw, i, attributes[a].llvm.raw)
    }
  }

  /// Adds the attribute named `n` to function `f`, and returns it.
  @discardableResult
  public mutating func addFunctionAttribute(
    named n: Function.AttributeName, to f: Function.Identity
  ) -> Function.Attribute.Identity {
    let a = functionAttribute(n)
    addFunctionAttribute(a, to: f)
    return a
  }
  /// Adds the attribute named `n` to the return value of function `f`, and returns it.
  @discardableResult
  public mutating func addReturnAttribute(
    named n: Function.Return.AttributeName, to f: Function.Identity
  ) -> Function.Return.Attribute.Identity {
    let a = returnAttribute(n)
    addReturnAttribute(a, to: f)
    return a
  }
  /// Adds the attribute named `n` to `p`, and returns it.
  @discardableResult
  public mutating func addParameterAttribute(
    named n: Parameter.AttributeName, to p: Parameter.Identity
  ) -> Parameter.Attribute.Identity {
    let a = parameterAttribute(n)
    addParameterAttribute(a, to: p)
    return a
  }

  /// Removes `a` from `f` without destroying the attribute.
  public mutating func removeFunctionAttribute(
    _ a: Function.Attribute.Identity, from f: Function.Identity
  ) {
    let k = LLVMGetEnumAttributeKind(attributes[a].llvm.raw)
    let i = UInt32(bitPattern: Int32(LLVMAttributeFunctionIndex))
    LLVMRemoveEnumAttributeAtIndex(values[f].llvm.raw, i, k)
  }

  /// Removes `a` from `p` without destroying the attribute.
  public mutating func removeParameterAttribute(
    _ a: Parameter.Attribute.Identity, from p: Parameter.Identity
  ) {
    let k = LLVMGetEnumAttributeKind(attributes[a].llvm.raw)
    read(values[p]) { parameter in
      let i = UInt32(parameter.index + 1)
      LLVMRemoveEnumAttributeAtIndex(parameter.parent.llvm.raw, i, k)
    }
  }

  /// Removes `a` from `r` without destroying the attribute.
  public mutating func removeReturnAttribute(
    _ a: Function.Return.Attribute.Identity, from r: Function.Return
  ) {
    let k = LLVMGetEnumAttributeKind(attributes[a].llvm.raw)
    LLVMRemoveEnumAttributeAtIndex(r.parent.llvm.raw, 0, k)
  }

  /// Appends a basic block named `n` to `f` and returns it.
  ///
  /// A unique name is generated if `n` is empty or if `f` already contains a block named `n`.
  @discardableResult
  public mutating func appendBlock(named n: String? = nil, to f: Function.Identity)
    -> BasicBlock.Identity
  {
    return basicBlocks.insert(
      .init(LLVMAppendBasicBlockInContext(context, values[f].llvm.raw, n ?? "")))
  }

  /// Returns an insertion pointing before `i`.
  public mutating func before(_ i: Instruction.Identity) -> InsertionPoint {
    let h = LLVMCreateBuilderInContext(context)!
    LLVMPositionBuilderBefore(h, values[i].llvm.raw)
    return InsertionPoint(h)
  }

  /// Returns an insertion point at the start of `b`.
  public mutating func startOf(_ b: BasicBlock.Identity) -> InsertionPoint {
    if let h = LLVMGetFirstInstruction(basicBlocks[b].llvm.raw) {
      return before(Instruction.Identity(values.id(for: ValueRef(h))!))
    } else {
      return endOf(b)
    }
  }

  /// Returns an insertion point at the end of `b`.
  public mutating func endOf(_ b: BasicBlock.Identity) -> InsertionPoint {
    let h = LLVMCreateBuilderInContext(context)!
    LLVMPositionBuilderAtEnd(h, basicBlocks[b].llvm.raw)
    return InsertionPoint(h)
  }

  /// Sets the name of `v` to `n`.
  public mutating func setName<V: IRValue>(_ n: String, for v: V.Identity) {
    n.withCString({ LLVMSetValueName2(values[v].llvm.raw, $0, n.utf8.count) })
  }

  /// Sets the linkage of `g` to `l`.
  public mutating func setLinkage<G: Global>(_ l: Linkage, for g: G.Identity) {
    LLVMSetLinkage(values[g].llvm.raw, l.llvm)
  }

  /// Configures whether `g` is a global constant.
  public mutating func setGlobalConstant(_ newValue: Bool, for g: GlobalVariable.Identity) {
    LLVMSetGlobalConstant(values[g].llvm.raw, newValue ? 1 : 0)
  }

  /// Configures whether `g` is externally initialized.
  public mutating func setExternallyInitialized(_ newValue: Bool, for g: GlobalVariable.Identity) {
    LLVMSetExternallyInitialized(values[g].llvm.raw, newValue ? 1 : 0)
  }

  /// Sets the initializer of `g` to `v`.
  ///
  /// - Precondition: if `g` has type pointer-to-`T`, the `newValue`
  ///   must have type `T`.
  public mutating func setInitializer<V: IRValue>(
    _ newValue: V.Identity, for g: GlobalVariable.Identity
  ) {
    LLVMSetInitializer(values[g].llvm.raw, values[newValue].llvm.raw)
  }

  /// Sets the preferred alignment of `v` to `a`.
  ///
  /// - Requires: `a` is whole power of 2.
  public mutating func setAlignment(_ a: Int, for v: Alloca.Identity) {
    LLVMSetAlignment(values[v].llvm.raw, UInt32(a))
  }

  // MARK: Basic type instances

  /// The `void` type.
  public private(set) lazy var void: VoidType.Identity = voidType()

  /// The `ptr` type in the default address space.
  public private(set) lazy var ptr: PointerType.Identity = pointerType(inAddressSpace: .default)

  /// The `half` type.
  public private(set) lazy var half: FloatingPointType.Identity = FloatingPointType.half(in: &self)

  /// The `float` type.
  public private(set) lazy var float: FloatingPointType.Identity = FloatingPointType.float(
    in: &self)

  /// The `double` type.
  public private(set) lazy var double: FloatingPointType.Identity = FloatingPointType.double(
    in: &self)

  /// The `fp128` type.
  public private(set) lazy var fp128: FloatingPointType.Identity = FloatingPointType.fp128(
    in: &self)

  /// The 1-bit integer type.
  public private(set) lazy var i1: IntegerType.Identity = integerType(1)

  /// The 8-bit integer type.
  public private(set) lazy var i8: IntegerType.Identity = integerType(8)

  /// The 16-bit integer type.
  public private(set) lazy var i16: IntegerType.Identity = integerType(16)

  /// The 32-bit integer type.
  public private(set) lazy var i32: IntegerType.Identity = integerType(32)

  /// The 64-bit integer type.
  public private(set) lazy var i64: IntegerType.Identity = integerType(64)

  /// The 128-bit integer type.
  public private(set) lazy var i128: IntegerType.Identity = integerType(128)

  /// Registers the parameters of `function` in the ID system.
  ///
  /// Precondition: the `function`'s parameters are not yet registered.
  private mutating func registerFunctionParameters(_ function: Function.Identity) {
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
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
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
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {  // todo test if this works when both operands are the same.
    let handle = LLVMBuildFAdd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertSub<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
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
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildFSub(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertMul<U: IRValue, V: IRValue>(
    overflow: OverflowBehavior = .ignore,
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
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
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildFMul(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertUnsignedDiv<U: IRValue, V: IRValue>(
    exact: Bool = false,
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
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
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    if exact {
      let handle = LLVMBuildExactSDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    } else {
      let handle = LLVMBuildSDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
      return .init(values.insert(ValueRef(handle)))
    }
  }

  public mutating func insertFDiv<U: IRValue, V: IRValue>(
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildFDiv(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertUnsignedRem<U: IRValue, V: IRValue>(
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildURem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertSignedRem<U: IRValue, V: IRValue>(
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildSRem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertFRem<U: IRValue, V: IRValue>(
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildFRem(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertShl<U: IRValue, V: IRValue>(
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildShl(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertLShr<U: IRValue, V: IRValue>(
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildLShr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertAShr<U: IRValue, V: IRValue>(
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildAShr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertBitwiseAnd(
    _ lhs: LLVMIdentity<some IRValue>, _ rhs: LLVMIdentity<some IRValue>,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildAnd(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertBitwiseOr(
    _ lhs: LLVMIdentity<some IRValue>, _ rhs: LLVMIdentity<some IRValue>,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildOr(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertBitwiseXor(
    _ lhs: LLVMIdentity<some IRValue>, _ rhs: LLVMIdentity<some IRValue>,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildXor(p.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Memory

  public mutating func insertAlloca(
    _ type: LLVMIdentity<some IRType>, at p: borrowing InsertionPoint
  )
    -> Alloca.Identity
  {
    Alloca.insert(type, at: p, in: &self)
  }

  /// Returns the entry block of `f`, if any.
  public mutating func entryOf(
    _ f: Function.Identity
  ) -> BasicBlock.Identity? {
    guard let e = values[f].entry else { return nil }
    return basicBlocks.id(for: e.llvm)!
  }
  /// Inerts an `alloca` allocating memory on the stack a value of `type`, at the entry of `f`.
  ///
  /// - Requires: `f` has an entry block.
  public mutating func insertAlloca<T: IRType>(_ type: T.Identity, atEntryOf f: Function.Identity)
    -> Alloca.Identity
  {
    insertAlloca(type, at: startOf(entryOf(f)!))
  }

  public mutating func insertGetElementPointer<V: IRValue, T: IRType>(
    of base: V.Identity,
    typed baseType: T.Identity,
    indices: [AnyValue.Identity],
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    var i = indices.map({ values[$0].llvm.raw as Optional })
    let handle = LLVMBuildGEP2(
      p.llvm, types[baseType].llvm.raw, values[base].llvm.raw, &i, UInt32(i.count), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertGetElementPointerInBounds<V: IRValue, T: IRType>(
    of base: V.Identity,
    typed baseType: T.Identity,
    indices: [AnyValue.Identity],
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    var i = indices.map({ values[$0].llvm.raw as Optional })
    let handle = LLVMBuildInBoundsGEP2(
      p.llvm, types[baseType].llvm.raw, values[base].llvm.raw, &i, UInt32(i.count), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertGetStructElementPointer<V: IRValue>(
    of base: V.Identity,
    typed baseType: StructType.Identity,
    index: Int,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildStructGEP2(
      p.llvm, types[baseType].llvm.raw, values[base].llvm.raw, UInt32(index), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertLoad<T: IRType, V: IRValue>(
    _ type: T.Identity, from source: V.Identity, at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    .init(
      values.insert(
        ValueRef(LLVMBuildLoad2(p.llvm, types[type].llvm.raw, values[source].llvm.raw, ""))))
  }

  @discardableResult
  public mutating func insertStore<V1: IRValue, V2: IRValue>(
    _ value: V1.Identity, to location: V2.Identity, at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let r = LLVMBuildStore(p.llvm, values[value].llvm.raw, values[location].llvm.raw)!
    LLVMSetAlignment(r, UInt32(layout.preferredAlignment(of: values[value].type)))
    return .init(values.insert(ValueRef(r)))
  }

  // MARK: Atomics

  public mutating func setOrdering(_ ordering: AtomicOrdering, for i: Instruction.Identity) {
    LLVMSetOrdering(values[i].llvm.raw, ordering.llvm)
  }

  public mutating func setCmpXchgSuccessOrdering(
    _ ordering: AtomicOrdering, for i: Instruction.Identity
  ) {
    LLVMSetCmpXchgSuccessOrdering(values[i].llvm.raw, ordering.llvm)
  }

  public mutating func setCmpXchgFailureOrdering(
    _ ordering: AtomicOrdering, for i: Instruction.Identity
  ) {
    LLVMSetCmpXchgFailureOrdering(values[i].llvm.raw, ordering.llvm)
  }

  public mutating func setAtomicRMWBinOp(_ binOp: AtomicRMWBinOp, for i: Instruction.Identity) {
    LLVMSetAtomicRMWBinOp(values[i].llvm.raw, binOp.llvm)
  }

  public mutating func setAtomicSingleThread(for i: Instruction.Identity) {
    LLVMSetAtomicSingleThread(values[i].llvm.raw, 1)
  }

  public mutating func insertAtomicCmpXchg<V1: IRValue, V2: IRValue, V3: IRValue>(
    _ atomic: V1.Identity,
    old: V2.Identity,
    new: V3.Identity,
    successOrdering: AtomicOrdering,
    failureOrdering: AtomicOrdering,
    weak: Bool,
    singleThread: Bool,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildAtomicCmpXchg(
      p.llvm, values[atomic].llvm.raw, values[old].llvm.raw, values[new].llvm.raw,
      successOrdering.llvm,
      failureOrdering.llvm, singleThread ? 1 : 0)!
    let i = Instruction.Identity(values.insert(ValueRef(handle)))
    if weak {
      LLVMSetWeak(values[i].llvm.raw, 1)
    }
    return i
  }

  public mutating func insertAtomicRMW<V1: IRValue, V2: IRValue>(
    _ atomic: V1.Identity,
    operation: AtomicRMWBinOp,
    value: V2.Identity,
    ordering: AtomicOrdering,
    singleThread: Bool,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildAtomicRMW(
      p.llvm, operation.llvm, values[atomic].llvm.raw, values[value].llvm.raw, ordering.llvm,
      singleThread ? 1 : 0
    )!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertFence(
    _ ordering: AtomicOrdering, singleThread: Bool, at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildFence(p.llvm, ordering.llvm, singleThread ? 1 : 0, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Terminators

  @discardableResult
  public mutating func insertBr(to destination: BasicBlock.Identity, at p: borrowing InsertionPoint)
    -> Instruction.Identity
  {
    let handle = LLVMBuildBr(p.llvm, basicBlocks[destination].llvm.raw)!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertCondBr<V: IRValue>(
    if condition: V.Identity, then t: BasicBlock.Identity, else e: BasicBlock.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildCondBr(
      p.llvm, values[condition].llvm.raw, basicBlocks[t].llvm.raw, basicBlocks[e].llvm.raw)!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertSwitch<
    V: IRValue, C: Collection<(AnyValue.Identity, BasicBlock.Identity)>
  >(
    on value: V.Identity, cases: C, default defaultCase: BasicBlock.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let s = LLVMBuildSwitch(
      p.llvm, values[value].llvm.raw, basicBlocks[defaultCase].llvm.raw, UInt32(cases.count))!
    for (caseValue, destination) in cases {
      LLVMAddCase(s, values[caseValue].llvm.raw, basicBlocks[destination].llvm.raw)
    }
    return .init(values.insert(ValueRef(s)))
  }

  @discardableResult
  public mutating func insertReturn(at p: borrowing InsertionPoint) -> Instruction.Identity {
    let handle = LLVMBuildRetVoid(p.llvm)!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertReturn<V: IRValue>(_ value: V.Identity, at p: borrowing InsertionPoint)
    -> Instruction.Identity
  {
    let handle = LLVMBuildRet(p.llvm, values[value].llvm.raw)!
    return .init(values.insert(ValueRef(handle)))
  }

  @discardableResult
  public mutating func insertUnreachable(at p: borrowing InsertionPoint) -> Instruction.Identity {
    let handle = LLVMBuildUnreachable(p.llvm)!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Aggregate operations

  public mutating func insertExtractValue<V: IRValue>(
    from whole: V.Identity,
    at index: Int,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildExtractValue(p.llvm, values[whole].llvm.raw, UInt32(index), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertInsertValue<V1: IRValue, V2: IRValue>(
    _ part: V1.Identity,
    at index: Int,
    into whole: V2.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildInsertValue(
      p.llvm, values[whole].llvm.raw, values[part].llvm.raw, UInt32(index), "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Conversions

  public mutating func insertTrunc<V: IRValue, T: IRType>(
    _ source: V.Identity, to target: T.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildTrunc(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertSignExtend<V: IRValue, T: IRType>(
    _ source: V.Identity, to target: T.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildSExt(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertZeroExtend<V: IRValue, T: IRType>(
    _ source: V.Identity, to target: T.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildZExt(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertIntToPtr<V: IRValue>(
    _ source: V.Identity, to target: AnyType.Identity? = nil,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
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
    _ source: V.Identity, to target: T.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildPtrToInt(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertFPTrunc<V: IRValue, T: IRType>(
    _ source: V.Identity, to target: T.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildFPTrunc(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertFPExtend<V: IRValue, T: IRType>(
    _ source: V.Identity, to target: T.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let handle = LLVMBuildFPExt(p.llvm, values[source].llvm.raw, types[target].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Others

  public mutating func insertCall<C: Callable>(
    _ callee: C.Identity,
    on arguments: [AnyValue.Identity],
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    let calleeTypeID = values[callee].valueType(in: &self)
    return insertCall(callee.erased, typed: calleeTypeID, on: arguments, at: p)
  }

  public mutating func insertCall<T: IRType>(
    _ callee: AnyValue.Identity,
    typed calleeType: T.Identity,
    on arguments: [AnyValue.Identity],
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    var a = arguments.map({ values[$0].llvm.raw as Optional })

    // Debug: Print function type and arguments
    let calleeTypeWrapper = types[calleeType]
    if let funcType = FunctionType(calleeTypeWrapper) {
      // Check if this is a problematic call (mismatched number of parameters when not vararg)
      if funcType.parameters.count != arguments.count && !funcType.isVarArg {
        let functionName = values[Function.Identity(callee)].name
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
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    precondition(values[lhs].type == values[rhs].type)
    let handle = LLVMBuildICmp(
      p.llvm, predicate.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  public mutating func insertFloatingPointComparison<U: IRValue, V: IRValue>(
    _ predicate: FloatingPointPredicate,
    _ lhs: U.Identity, _ rhs: V.Identity,
    at p: borrowing InsertionPoint
  ) -> Instruction.Identity {
    precondition(values[lhs].type == values[rhs].type)
    let handle = LLVMBuildFCmp(
      p.llvm, predicate.llvm, values[lhs].llvm.raw, values[rhs].llvm.raw, "")!
    return .init(values.insert(ValueRef(handle)))
  }

  // MARK: Type constructors

  public mutating func integerType(_ bitWidth: Int) -> IntegerType.Identity {
    return IntegerType.create(bitWidth, in: &self)
  }

  /// Creates an opaque pointer type in the given address space.
  public mutating func pointerType(inAddressSpace s: AddressSpace = .default)
    -> PointerType.Identity
  {
    PointerType.create(inAddressSpace: s, in: &self)
  }

  /// Creates a function type with given parameter and return types.
  public mutating func functionType<each T: IRType, R: IRType>(
    from parameters: (repeat (each T).Identity), to returnType: R.Identity
  ) -> FunctionType.Identity {
    FunctionType.create(from: parameters, to: returnType.erased, in: &self)
  }

  /// Creates a function type with given parameter types and void as return type.
  public mutating func functionType<each T: IRType>(from parameters: (repeat (each T).Identity)) -> FunctionType.Identity {
    FunctionType.create(from: parameters, to: nil, in: &self)
  }

  /// Creates an array type of `count` elements of `element`.
  public mutating func arrayType<T: IRType>(_ count: Int, _ element: T.Identity)
    -> ArrayType.Identity
  {
    ArrayType.create(count, types[element] as T, in: &self)
  }

  /// Creates or retrieves the `void` type, returning its ID.
  public mutating func voidType() -> VoidType.Identity {
    return VoidType.create(in: &self)
  }

  /// Creates a struct type with given field type IDs.
  public mutating func structType(_ fields: [AnyType.Identity], packed: Bool = false)
    -> StructType.Identity
  {
    StructType.create(fields, packed: packed, in: &self)
  }

  /// Creates a named struct type with given field type IDs.
  public mutating func structType(
    named name: String, _ fields: [AnyType.Identity], packed: Bool = false
  )
    -> StructType.Identity
  {
    StructType.create(named: name, fields, packed: packed, in: &self)
  }

  /// Creates an instruction representing an undefined value of type `type`.
  public mutating func undefinedValue<T: IRType>(of type: T.Identity) -> Undefined.Identity {
    Undefined.create(of: type, in: &self)
  }

  /// Creates an instruction representing a poison value of type `type`.
  public mutating func poisonValue<T: IRType>(of type: T.Identity) -> Poison.Identity {
    return Poison.create(of: type, in: &self)
  }
}
