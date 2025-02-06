internal import llvmc
import Foundation

/// An intrinsic function known to LLVM.
///
/// Intrinsic functions have well known names and semantics and are required to follow certain
/// restrictions. Overall, these intrinsics represent an extension mechanism for the LLVM language
/// that does not require changing all of the transformations in LLVM when adding to the language.
public struct Intrinsic: Global, Hashable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  internal init(_ llvm: LLVMValueRef) {
    self.llvm = .init(llvm)
  }

  /// The intrinsic's identifier.
  public var identifier: UInt32 {
    LLVMGetIntrinsicID(llvm.raw)
  }

  /// `true` iff the intrinsic is overloaded.
  public var isOverloaded: Bool {
    LLVMIntrinsicIsOverloaded(identifier) != 0
  }

  /// The name of the intrinsic.
  public var name: String {
    String(from: identifier, readingWith: LLVMIntrinsicGetName(_:_:)) ?? ""
  }

}

extension Intrinsic {

  /// The name of an intrinsic.
  @dynamicMemberLookup
  public struct Name: Sendable {

    /// The value of this instance.
    public let value: String

    /// Creates an instance with name `n`.
    fileprivate init(_ n: String) {
      self.value = n
    }

    /// Returns `self` with `n` appended.
    public subscript(dynamicMember n: String) -> Name {
      Name(value + "." + n)
    }

  }

  /// The prefix of all intrinsics.
  public static let llvm = Name("llvm")

}
