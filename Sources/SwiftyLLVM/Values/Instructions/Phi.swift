internal import llvmc

/// LLVM's `phi` instruction.
///
/// - See https://llvm.org/docs/LangRef.html#phi-instruction.
public struct Phi: IRInstruction {

  /// A handle to the LLVM object wrapped by this instance.
  public let llvm: ValueRef

  /// Creates an instance wrapping `handle`.
  public init(temporarilyWrapping handle: ValueRef) {
    self.llvm = handle
  }

  /// The incoming branches of the instruction.
  public var incoming: Incoming { .init(of: llvm) }

}

extension Phi {


  /// A collection containing the incoming branches of `phi` function.
  public struct Incoming: RandomAccessCollection {

    /// The collection index type.
    public typealias Index = Int

    /// The collection element type.
    public struct Element {

      /// The value on the incoming branch.
      public let value: AnyValue.UnsafeReference

      /// The origin of the incoming branch.
      public let block: BasicBlock.UnsafeReference

    }

    /// The instruction containing the elements of the collection.
    private let parent: ValueRef

    /// Creates a collection containing the incoming branches of `parent`.
    fileprivate init(of parent: ValueRef) {
      self.parent = parent
    }

    /// The number of branches in the collection.
    public var count: Int {
      Int(LLVMCountIncoming(parent.raw))
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
    public subscript(position: Int) -> Element {
      precondition(position >= 0 && position < count, "index is out of bounds")
      let v = LLVMGetIncomingValue(parent.raw, UInt32(position))
      let b = LLVMGetIncomingBlock(parent.raw, UInt32(position))
      return Element(value: .init(v!), block: .init(b!))
    }

  }

}

extension UnsafeReference<Phi> {

  /// Creates an instance with `s`, failing iff `s` isn't an `alloca`.
  public init?(_ s: AnyValue.UnsafeReference) {
    if let h = LLVMIsAPHINode(s.llvm.raw) {
      self.init(h)
    } else {
      return nil
    }
  }

}
