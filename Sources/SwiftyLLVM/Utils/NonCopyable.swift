/// A non-copyable type that can be compared for value equality.
public protocol NCEquatable: ~Copyable {
  /// Returns a Boolean value indicating whether two values are equal.
  static func == (a: borrowing Self, _ b: borrowing Self) -> Bool

}

extension NCEquatable {
  /// Returns a Boolean value indicating whether two values are not equal.
  public static func != (lhs: Self, rhs: Self) -> Bool {
    !(lhs == rhs)
  }
}

/// A non-copyable type that can be hashed into a `Hasher` to produce an integer hash value.
public protocol NCHashable: NCEquatable, ~Copyable {

  /// Hashes the essential components of this value by feeding them into the
  /// given hasher.
  func hash(into hasher: inout Hasher)
}

/// A type with a customized textual representation.
public protocol NCCustomStringConvertible: ~Copyable {

  /// A textual representation of this instance.
  var description: String { get }
}
