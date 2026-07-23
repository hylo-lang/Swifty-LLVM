internal import llvmc

/// Fast floating point operation flags used for allowing additional optimizations.
/// 
/// LLVM IR floating-point operations (fneg, fadd, fsub, fmul, fdiv, frem, fcmp, fptrunc, fpext),
/// uitofp, sitofp, and phi, select, or call instructions that return floating-point types may use
/// the following flags to enable otherwise unsafe floating-point transformations.
///
/// - See: https://llvm.org/docs/LangRef.html#fast-math-flags
public struct FastMathFlags: OptionSet, Sendable {

  /// The LLVM representation of `self`.
  public let rawValue: UInt32

  /// Creates an instance from its LLVM representation.
  public init(rawValue: UInt32) { self.rawValue = rawValue }

  /// Allow algebraically equivalent transformations for floating-point instructions such as 
  /// reassociation transformations. This may dramatically change results in floating-point.
  public static let reassoc = FastMathFlags(rawValue: 1 << 0)
  
  /// Assume no NaNs.
  /// 
  /// Allow optimizations to assume the arguments and result are not NaN. If an argument is a NaN, 
  /// or the result would be a NaN, it produces a poison value instead.
  public static let nnan = FastMathFlags(rawValue: 1 << 1)

  /// Assume no infinities.
  /// 
  /// Allow optimizations to assume the arguments and result are not `+/-Inf`. If an argument is 
  /// `+/-Inf`, or the result would be `+/-Inf`, it produces a poison value instead.
  public static let ninf = FastMathFlags(rawValue: 1 << 2)

  /// Assume no signed zeros.
  /// 
  /// Unless otherwise mentioned, the sign bit of `0.0` or `-0.0` input operands can be 
  /// non-deterministically flipped. This does not imply that `-0.0` is poison and/or guaranteed to
  /// not exist in the operation.
  public static let nsz = FastMathFlags(rawValue: 1 << 3)

  /// Allows division to be treated as a multiplication by a reciprocal.
  /// 
  /// Specifically, this permits `a / b` to be considered equivalent to `a * (1.0 / b)` 
  /// (which may subsequently be susceptible to code motion), and it also permits `a / (b / c)` to 
  /// be considered equivalent to `a * (c / b)`. Both of these rewrites can be applied in either
  /// direction: `a * (c / b)` can be rewritten into `a / (b / c)`.
  public static let arcp = FastMathFlags(rawValue: 1 << 4)

  /// Allow floating-point contraction.
  /// 
  /// E.g., fusing a multiply followed by an addition into a fused multiply-and-add.
  /// 
  /// This does not enable reassociation to form arbitrary contractions. For example,
  /// `(a*b) + (c*d) + e` can not be transformed into `(a*b) + ((c*d) + e)`` to create two 
  /// fma operations.
  public static let contract = FastMathFlags(rawValue: 1 << 5)
  
  /// Approximate functions - Allow substitution of approximate calculations for math functions.
  ///
  /// See floating-point intrinsic definitions for places where this can apply to LLVM’s intrinsic
  /// math functions.
  public static let afn = FastMathFlags(rawValue: 1 << 6)

  /// An instance with all flags active.
  public static let fast: FastMathFlags = [
    .reassoc, .nnan, .ninf, .nsz, .arcp, .contract, .afn,
  ]

}
