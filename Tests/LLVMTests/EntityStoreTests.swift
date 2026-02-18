import XCTest

@testable import SwiftyLLVM

// MARK: - Mock Entity for Testing

struct MockData {
  var name: String
  var value: Int
}

/// A wrapper similar to an LLVM entity.
struct MockEntity: LLVMEntity, Hashable {
  typealias Handle = UnsafeMutablePointer<MockData>

  var handle: Handle

  init(temporarilyWrapping handle: Handle) {
    self.handle = handle
  }

  var name: String {
    get { handle.pointee.name }
    set { handle.pointee.name = newValue }
  }

  var value: Int {
    get { handle.pointee.value }
    set { handle.pointee.value = newValue }
  }
}

/// An allocator that, similarly to LLVM, allows creating objects, and frees all of them at the end of its lifetime.
/// 
/// Accessing entity wrappers after the arena's lifetime is undefined behavior.
private struct TrackedHandleArena: ~Copyable {
  private var live: [MockEntity.Handle] = []

  mutating func makeHandle(name: String, value: Int) -> MockEntity.Handle {
    let pointer = UnsafeMutablePointer<MockData>.allocate(capacity: 1)
    pointer.initialize(to: MockData(name: name, value: value))
    live.append(pointer)
    return pointer
  }

  deinit {
    for handle in live {
      handle.deinitialize(count: 1)
      handle.deallocate()
    }
  }
}

// MARK: - EntityStore Tests

final class EntityStoreTests: XCTestCase {

  func testIDsAreUnique() {
    var arena = TrackedHandleArena()
    var store = EntityStore<MockEntity>()
    let id1 = store.insert(arena.makeHandle(name: "A", value: 1))
    let id2 = store.insert(arena.makeHandle(name: "B", value: 2))
    let id3 = store.insert(arena.makeHandle(name: "C", value: 3))

    XCTAssertNotEqual(id1.raw, id2.raw)
    XCTAssertNotEqual(id2.raw, id3.raw)
    XCTAssertNotEqual(id1.raw, id3.raw)

  }

  func testUnsafeExtractAndRestore() {
    var arena = TrackedHandleArena()
    var store = EntityStore<MockEntity>()
    let id = store.insert(arena.makeHandle(name: "Extract", value: 7))

    let handle = store.unsafeExtract(id)
    XCTAssertFalse(store.contains(id))

    handle.pointee.value = 99
    store.unsafeRestore(id, handle)

    XCTAssertTrue(store.contains(id))
    XCTAssertEqual(store[id].value, 99)

  }

  func testSubscriptReadAndWrite() {
    var arena = TrackedHandleArena()
    var store = EntityStore<MockEntity>()
    let id = store.insert(arena.makeHandle(name: "Sub", value: 5))

    XCTAssertEqual(store[id].value, 5)
    store[id].value += 10
    XCTAssertEqual(store[id].value, 15)

  }

  func testHandleForReturnsNilWhenExtracted() {
    var arena = TrackedHandleArena()
    var store = EntityStore<MockEntity>()
    let id = store.insert(arena.makeHandle(name: "H", value: 1))

    XCTAssertNotNil(store.handle(for: id))
    let handle = store.unsafeExtract(id)
    XCTAssertNil(store.handle(for: id))

    store.unsafeRestore(id, handle)
    XCTAssertNotNil(store.handle(for: id))

  }
}

// MARK: - BidirectionalEntityStore Tests

final class BidirectionalEntityStoreTests: XCTestCase {

  func testInsertAndLookupByHandle() {
    var arena = TrackedHandleArena()
    var store = BidirectionalEntityStore<MockEntity>()
    let handle = arena.makeHandle(name: "Lookup", value: 10)
    let id = store.insert(handle)

    XCTAssertTrue(store.contains(id))
    XCTAssertTrue(store.contains(handle: handle))
    XCTAssertEqual(store.id(for: handle)?.raw, id.raw)

  }

  func testdemandReturnsSameID() {
    var arena = TrackedHandleArena()
    var store = BidirectionalEntityStore<MockEntity>()
    let handle = arena.makeHandle(name: "Uniq", value: 1)

    let id1 = store.demandId(for: handle)
    let id2 = store.demandId(for: handle)

    XCTAssertEqual(id1.raw, id2.raw)
  }

  func testUnsafeExtractUpdatesHandleIndex() {
    var arena = TrackedHandleArena()
    var store = BidirectionalEntityStore<MockEntity>()
    let handle = arena.makeHandle(name: "X", value: 3)
    let id = store.insert(handle)

    let extracted = store.unsafeExtract(id)
    XCTAssertFalse(store.contains(id))
    XCTAssertFalse(store.contains(handle: handle))
    XCTAssertNil(store.id(for: handle))

    store.unsafeRestore(id, extracted)
    XCTAssertTrue(store.contains(id))
    XCTAssertTrue(store.contains(handle: handle))
    XCTAssertEqual(store.id(for: handle)?.raw, id.raw)
  }

  func testSubscriptByIDAndHandle() {
    var arena = TrackedHandleArena()
    var store = BidirectionalEntityStore<MockEntity>()
    let handle = arena.makeHandle(name: "Mixed", value: 50)
    let id = store.insert(handle)

    store[id].value = 60
    XCTAssertEqual(store[handle].value, 60)

    store[handle].value = 70
    XCTAssertEqual(store[id].value, 70)

  }

  func testSubscriptExtractsAndRestoresHandle() {
    var arena = TrackedHandleArena()
    var store = BidirectionalEntityStore<MockEntity>()

    let handle = arena.makeHandle(name: "Subscript", value: 5)
    let id = store.insert(handle)

    withUnsafeMutablePointer(
      to: &store,
      { s in

        modify(
          &s.pointee[id],
          { e in

            XCTAssertFalse(s.pointee.contains(id))
            XCTAssertFalse(s.pointee.contains(handle: handle))
            XCTAssertNil(s.pointee.id(for: handle))
            e.value += 10
          })
      })

    XCTAssertTrue(store.contains(id))
    XCTAssertTrue(store.contains(handle: handle))
    XCTAssertEqual(store.id(for: handle)?.raw, id.raw)
    XCTAssertEqual(store[id].value, 15)
  }

}
