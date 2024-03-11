import SwiftyLLVM

/// Returns the result of calling `action` on a new context and a new module in that context.
func withContextAndModule<R>(
  named n: String, do action: (inout Context, inout Module) throws -> R
) rethrows -> R {
  try Context.withNew { (c) in try c.withNewModule(n, do: action) }
}
