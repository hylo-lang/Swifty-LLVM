import Foundation
internal import llvmc

/// An intrinsic function known to LLVM.
///
/// Intrinsic functions have well known names and semantics and are required to follow certain
/// restrictions. Overall, these intrinsics represent an extension mechanism for the LLVM language
/// that does not require changing all of the transformations in LLVM when adding to the language.
public struct Intrinsic: Global, Callable, Hashable, Sendable {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `llvm`.
  public init(wrappingTemporarily llvm: ValueRef) {
    self.llvm = llvm
  }

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

  /// The name of a non-overloaded intrinsic.
  public var name: String {
    precondition(!isOverloaded, "Overloaded intrinsics do not have a single name")
    // See https://searchfox.org/llvm/rev/7a089bc4c00fe35c8f07b7c420be6535ad331161/llvm/lib/IR/Intrinsics.cpp#51
    // and https://searchfox.org/llvm/rev/7a089bc4c00fe35c8f07b7c420be6535ad331161/llvm/lib/IR/Core.cpp#2474

    // We may get the name by LLVMIntrinsicCopyOverloadedName2 if we can recover the parameters based on the ValueRef (that contains a ptr),
    // or we could just save them additionally when creating the intrinsic when the user explicitly provides this list. This seems wasteful though.
    return String(from: identifier, readingWith: LLVMIntrinsicGetName(_:_:)) ?? ""
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
