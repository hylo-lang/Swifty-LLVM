internal import llvmc

/// LLVM's `alloca` instruction.
public struct Alloca: IRValue {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = .init(llvm)
  }

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    llvm = handle
  }

  /// Creates an instance with `s`, failing iff `s` isn't an `alloca`
  public init?(_ s: any IRValue) {
    if let h = LLVMIsAAllocaInst(s.llvm.raw) {
      self.llvm = .init(h)
    } else {
      return nil
    }
  }

  public static func insert<T: IRType>(_ type: T.Identity, at p: borrowing InsertionPoint, in module: inout Module)
    -> Alloca.Identity
  {
    let handle = LLVMBuildAlloca(p.llvm, module.types[type].llvm.raw, "")!
    return Alloca.Identity(module.values.insert(ValueRef(handle)))
  }

  /// The type of the value allocated by the instruction.
  public var allocatedType: any IRType { AnyType(LLVMGetAllocatedType(llvm.raw)) }

  /// The preferred alignment of the allocated memory.
  public var alignment: Int { Int(LLVMGetAlignment(llvm.raw)) }

}
