internal import llvmc

/// How data are represented in memory for a particular target machine.
public struct DataLayout: ~Copyable {

  /// A handle to the LLVM object wrapped by this instance.
  private let llvm: LLVMTargetDataRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMTargetDataRef) {
    self.llvm = llvm
  }

  /// Creates an instance representing the data layout associated with `machine`.
  public init(of machine: borrowing TargetMachine) {
    self.llvm = LLVMCreateTargetDataLayout(machine.llvm)
  }

  deinit {
    LLVMDisposeTargetData(llvm)
  }

  /// Returns the number of bits in the representation of `type`'s instances.
  public func bitWidth(of type: any IRType) -> Int {
    Int(LLVMSizeOfTypeInBits(llvm, type.llvm.raw))
  }

  /// Returns the storage size of the representation of `type`'s instances in bytes.
  public func storageSize(of type: any IRType) -> Int {
    Int(LLVMStoreSizeOfType(llvm, type.llvm.raw))
  }

  /// Returns the number of bytes from one instance of `type` to the next when stored in contiguous
  /// memory.
  public func storageStride(of type: any IRType) -> Int {
    let align = abiAlignment(of: type)
    assert(align > 0)
    return (storageSize(of: type) + align - 1) / align * align
  }

  /// The alignment of `type`'s instances in bytes.
  public func preferredAlignment(of type: any IRType) -> Int {
    Int(LLVMPreferredAlignmentOfType(llvm, type.llvm.raw))
  }

  /// The ABI alignment of `type`'s instances in bytes.
  public func abiAlignment(of type: any IRType) -> Int {
    Int(LLVMABIAlignmentOfType(llvm, type.llvm.raw))
  }

  /// Returns the offset in bytes of the element at given `index`.
  ///
  /// - Requires: `index` is a valid element index in `type`.
  public func offset(of index: Int, in type: StructType) -> Int {
    Int(LLVMOffsetOfElement(llvm, type.llvm.raw, UInt32(index)))
  }

  /// Returns the index of the element containing the byte at given `offset`.
  ///
  /// - Requires: `offset` is a valid byte offset in `type`.
  public func index(at offset: Int, in type: StructType) -> Int {
    Int(LLVMElementAtOffset(llvm, type.llvm.raw, UInt64(offset)))
  }

}

extension DataLayout {

  public var description: String {
    guard let s = LLVMCopyStringRepOfTargetData(llvm) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return .init(cString: s)
  }

}
