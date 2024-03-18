internal import llvmc

/// A constant character string in LLVM IR.
public struct StringConstant: IRValue, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance with `text` in `context`, appending a null terminator to the string iff
  /// `nullTerminated` is `true`.
  public init(_ text: String, nullTerminated: Bool = true, in context: inout Context) {
    self.llvm = text.withCString { (s) in
      let h = LLVMConstStringInContext(
        context.llvm, s, UInt32(text.utf8.count), nullTerminated ? 0 : 1)
      return .init(h!)
    }
  }

  /// Creates an instance with `v`, failing iff `v` is not a constant string value.
  public init?(_ v: IRValue) {
    if LLVMIsAConstantDataSequential(v.llvm.raw) != nil && LLVMIsConstantString(v.llvm.raw) != 0 {
      self.llvm = v.llvm
    } else {
      return nil
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
