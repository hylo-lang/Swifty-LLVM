internal import llvmc

/// A constant character string in LLVM IR.
public struct StringConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

  /// Creates a string constant from `text` in `module`, appending a null terminator iff
  /// `nullTerminated` is `true`.
  public static func create(_ text: String, nullTerminated: Bool = true, in module: inout Module)
    -> StringConstant.UnsafeReference
  {
    text.withCString { (s) in
      StringConstant.UnsafeReference(
        LLVMConstStringInContext(module.context, s, UInt32(text.utf8.count), nullTerminated ? 0 : 1)
      )
    }
  }

  /// The value of this constant.
  public var value: String {
    .init(from: llvm) { (h, count) in
      // Decrement `count` if the string is null-terminated.
      guard let s = LLVMGetAsString(h.raw, count) else { return nil }
      if s[count!.pointee - 1] == 0 { count!.pointee -= 1 }
      return s
    } ?? ""
  }

}

extension UnsafeReference<StringConstant> {
  /// Creates an instance with `v`, failing iff `v` is not a constant string value.
  public init?(_ v: AnyValue.UnsafeReference) {
    if LLVMIsAConstantDataSequential(v.llvm.raw) != nil && LLVMIsConstantString(v.llvm.raw) != 0 {
      self.init(v.llvm)
    } else {
      return nil
    }
  }
}
