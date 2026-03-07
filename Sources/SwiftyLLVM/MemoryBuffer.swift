internal import llvmc

/// A read-only access to a block of memory.
public struct MemoryBuffer: ~Copyable {

  /// A pointer to an LLVM memory buffer wrapped by this instance.
  let llvm: LLVMMemoryBufferRef

  /// `true` iff this instance is the owner of the memory pointed by `llvm`.
  private let isOwner: Bool

  deinit {
    if !isOwner { return }
    LLVMDisposeMemoryBuffer(llvm)
  }

  /// Creates an instance referring to the memory represented by `llvm`, taking ownership of the
  /// memory iff `isOwned` is `true`.
  internal init(_ llvm: LLVMMemoryBufferRef, owned isOwned: Bool) {
    self.llvm = llvm
    self.isOwner = isOwned
  }

  /// Creates an instance named `name`, copying the bytes of `source`.
  public init(copying source: UnsafeBufferPointer<Int8>, named name: String = "") {
    let handle = LLVMCreateMemoryBufferWithMemoryRangeCopy(source.baseAddress, source.count, name)
    self.init(handle!, owned: true)
  }

  /// Creates an instance with the contents at `filepath`.
  public init(contentsOf filepath: String) throws {
    var handle: LLVMMemoryBufferRef? = nil
    var error: UnsafeMutablePointer<CChar>? = nil
    LLVMCreateMemoryBufferWithContentsOfFile(filepath, &handle, &error)

    if let e = error {
      defer { LLVMDisposeMessage(e) }
      throw LLVMError("read failure: \(String(cString: e))")
    }

    self.init(handle!, owned: true)
  }

  /// Calls `action` with a memory buffer named `name`, borrowing the bytes of `source`.
  public static func withInstanceBorrowing<T>(
    _ source: UnsafeBufferPointer<Int8>, named name: String = "",
    _ action: (borrowing MemoryBuffer) throws -> T
  ) rethrows -> T {
    let handle = LLVMCreateMemoryBufferWithMemoryRange(source.baseAddress, source.count, name, 0)
    return try action(.init(handle!, owned: false))
  }

  /// The number of bytes in the buffer.
  public var count: Int {
    LLVMGetBufferSize(llvm)
  }

  /// Calls `action` with the contents of the buffer.
  public func withUnsafeBytes<T>(
    _ action: (UnsafeBufferPointer<Int8>) throws -> T
  ) rethrows -> T {
    let start = LLVMGetBufferStart(llvm)
    return try action(.init(start: start, count: count))
  }
}
