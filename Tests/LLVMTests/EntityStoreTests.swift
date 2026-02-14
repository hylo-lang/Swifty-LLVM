import SwiftyLLVM
import XCTest

// MARK: - Mock Entity for Testing

/// A simple mock entity to demonstrate EntityStore functionality
struct MockEntity: EntityViewWithImmutableNonThrowingCreationContext, Hashable {
  typealias Handle = UnsafeMutablePointer<MockData>
  
  var handle: Handle
  
  init(wrappingTemporarily handle: Handle) {
    self.handle = handle
  }
  
  struct CreationContext {
    var name: String
    var value: Int
  }
  
  static func create(using context: CreationContext) -> Handle {
    let pointer = UnsafeMutablePointer<MockData>.allocate(capacity: 1)
    pointer.initialize(to: MockData(name: context.name, value: context.value))
    return pointer
  }
  
  static func destroy(_ handle: Handle) {
    handle.deinitialize(count: 1)
    handle.deallocate()
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

struct MockData {
  var name: String
  var value: Int
}

/// A throwing mock entity to test error handling
struct ThrowingMockEntity: EntityViewWithImmutableThrowingCreationContext {
  typealias Handle = UnsafeMutablePointer<MockData>
  
  var handle: Handle
  
  init(wrappingTemporarily handle: Handle) {
    self.handle = handle
  }
  
  struct CreationContext {
    var name: String
    var value: Int
    var shouldThrow: Bool
  }
  
  enum CreationError: Error {
    case forcedFailure
  }
  
  static func create(using context: CreationContext) throws -> Handle {
    if context.shouldThrow {
      throw CreationError.forcedFailure
    }
    let pointer = UnsafeMutablePointer<MockData>.allocate(capacity: 1)
    pointer.initialize(to: MockData(name: context.name, value: context.value))
    return pointer
  }
  
  static func destroy(_ handle: Handle) {
    handle.deinitialize(count: 1)
    handle.deallocate()
  }
  
  var value: Int {
    get { handle.pointee.value }
    set { handle.pointee.value = newValue }
  }
}

// MARK: - EntityStore Tests

final class EntityStoreTests: XCTestCase {
  
  // MARK: Creation Tests
  
  func testCreateEntity() throws {
    var store = EntityStore<MockEntity>()
    
    let id = store.create(using: .init(name: "Alice", value: 42))
    
    // Verify entity exists and has correct data
    XCTAssertTrue(store.contains(id))
    store.projecting(id) { entity in
      XCTAssertEqual(entity.name, "Alice")
      XCTAssertEqual(entity.value, 42)
    }
  }
  
  func testCreateMultipleEntities() throws {
    var store = EntityStore<MockEntity>()
    
    // Create three entities with different data
    let id1 = store.create(using: .init(name: "Alice", value: 10))
    let id2 = store.create(using: .init(name: "Bob", value: 20))
    let id3 = store.create(using: .init(name: "Charlie", value: 30))
    
    // All entities should be contained
    XCTAssertTrue(store.contains(id1))
    XCTAssertTrue(store.contains(id2))
    XCTAssertTrue(store.contains(id3))
    
    // Verify each entity retains its own data
    store.projecting(id1) { entity in
      XCTAssertEqual(entity.name, "Alice")
      XCTAssertEqual(entity.value, 10)
    }
    
    store.projecting(id2) { entity in
      XCTAssertEqual(entity.name, "Bob")
      XCTAssertEqual(entity.value, 20)
    }
    
    store.projecting(id3) { entity in
      XCTAssertEqual(entity.name, "Charlie")
      XCTAssertEqual(entity.value, 30)
    }
  }
  
  func testEntityIDsAreUnique() throws {
    var store = EntityStore<MockEntity>()

    let id1 = store.create(using: .init(name: "Alice", value: 10))
    let id2 = store.create(using: .init(name: "Bob", value: 20))
    let id3 = store.create(using: .init(name: "Charlie", value: 30))
    
    XCTAssertNotEqual(id1, id2)
    XCTAssertNotEqual(id2, id3)
    XCTAssertNotEqual(id1, id3)
  }
  
  func testCreateThrowingEntity() throws {
    var store = EntityStore<ThrowingMockEntity>()
    
    // Successful creation
    let id = try store.create(using: .init(name: "Success", value: 10, shouldThrow: false))
    XCTAssertTrue(store.contains(id))
    
    // Failing creation
    XCTAssertThrowsError(
      try store.create(using: .init(name: "Fail", value: 20, shouldThrow: true))
    ) { error in
      XCTAssert(error is ThrowingMockEntity.CreationError)
    }
  }
  
  // MARK: Projection Tests
  
  func testProjectingAllowsReading() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Reader", value: 100))
    
    let name = store.projecting(id) { $0.name }
    let value = store.projecting(id) { $0.value }
    
    XCTAssertEqual(name, "Reader")
    XCTAssertEqual(value, 100)
  }
  
  func testProjectingAllowsModification() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Mutable", value: 50))
    
    // Modify the entity
    store.projecting(id) { entity in
      entity.name = "Modified"
      entity.value = 75
    }
    
    // Verify the changes persisted
    store.projecting(id) { entity in
      XCTAssertEqual(entity.name, "Modified")
      XCTAssertEqual(entity.value, 75)
    }
  }
  
