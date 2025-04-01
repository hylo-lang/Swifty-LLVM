internal import llvmc

/// The ordering for an atomic operation.
///
/// See https://en.cppreference.com/w/cpp/atomic/memory_order
public enum AtomicOrdering: Sendable {

  /// A load or a store operation that is not atomic.
  ///
  /// Matches C++ memory model for non-atomic shared variables.
  case notAtomic

  /// Lowest level of atomicity, guarantees somewhat sane results, lock free.
  ///
  /// Matches Java memory model for shared variables.
  case unordered

  /// Guarantees that if you take all the operations affecting a specific address, a consistent
  /// ordering exists.
  ///
  /// Matches the C++ memory_order_relaxed memory order.
  case monotonic

  /// A load that is an *acquire operation*, or a barrier necessary to acquire a lock to access
  /// other memory with normal loads and stores.
  ///
  /// Matches the C++ memory_order_acquire memory order.
  case acquire

  /// A store that is a *release operation*, or a barrier necessary to release a lock.
  ///
  /// Matches the C++ memory_order_release memory order.
  case release

  /// A read-modify-write operation with this memory order is both an *acquire operation* and a
  /// *release operation*, or a barrier that is both an Acquire and a Release barrier.
  ///
  /// Matches the C++ memory_order_acq_rel memory order.
  case acquireRelease

  /// Same as `acquireRelease`, but also provides a single total order of all modifications.
  ///
  /// Matches the C++ memory_order_seq_cst memory order.
  case sequentiallyConsistent

  /// Creates an instance from its LLVM representation.
  internal init(llvm: LLVMAtomicOrdering) {
    switch llvm {
    case LLVMAtomicOrderingNotAtomic:
      self = .notAtomic
    case LLVMAtomicOrderingUnordered:
      self = .unordered
    case LLVMAtomicOrderingMonotonic:
      self = .monotonic
    case LLVMAtomicOrderingAcquire:
      self = .acquire
    case LLVMAtomicOrderingRelease:
      self = .release
    case LLVMAtomicOrderingAcquireRelease:
      self = .acquireRelease
    case LLVMAtomicOrderingSequentiallyConsistent:
      self = .sequentiallyConsistent
    default:
      fatalError("unsupported atomic ordering")
    }
  }

  /// The LLVM representation of this instance.
  internal var llvm: LLVMAtomicOrdering {
    switch self {
    case .notAtomic:
      return LLVMAtomicOrderingNotAtomic
    case .unordered:
      return LLVMAtomicOrderingUnordered
    case .monotonic:
      return LLVMAtomicOrderingMonotonic
    case .acquire:
      return LLVMAtomicOrderingAcquire
    case .release:
      return LLVMAtomicOrderingRelease
    case .acquireRelease:
      return LLVMAtomicOrderingAcquireRelease
    case .sequentiallyConsistent:
      return LLVMAtomicOrderingSequentiallyConsistent
    }
  }

}
