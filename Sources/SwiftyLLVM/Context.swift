internal import llvmc

/// An opaque object that owns core LLVM data structures.
///
/// A single context is not thread safe but different contexts can execute on different threads
/// simultaneously.
public struct Context {

  /// A handle to the LLVM object wrapped by this instance.
  let llvm: LLVMContextRef

  /// Returns the result of calling `action` wiht a new LLVM context.
  public static func withNew<R>(do action: (inout Context) throws -> R) rethrows -> R {
    var instance = Context(llvm: LLVMContextCreate()!)
    defer { LLVMContextDispose(instance.llvm) }
    return try action(&instance)
  }

  /// Returns the result of calling `action` with a mutable projection of `self` along with the
  /// projection of a new LLVM module named `n`.
  ///
  /// The argument to `action` is only valid for the duration of its call. It is undefined behavior
  /// to let it escape in any way.
  public mutating func withNewModule<R>(
    _ n: String, do action: (inout Context, inout Module) throws -> R
  ) rethrows -> R {
    var instance = Module(n, in: self)
    defer { instance.dispose() }
    return try action(&self, &instance)
  }

  /// Returns the type with given `name`, or `nil` if no such type exists.
  public func type(named name: String) -> IRType? {
    LLVMGetTypeByName2(llvm, name).map(AnyType.init(_:))
  }

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
  public private(set) lazy var i1: IntegerType = .init(LLVMInt1TypeInContext(llvm))

  /// The 8-bit integer type.
  public private(set) lazy var i8: IntegerType = .init(LLVMInt8TypeInContext(llvm))

  /// The 16-bit integer type.
  public private(set) lazy var i16: IntegerType = .init(LLVMInt16TypeInContext(llvm))

  /// The 32-bit integer type.
  public private(set) lazy var i32: IntegerType = .init(LLVMInt32TypeInContext(llvm))

  /// The 64-bit integer type.
  public private(set) lazy var i64: IntegerType = .init(LLVMInt64TypeInContext(llvm))

  /// The 128-bit integer type.
  public private(set) lazy var i128: IntegerType = .init(LLVMInt128TypeInContext(llvm))

}
