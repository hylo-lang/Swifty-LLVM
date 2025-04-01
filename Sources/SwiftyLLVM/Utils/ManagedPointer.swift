/// A pointer to a LLVM object that disposes of its pointee when it's no longer accessible.
final class ManagedPointer<T> {

  /// A pointer to a LLVM object.
  let llvm: T

  /// A closure that disposes of an instance pointed by `T`.
  private let dispose: @Sendable (T) -> Void

  /// Creates an instance managing `p` and calling `dispose(p)` at the end of its lifetime.
  init(_ p: T, dispose: @escaping @Sendable (T) -> Void) {
    self.llvm = p
    self.dispose = dispose
  }

  deinit {
    dispose(llvm)
  }

}
extension ManagedPointer: Sendable where T: Sendable { }