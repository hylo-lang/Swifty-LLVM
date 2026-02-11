internal import llvmc

public protocol LLVMEntity: ~Copyable {
}

public struct ConcreteLLVMIdentity<T: LLVMEntity>: Hashable {
  let raw: Int

  init(_ raw: Int) {
    self.raw = raw
  }
}

extension LLVMEntity {

  /// The identity of an instance of `Self`.
  public typealias ID = ConcreteLLVMIdentity<Self>

}

/// An LLVM context, owning all objects.
public struct LLVM: ~Copyable {
  private let context: LLVMContextRef

  /// Creates a new LLVM context.
  public init() {
    self.context = LLVMContextCreate()
  }

  deinit {
    LLVMContextDispose(context)
  }

  // Index corresponds to the module's ID.
  private var modules: [ModuleReference] = []

  /// Creates a new module in the context with given `name` and returns its ID.
  public mutating func createModule(named name: String) -> Module.ID {
    let m = ModuleReference(LLVMModuleCreateWithNameInContext(name, context)!)
    let id = Module.ID(modules.count)
    modules.append(m)
    return id
  }

  /// Appends a basic block named `n` to `f` and returns it.
  ///
  /// A unique name is generated if `n` is empty or if `f` already contains a block named `n`.
  @discardableResult
  public mutating func appendBlock(named n: String = "", to f: Function.ID, in m: Module.ID) -> BasicBlock {
    .init(LLVMAppendBasicBlockInContext(context, f.llvm.raw, n))
  }
}


public struct DataLayout: LLVMEntity {
  internal let llvmDataLayout: LLVMTargetDataRef

  internal init(wrappingTemporarily dataLayout: LLVMTargetDataRef) {
    self.llvmDataLayout = dataLayout
  }
}


// - We can copy and escape the instance -> try making it non-copyable
// - We can project multiple views of the same instance -> dynamic side table (these should be stored in the parent object)
// - It will be a bit cumbersome to have nested `with...` calls - yeah maybe, then 