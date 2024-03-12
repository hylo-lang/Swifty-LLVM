internal import llvmc

/// A read-only access to a block of memory.
public struct MemoryBuffer {

  /// A handle to the LLVM object representing a memory buffer.
  private final class Handle {

    /// A pointer to a LLVM memory buffer.
    let llvm: LLVMMemoryBufferRef

    /// `true` iff this instance is the owner of the memory pointed by `llvm`.
    private let isOwner: Bool

    /// Creates an instance wrapping `llvm` and calling `LLVMDisposeMemoryBuffer` on it at the
    /// end of its lifetime iff `isOwner` is `true`.
    init(_ llvm: LLVMMemoryBufferRef, owned isOwner: Bool) {
      self.llvm = llvm
      self.isOwner = isOwner
    }

    deinit {
      if !isOwner { return }
      LLVMDisposeMemoryBuffer(llvm)
    }

  }

  /// A pointer the object wrapped by this instance.
  private let wrapped: Handle

  /// Creates an instance referring to the memory represented by `llvm`, taking ownership of the
  /// memory iff `isOwned` is `true`.
  internal init(_ llvm: LLVMMemoryBufferRef, owned isOwned: Bool) {
    self.wrapped = .init(llvm, owned: isOwned)
  }

  /// Creates an instance with given `name`, copying the bytes of `source`.
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
    _ action: (MemoryBuffer) throws -> T
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

  /// A handle to the LLVM object wrapped by this instance.
  internal var llvm: LLVMMemoryBufferRef { wrapped.llvm }

}
