extension String {

  /// Creates an instance calling `getter` on `llvm` to read its value.
  init?<T>(
    from llvm: T,
    readingWith getter: (T, UnsafeMutablePointer<Int>?) -> UnsafePointer<CChar>?
  ) {
    var n = 0
    guard let s = getter(llvm, &n) else { return nil }
    self.init(
      decoding: UnsafeBufferPointer(start: s, count: n).lazy.map(UInt8.init(bitPattern:)),
      as: UTF8.self)
  }

}
