internal import llvmc

/// The type of a value in LLVM IR.
public protocol IRType: CustomStringConvertible, LLVMEntity where Handle == TypeRef {

  /// A handle to the LLVM object wrapped by this instance.
  var llvm: TypeRef { get }

}

extension IRType {

  /// Creates an instance wrapping `r`.
  public init(temporarilyWrapping r: Self.UnsafeReference) {
    self.init(temporarilyWrapping: r.raw)
  }

  /// Creates an instance wrapping the native handle `r`.
  init(temporarilyWrapping r: LLVMTypeRef) {
    self.init(temporarilyWrapping: TypeRef(r))
  }

  /// A string representation of the type.
  public var description: String {
    guard let s = LLVMPrintTypeToString(llvm.raw) else { return "" }
    defer { LLVMDisposeMessage(s) }
    return String(cString: s)
  }

  /// `true` if the size of the type is known.
  public var isSized: Bool { LLVMTypeIsSized(llvm.raw) != 0 }

  /// The `null` instance of this type (e.g., the zero of `i32`).
  public var null: AnyValue.UnsafeReference { .init(LLVMConstNull(llvm.raw)) }

}
