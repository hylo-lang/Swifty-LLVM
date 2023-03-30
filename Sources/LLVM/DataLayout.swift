import llvmc

/// How data are represented in memory for a particular target machine.
public struct DataLayout {

  /// A handle to the LLVM object wrapped by this instance.
  private let wrapped: ManagedPointer<LLVMTargetDataRef>

  /// Creates an instance representing the data layout associated with `machine`.
  public init(of machine: TargetMachine) {
    let handle = LLVMCreateTargetDataLayout(machine.llvm)
    self.wrapped = .init(handle!, dispose: LLVMDisposeTargetData(_:))
  }

  /// A handle to the LLVM object wrapped by this instance.
  internal var llvm: LLVMTargetDataRef { wrapped.llvm }

  /// Returns the number of bits in the representation of `type`'s instances.
  public func bitWidth(of type: IRType) -> Int {
    Int(LLVMSizeOfTypeInBits(llvm, type.llvm))
  }

  /// Returns the storage size of the representation of `type`'s instances in bytes.
  public func storageSize(of type: IRType) -> Int {
    Int(LLVMStoreSizeOfType(llvm, type.llvm))
  }

  /// Returns the number of bytes from one instance of `type` to the next when stored in contiguous
  /// memory.
  public func storageStride(of type: IRType) -> Int {
    let align = abiAlignment(of: type)
    assert(align > 0)
    return (storageSize(of: type) + align - 1) / align * align
  }

  /// The alignment of `type`'s instances in bytes.
  public func preferredAlignment(of type: IRType) -> Int {
    Int(LLVMPreferredAlignmentOfType(llvm, type.llvm))
  }

  /// The ABI alignment of `type`'s instances in bytes.
  public func abiAlignment(of type: IRType) -> Int {
    Int(LLVMABIAlignmentOfType(llvm, type.llvm))
  }

  /// Returns the offset in bytes of the element at given `index`.
  ///
  /// - Requires: `index` is a valid element index in `type`.
  public func offset(of index: Int, in type: StructType) -> Int {
    Int(LLVMOffsetOfElement(llvm, type.llvm, UInt32(index)))
  }

  /// Returns the index of the element containing the byte at given `offset`.
  ///
  /// - Requires: `offset` is a valid byte offset in `type`.
  public func index(at offset: Int, in type: StructType) -> Int {
    Int(LLVMElementAtOffset(llvm, type.llvm, UInt64(offset)))
  }

}

extension DataLayout: CustomStringConvertible {

  public var description: String {
    guard let s = LLVMCopyStringRepOfTargetData(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

}
