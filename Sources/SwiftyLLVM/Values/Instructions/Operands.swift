internal import llvmc

/// A collection containing the opereands of an LLVM instruction.
public struct Operands: BidirectionalCollection {

  /// The collection index type.
  public typealias Index = Int

  /// The collection element type.
  public typealias Element = AnyValue.UnsafeReference

  /// The instruction containing the operands of the collection.
  private let parent: any IRInstruction

  /// Creates a collection containing the operands of `parent`.
  public init(of parent: any IRInstruction) {
    self.parent = parent
  }

  /// The number of operands in the collection.
  public var count: Int {
    Int(LLVMGetNumOperands(parent.llvm.raw))
  }

  /// The position of the first element.
  public var startIndex: Int { 0 }

  /// The position past the last element.
  public var endIndex: Int { count }

  /// Returns the index immediately after `position`.
  public func index(after position: Int) -> Int {
    precondition(position < count, "index is out of bounds")
    return position + 1
  }

  /// Returns the index immediately before `position`.
  public func index(before position: Int) -> Int {
    precondition(position > 0, "index is out of bounds")
    return position - 1
  }

  /// The parameter at `position`.
  public subscript(position: Int) -> AnyValue.UnsafeReference {
    precondition(position >= 0 && position < count, "index is out of bounds")
    return .init(LLVMGetOperand(parent.llvm.raw, UInt32(position)))
  }

}
