import llvmc

/// Lifetime manager for a raw LLVM context.
public final class ContextHandle {

  /// The raw LLVM context managed by `self`.
  let raw: LLVMContextRef

  /// An instance managing c.
  init(_ c: LLVMContextRef) {
    self.raw = c
  }

  deinit {
    LLVMContextDispose(raw)
  }

}

/// A context handle is valueless; all such handles are considered to be equal.
extension ContextHandle: Hashable {

  public static func == (_: ContextHandle, _: ContextHandle) -> Bool { true }

  public func hash(into hasher: inout Hasher) {}

}

/// A type whose operations require a particular live LLVMContextRef for validity.
public protocol Contextual {

  /// A handle managing the LLVMContextRef that must remain live for operations on `self` to be
  /// valid.
  var context: ContextHandle { get }

}

extension Contextual {

  /// Invokes `body`, returning its result, with the guarantee that `context` will remain live
  /// during the execution of `body`.
  func inContext<R>(body: () throws -> R) rethrows -> R {
    try withExtendedLifetime(context) {
      try body()
    }
  }

}
