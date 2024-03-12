/// A pointer to a LLVM object that disposes of its pointee when it's no longer accessible.
final class ManagedPointer<T> {

  /// A pointer to a LLVM object.
  let llvm: T

  /// A closure that disposes of an instance pointed by `T`.
  private let dispose: (T) -> Void

  /// Creates an instance managing `p` and calling `dispose(p)` at the end of its lifetime.
  init(_ p: T, dispose: @escaping (T) -> Void) {
    self.llvm = p
    self.dispose = dispose
  }

  deinit {
    dispose(llvm)
  }

}
