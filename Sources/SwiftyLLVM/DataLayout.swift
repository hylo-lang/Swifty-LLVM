internal import llvmc
internal import llvmshims

/// How data are represented in memory for a particular target machine.
public struct DataLayout: ~Copyable {

  /// A handle to the LLVM object wrapped by this instance.
  private let llvm: LLVMTargetDataRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMTargetDataRef) {
    self.llvm = llvm
  }

  deinit {
    LLVMDisposeTargetData(llvm)
  }

  /// Returns the number of bits in the representation of `type`'s instances.
  public func bitWidth(of type: UnsafeReference<some IRType>) -> Int {
    Int(LLVMSizeOfTypeInBits(llvm, type.llvm.raw))
  }

  /// Returns the storage size of the representation of `type`'s instances in bytes.
  public func storageSize(of type: UnsafeReference<some IRType>) -> Int {
    Int(LLVMStoreSizeOfType(llvm, type.llvm.raw))
  }

  /// Returns the number of bytes from one instance of `type` to the next when stored in contiguous
  /// memory.
  public func storageStride(of type: UnsafeReference<some IRType>) -> Int {
    let align = abiAlignment(of: type)
    assert(align > 0)
    return (storageSize(of: type) + align - 1) / align * align
  }

  

  /// The alignment of `type`'s instances in bytes as specified by the target ABI.
  /// 
  /// - Guarantees:
  ///   - Less than or equal to the preferred alignment.
  ///   - A power of 2.
  /// - Requires: `type` is sized (i.e. not void or a function type).
  public func abiAlignment(of type: UnsafeReference<some IRType>) -> Int {
    precondition(type.pointee.isSized, "Cannot get alignment of unsized type.")
    return Int(LLVMABIAlignmentOfType(llvm, type.raw))
  }

  /// The alignment of `type`'s instances in bytes when it's most efficient to access values.
  /// 
  /// - Guarantees:
  ///   - Greater than or equal to the ABI alignment.
  ///   - A power of 2.
  /// - Requires: `type` is sized (i.e. not void or a function type).
  public func preferredAlignment(of type: UnsafeReference<some IRType>) -> Int {
    precondition(type.pointee.isSized, "Cannot get alignment of unsized type.")
    return Int(LLVMPreferredAlignmentOfType(llvm, type.raw))
  }

  /// Returns the offset in bytes of the element at given `index`.
  ///
  /// - Requires: `index` is a valid element index in `type`.
  public func offset(of index: Int, in type: StructType.UnsafeReference) -> Int {
    Int(LLVMOffsetOfElement(llvm, type.llvm.raw, UInt32(index)))
  }

  /// Returns the index of the element containing the byte at given `offset`.
  ///
  /// - Requires: `offset` is a valid byte offset in `type`.
  public func index(at offset: Int, in type: StructType.UnsafeReference) -> Int {
    Int(LLVMElementAtOffset(llvm, type.llvm.raw, UInt64(offset)))
  }

  /// The size of pointers in bytes in the default address space.
  public var pointerSize: Int {
    Int(LLVMPointerSize(llvm))
  }

  /// An integer type with equal size to pointers in the default address space.
  public var pointerSizedIntegerType: IntegerType.UnsafeReference {
    .init(LLVMIntPtrType(llvm))
  }

  /// The address space in which function pointers are represented.
  public var programAddressSpace: AddressSpace {
    .init(SwiftyLLVMGetProgramAddressSpace(llvm))
  }

}

extension DataLayout {

  /// The canonical LLVM data layout string.
  public var description: String {
    guard let s = LLVMCopyStringRepOfTargetData(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

}
