/// An error indicating that IR is ill-formed.
public struct VerificationError: Error, CustomStringConvertible {

  /// A description of the error.
  public let description: String

}