  func testProjectingReturnsValue() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Calculator", value: 5))
    
    let result = store.projecting(id) { entity in
      entity.value * 2
    }
    
    XCTAssertEqual(result, 10)
  }
  
  func testProjectingThrowingClosure() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Thrower", value: -1))
    
    enum TestError: Error {
      case negativeValue
    }
    
    XCTAssertThrowsError(
      try store.projecting(id) { entity in
        if entity.value < 0 {
          throw TestError.negativeValue
        }
      }
    ) { error in
      XCTAssert(error is TestError)
    }
  }
  
  func testProjectingMarksEntityAsNotContained() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Temporary", value: 100))
    
    // Entity should be contained before projection
    XCTAssertTrue(store.contains(id))
    
    // During projection, entity should not be contained
    store.projecting(id) { entity, store in
      XCTAssertFalse(store.contains(id), "Entity should not be contained during projection")
      entity.value = 200
    }
    
    // After projection, entity should be contained again
    XCTAssertTrue(store.contains(id))
    
    // Verify the modification persisted
    store.projecting(id) { entity in
      XCTAssertEqual(entity.value, 200)
    }
  }
  
  func testProjectingWithMultipleEntitiesOnlyMarksTargetAsNotContained() throws {
    var store = EntityStore<MockEntity>()
    let id1 = store.create(using: .init(name: "Entity1", value: 1))
    let id2 = store.create(using: .init(name: "Entity2", value: 2))
    let id3 = store.create(using: .init(name: "Entity3", value: 3))
    
    // All entities should be contained initially
    XCTAssertTrue(store.contains(id1))
    XCTAssertTrue(store.contains(id2))
    XCTAssertTrue(store.contains(id3))
    
    // Project id2 and verify only it is marked as not contained
    store.projecting(id2) { entity, store in
      XCTAssertTrue(store.contains(id1), "id1 should remain contained")
      XCTAssertFalse(store.contains(id2), "id2 should not be contained during projection")
      XCTAssertTrue(store.contains(id3), "id3 should remain contained")
    }
    
    // After projection, all should be contained again
    XCTAssertTrue(store.contains(id1))
    XCTAssertTrue(store.contains(id2))
    XCTAssertTrue(store.contains(id3))
  }
  
  func testProjectingRestoresEntityEvenOnThrow() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "ThrowTest", value: 50))
    
    enum TestError: Error {
      case intentionalError
    }
    
    // Entity should be contained before
    XCTAssertTrue(store.contains(id))
    
    // Projection that throws
    XCTAssertThrowsError(
      try store.projecting(id) { entity, store in
        XCTAssertFalse(store.contains(id))
        entity.value = 99
        throw TestError.intentionalError
      }
    )
    
    // Entity should be restored even after throw
    XCTAssertTrue(store.contains(id))
    
    // Verify modifications before the throw persisted
    store.projecting(id) { entity in
      XCTAssertEqual(entity.value, 99)
    }
  }
  
  // MARK: Contains Tests
  
  func testContainsReturnsTrueForExistingEntity() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Exists", value: 1))
    
    XCTAssertTrue(store.contains(id))
  }
  
  func testContainsReturnsFalseAfterRemoval() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "ToRemove", value: 1))
    
    XCTAssertTrue(store.contains(id))
    store.remove(id)
    XCTAssertFalse(store.contains(id))
  }
  
  // MARK: Removal Tests
  
  func testRemoveEntity() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "ToRemove", value: 555))
    
    // Verify entity exists
    XCTAssertTrue(store.contains(id))
    store.projecting(id) { entity in
      XCTAssertEqual(entity.name, "ToRemove")
    }
    
    // Remove the entity
    store.remove(id)
    
    // Entity should no longer be contained
    XCTAssertFalse(store.contains(id))
  }
  
  func testRemoveOneEntityLeavesOthers() throws {
    var store = EntityStore<MockEntity>()
    
    let keep1 = store.create(using: .init(name: "Keep1", value: 1))
    let entityToRemove = store.create(using: .init(name: "Remove", value: 2))
    let keep2 = store.create(using: .init(name: "Keep2", value: 3))
    
    // Remove middle entity
    XCTAssertTrue(store.contains(entityToRemove))
    store.remove(entityToRemove)
    XCTAssertFalse(store.contains(entityToRemove))
    
    // Verify other entities are still accessible
    XCTAssertTrue(store.contains(keep1))
    XCTAssertTrue(store.contains(keep2))
    
    store.projecting(keep1) { entity in
      XCTAssertEqual(entity.name, "Keep1")
      XCTAssertEqual(entity.value, 1)
    }
    
    store.projecting(keep2) { entity in
      XCTAssertEqual(entity.name, "Keep2")
      XCTAssertEqual(entity.value, 3)
    }
  }
  
  // MARK: Complex Workflow Tests
  
  func testComplexWorkflow() throws {
    var store = EntityStore<MockEntity>()
    
    // Create a batch of entities
    var entities: [MockEntity.ID] = []
    for i in 0..<5 {
      let id = store.create(using: .init(name: "Entity\(i)", value: i * 10))
      entities.append(id)
    }
    
    // Verify all entities are contained
    for id in entities {
      XCTAssertTrue(store.contains(id))
    }
    
    // Modify entities using projection
    for id in entities {
      store.projecting(id) { entity in
        entity.value += 5  // Add 5 to each value
      }
    }
    
    // Modify one entity with special values
    store.projecting(entities[2]) { entity in
      entity.name = "Special"
      entity.value = 1000
    }
    
    // Remove some entities
    store.remove(entities[0])
    store.remove(entities[4])
    
    // Verify removed entities are not contained
    XCTAssertFalse(store.contains(entities[0]))
    XCTAssertFalse(store.contains(entities[4]))
    
    // Verify remaining entities are contained and have correct values
    XCTAssertTrue(store.contains(entities[1]))
    store.projecting(entities[1]) { entity in
      XCTAssertEqual(entity.name, "Entity1")
      XCTAssertEqual(entity.value, 15)  // 10 + 5
    }
    
    XCTAssertTrue(store.contains(entities[2]))
    store.projecting(entities[2]) { entity in
      XCTAssertEqual(entity.name, "Special")
      XCTAssertEqual(entity.value, 1000)
    }
    
    XCTAssertTrue(store.contains(entities[3]))
    store.projecting(entities[3]) { entity in
      XCTAssertEqual(entity.name, "Entity3")
      XCTAssertEqual(entity.value, 35)  // 30 + 5
    }
  }
  
  func testEntityIDHashability() throws {
    var store = EntityStore<MockEntity>()
    
    let id1 = store.create(using: .init(name: "Hashable", value: 0))
    let id2 = store.create(using: .init(name: "Hashable", value: 0))
    
    // Test that IDs can be used in Sets and Dictionaries
    let idSet: Set<EntityID<MockEntity>> = [id1, id2]
    XCTAssertEqual(idSet.count, 2)
    XCTAssertTrue(idSet.contains(id1))
    XCTAssertTrue(idSet.contains(id2))
    
    var idDict: [EntityID<MockEntity>: String] = [:]
    idDict[id1] = "First"
    idDict[id2] = "Second"
    XCTAssertEqual(idDict[id1], "First")
    XCTAssertEqual(idDict[id2], "Second")
  }
  
  // MARK: Edge Cases
  
  func testCreateWithEmptyStore() throws {
    var store = EntityStore<MockEntity>()
    
    let id = store.create(using: .init(name: "First", value: 1))
    
    XCTAssertTrue(store.contains(id))
    store.projecting(id) { entity in
      XCTAssertEqual(entity.name, "First")
      XCTAssertEqual(entity.value, 1)
    }
  }
  
  func testMultipleProjectionsOnSameEntity() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Multi", value: 10))
    
    // First projection
    let result1 = store.projecting(id) { entity in
      entity.value * 2
    }
    XCTAssertEqual(result1, 20)
    
    // Second projection - entity should be contained between projections
    XCTAssertTrue(store.contains(id))
    store.projecting(id) { entity in
      entity.value = 50
    }
    
    // Third projection to verify
    XCTAssertTrue(store.contains(id))
    let result2 = store.projecting(id) { entity in
      entity.value
    }
    XCTAssertEqual(result2, 50)
  }
  
  func testNestedProjectionsDifferentEntities() throws {
    var store = EntityStore<MockEntity>()
    let id1 = store.create(using: .init(name: "Outer", value: 1))
    let id2 = store.create(using: .init(name: "Inner", value: 2))
    
    // Nested projections should work as long as they're on different entities
    store.projecting(id1) { entity1, store in
      XCTAssertEqual(entity1.value, 1)
      XCTAssertFalse(store.contains(id1))
      XCTAssertTrue(store.contains(id2))
      
      store.projecting(id2) { entity2, store in
        XCTAssertEqual(entity2.value, 2)
        XCTAssertFalse(store.contains(id1))
        XCTAssertFalse(store.contains(id2))
      }
      
      XCTAssertTrue(store.contains(id2))
    }
    
    XCTAssertTrue(store.contains(id1))
    XCTAssertTrue(store.contains(id2))
  }
  
  // MARK: Subscript Tests
  
  func testSubscriptReadAccess() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "ReadTest", value: 123))
    
    // Test read access using subscript
    let name = store[id].name
    let value = store[id].value
    
    XCTAssertEqual(name, "ReadTest")
    XCTAssertEqual(value, 123)
  }
  
  func testSubscriptModifyAccess() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "ModifyTest", value: 50))
    
    // Test modify access using subscript
    store[id].name = "Modified"
    store[id].value = 100
    
    // Verify changes persisted
    XCTAssertEqual(store[id].name, "Modified")
    XCTAssertEqual(store[id].value, 100)
  }
  
  func testSubscriptUsedInComputation() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Compute", value: 10))
    
    // Use subscript in computation
    let doubled = store[id].value * 2
    XCTAssertEqual(doubled, 20)
    
    // Modify via subscript with compound assignment
    store[id].value += 5
    XCTAssertEqual(store[id].value, 15)
  }
  
  func testSubscriptMarksEntityAsNotContained() throws {
    var store = EntityStore<MockEntity>()
    let id1 = store.create(using: .init(name: "Entity1", value: 1))
    let id2 = store.create(using: .init(name: "Entity2", value: 2))
    
    XCTAssertTrue(store.contains(id1))
    XCTAssertTrue(store.contains(id2))
    
    // Access via subscript - entity should be temporarily extracted
    store.projecting(id1) { entity, store in
      // During projection of id1, try to access id2 via subscript
      let value = store[id2].value
      XCTAssertEqual(value, 2)
      XCTAssertFalse(store.contains(id1))
      XCTAssertTrue(store.contains(id2))  // id2 should be back after subscript access
    }
  }
  
  func testMultipleSubscriptAccesses() throws {
    var store = EntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Multiple", value: 10))
    
    // Multiple subscript accesses in sequence
    let value1 = store[id].value
    XCTAssertEqual(value1, 10)
    
    store[id].value = 20
    
    let value2 = store[id].value
    XCTAssertEqual(value2, 20)
    
    store[id].value += 5
    
    let value3 = store[id].value
    XCTAssertEqual(value3, 25)
  }
}

