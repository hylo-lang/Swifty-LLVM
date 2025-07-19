/// Properties of a pointer expressed through the data layout.
public struct AddressSpace: Hashable, Sendable {

  /// The LLVM representation of this instance.
  public let llvm: UInt32

  /// Creates an instance with given `rawValue`.
  internal init(_ rawValue: UInt32) {
    self.llvm = rawValue
  }

  /// The default address space.
  public static let `default` = AddressSpace(0)

}
