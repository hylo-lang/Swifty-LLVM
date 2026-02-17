/// An LLVM function or intrinsic that can be called.
public protocol Callable: Global, Hashable {
  /// The parameters of the function.
  var parameters: Function.Parameters { get }

  /// The return value of the function.
  var returnValue: Function.Return { get }
}