// MARK: - BidirectionalEntityStore Tests

final class BidirectionalEntityStoreTests: XCTestCase {
  
  // MARK: Creation and Basic Operations
  
  func testCreateEntity() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    
    let id = store.create(using: .init(name: "Alice", value: 42))
    
    XCTAssertTrue(store.contains(id))
    store.projecting(id) { entity in
      XCTAssertEqual(entity.name, "Alice")
      XCTAssertEqual(entity.value, 42)
    }
  }
  
  func testIDForHandle() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    
    let id = store.create(using: .init(name: "Test", value: 100))
    
    // Get the handle during projection
    var handle: MockEntity.Handle?
    store.projecting(id) { entity in
      handle = entity.handle
    }
    
    // Verify we can look up the ID from the handle
    let retrievedID = store.id(for: handle!)
    XCTAssertEqual(retrievedID, id)
  }
  
  func testContainsHandle() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    
    let id = store.create(using: .init(name: "Test", value: 100))
    
    var handle: MockEntity.Handle?
    store.projecting(id) { entity in
      handle = entity.handle
    }
    
    XCTAssertTrue(store.contains(handle: handle!))
  }
  
  func testRemoveEntityCleansUpHandleMapping() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    
    let id = store.create(using: .init(name: "ToRemove", value: 50))
    
    var handle: MockEntity.Handle?
    store.projecting(id) { entity in
      handle = entity.handle
    }
    
    // Before removal
    XCTAssertTrue(store.contains(id))
    XCTAssertTrue(store.contains(handle: handle!))
    XCTAssertEqual(store.id(for: handle!), id)
    
    // Remove entity
    store.remove(id)
    
    // After removal
    XCTAssertFalse(store.contains(id))
    XCTAssertFalse(store.contains(handle: handle!))
    XCTAssertNil(store.id(for: handle!))
  }
  
  func testProjectingByHandle() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    
    let id = store.create(using: .init(name: "HandleTest", value: 77))
    
    var handle: MockEntity.Handle?
    store.projecting(id) { entity in
      handle = entity.handle
    }
    
    // Project using handle
    let value = store.projecting(handle: handle!) { entity in
      entity.value
    }
    
    XCTAssertEqual(value, 77)
    
    // Modify using handle
    store.projecting(handle: handle!) { entity in
      entity.value = 99
    }
    
    // Verify modification persisted
    let newValue = store.projecting(id) { entity in
      entity.value
    }
    XCTAssertEqual(newValue, 99)
  }
  
  func testMultipleEntitiesWithHandleLookup() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    
    let id1 = store.create(using: .init(name: "Entity1", value: 10))
    let id2 = store.create(using: .init(name: "Entity2", value: 20))
    let id3 = store.create(using: .init(name: "Entity3", value: 30))
    
    // Get all handles
    var handles: [MockEntity.Handle] = []
    for id in [id1, id2, id3] {
      store.projecting(id) { entity in
        handles.append(entity.handle)
      }
    }
    
    // Verify each handle maps to correct ID
    XCTAssertEqual(store.id(for: handles[0]), id1)
    XCTAssertEqual(store.id(for: handles[1]), id2)
    XCTAssertEqual(store.id(for: handles[2]), id3)
  }
  
  // MARK: Subscript Tests by ID
  
  func testSubscriptByIDReadAccess() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    let id = store.create(using: .init(name: "ReadTest", value: 456))
    
    // Test read access using subscript
    let name = store[id].name
    let value = store[id].value
    
    XCTAssertEqual(name, "ReadTest")
    XCTAssertEqual(value, 456)
  }
  
  func testSubscriptByIDModifyAccess() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    let id = store.create(using: .init(name: "ModifyTest", value: 200))
    
    // Test modify access using subscript
    store[id].name = "Modified"
    store[id].value = 250
    
    // Verify changes persisted
    XCTAssertEqual(store[id].name, "Modified")
    XCTAssertEqual(store[id].value, 250)
  }
  
  func testSubscriptByIDMultipleAccesses() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Multiple", value: 100))
    
    // Multiple subscript accesses
    let initial = store[id].value
    XCTAssertEqual(initial, 100)
    
    store[id].value = 150
    XCTAssertEqual(store[id].value, 150)
    
    store[id].value += 25
    XCTAssertEqual(store[id].value, 175)
  }
  
  // MARK: Subscript Tests by Handle
  
  func testSubscriptByHandleReadAccess() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    let id = store.create(using: .init(name: "HandleRead", value: 789))
    
    var handle: MockEntity.Handle?
    store.projecting(id) { entity in
      handle = entity.handle
    }
    
    // Test read access using handle subscript
    let name = store[handle!].name
    let value = store[handle!].value
    
    XCTAssertEqual(name, "HandleRead")
    XCTAssertEqual(value, 789)
  }
  
  func testSubscriptByHandleModifyAccess() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    let id = store.create(using: .init(name: "HandleModify", value: 300))
    
    var handle: MockEntity.Handle?
    store.projecting(id) { entity in
      handle = entity.handle
    }
    
    // Test modify access using handle subscript
    store[handle!].name = "ModifiedViaHandle"
    store[handle!].value = 400
    
    // Verify changes persisted (check via ID)
    XCTAssertEqual(store[id].name, "ModifiedViaHandle")
    XCTAssertEqual(store[id].value, 400)
  }
  
  func testSubscriptByHandleMixedWithIDAccess() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Mixed", value: 500))
    
    var handle: MockEntity.Handle?
    store.projecting(id) { entity in
      handle = entity.handle
    }
    
    // Mix handle and ID subscript access
    store[id].value = 600
    XCTAssertEqual(store[handle!].value, 600)
    
    store[handle!].value = 700
    XCTAssertEqual(store[id].value, 700)
    
    store[id].name = "Updated"
    XCTAssertEqual(store[handle!].name, "Updated")
  }
  
  func testSubscriptByHandleMultipleEntities() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    
    let id1 = store.create(using: .init(name: "First", value: 1))
    let id2 = store.create(using: .init(name: "Second", value: 2))
    
    var handle1: MockEntity.Handle?
    var handle2: MockEntity.Handle?
    
    store.projecting(id1) { entity in
      handle1 = entity.handle
    }
    store.projecting(id2) { entity in
      handle2 = entity.handle
    }
    
    // Access different entities via their handles
    XCTAssertEqual(store[handle1!].name, "First")
    XCTAssertEqual(store[handle2!].name, "Second")
    
    // Modify via handle subscripts
    store[handle1!].value = 10
    store[handle2!].value = 20
    
    // Verify via ID subscripts
    XCTAssertEqual(store[id1].value, 10)
    XCTAssertEqual(store[id2].value, 20)
  }
  
  func testSubscriptHandleLookupMaintainedAfterModification() throws {
    var store = BidirectionalEntityStore<MockEntity>()
    let id = store.create(using: .init(name: "Lookup", value: 999))
    
    var handle: MockEntity.Handle?
    store.projecting(id) { entity in
      handle = entity.handle
    }
    
    // Modify several times
    store[id].value = 100
    store[handle!].value = 200
    store[id].value = 300
    
    // Verify handle-to-ID mapping still works
    XCTAssertEqual(store.id(for: handle!), id)
    XCTAssertTrue(store.contains(handle: handle!))
    XCTAssertEqual(store[handle!].value, 300)
  }
}
