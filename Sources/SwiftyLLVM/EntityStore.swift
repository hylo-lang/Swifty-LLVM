/// Manages the lifecycle of entities of a given type, allowing
/// temporary extraction and restoration of entities.
public struct EntityStore<Entity: EntityView>: ~Copyable {

  /// The ever-growing list of entity handles, identified by their index in the list via `Entity.ID`.
  ///
  /// Note: There is no reuse of indices except for borrowing an entity for temporary use.
  private var handles: [Entity.Handle?] = []

  /// Creates a new empty entity store.
  public init() {}

  /// Destroys all remaining entities in the store.
  deinit {
    for handle in handles {
      if let h = handle {
        Entity.destroy(h)
      }
    }
  }

  /// Creates a new entity in the store, returning its ID.
  public mutating func create(using context: inout Entity.CreationContext) throws -> Entity.ID
  where Entity: EntityViewWithMutableThrowingCreationContext {
    let id = Entity.ID(handles.count)
    let handle = try Entity.create(using: &context)
    handles.append(handle)
    return id
  }

  /// Creates a new entity in the store, returning its ID.
  public mutating func create(using context: inout Entity.CreationContext) -> Entity.ID
  where Entity: EntityViewWithMutableNonThrowingCreationContext {
    let id = Entity.ID(handles.count)
    let handle = Entity.create(using: &context)
    handles.append(handle)
    return id
  }

  /// Creates a new entity in the store, returning its ID.
  public mutating func create(using context: Entity.CreationContext) throws -> Entity.ID
  where Entity: EntityViewWithImmutableThrowingCreationContext {
    let id = Entity.ID(handles.count)
    let handle = try Entity.create(using: context)
    handles.append(handle)
    return id
  }

  /// Creates a new entity in the store, returning its ID.
  public mutating func create(using context: Entity.CreationContext) -> Entity.ID
  where Entity: EntityViewWithImmutableNonThrowingCreationContext {
    let id = Entity.ID(handles.count)
    let handle = Entity.create(using: context)
    handles.append(handle)
    return id
  }

  /// Removes and destroys the entity in the store with the given `id`.
  ///
  /// - Requires: Entity with `id` is present in the store.
  public mutating func remove(_ id: Entity.ID) {
    guard let handle = handles[id.raw] else {
      fatalError("Attempting to remove entity with ID \(id) that is not present in the store.")
    }

    Entity.destroy(handle)
    handles[id.raw] = nil
  }

  /// Extracts the entity with given `id` for the duration of `witness`.
  ///
  /// - Requires: Entity with `id` is present in the store.
  public mutating func projecting<R>(_ id: Entity.ID, _ witness: (inout Entity) throws -> R)
    rethrows -> R
  {
    let handle = extract(id)
    var entity = Entity(wrappingTemporarily: handle)
    defer { restore(id, handle) }  // Safety: Required to be run even if `witness` throws.
    return try witness(&entity)
  }

  /// Extracts the entity with given `id` for the duration of `witness`.
  ///
  /// - Requires: Entity with `id` is present in the store.
  public mutating func projecting<R>(
    _ id: Entity.ID, _ witness: (inout Entity, inout Self) throws -> R
  )
    rethrows -> R
  {
    let handle = extract(id)
    var entity = Entity(wrappingTemporarily: handle)
    defer { restore(id, handle) }  // Safety: Required to be run even if `witness` throws.
    return try witness(&entity, &self)
  }

  /// Extracts the entity with given `id` for temporary use, without destroying it.
  ///
  /// - Requires: Entity with `id` is present in the store.
  fileprivate mutating func extract(_ id: Entity.ID) -> Entity.Handle {
    guard let handle = handles[id.raw] else {
      fatalError("Attempting to extract entity with ID \(id) that is not present in the store.")
    }

    handles[id.raw] = nil
    return handle
  }

  /// Restores an entity with given `id` and `handle` to the store.
  ///
  /// - Requires: Entity with `id` has been extracted from the store and not yet
  ///   been restored since the last extraction.
  fileprivate mutating func restore(_ id: Entity.ID, _ handle: Entity.Handle) {
    guard handles[id.raw] == nil else {
      fatalError("Attempting to restore entity with ID \(id) that is already present in the store.")
    }

    handles[id.raw] = handle
  }

  /// Checks if the store contains an entity with given `id`.
  ///
  /// Note: Temporarily extracted entities are not considered to be contained.
  public func contains(_ id: Entity.ID) -> Bool {
    guard id.raw < handles.count else { return false }
    return handles[id.raw] != nil
  }
}

/// A temporary wrapper view around a native handle managed by an `EntityStore`.
public protocol EntityView: ~Copyable {
  /// The native handle being wrapped by the entity, e.g. a pointer.
  associatedtype Handle: Equatable

  /// Wraps a handle for temporary use as an instance of `Self`.
  init(wrappingTemporarily handle: Handle)

  /// Data required to create the underlying instance of `Self`.
  associatedtype CreationContext

  /// Destroys an instance with the given `handle`.
  static func destroy(_ handle: Handle)
}

public protocol EntityViewWithImmutableThrowingCreationContext: EntityView {
  /// Creates a new instance to be inserted into the store, handing off ownership via the returned handle.
  static func create(using context: CreationContext) throws -> Handle
}

public protocol EntityViewWithMutableThrowingCreationContext: EntityView {
  /// Creates a new instance to be inserted into the store, handing off ownership via the returned handle.
  static func create(using context: inout CreationContext) throws -> Handle
}

public protocol EntityViewWithImmutableNonThrowingCreationContext: EntityView {
  /// Creates a new instance to be inserted into the store, handing off ownership via the returned handle.
  static func create(using context: CreationContext) -> Handle
}

public protocol EntityViewWithMutableNonThrowingCreationContext: EntityView {
  /// Creates a new instance to be inserted into the store, handing off ownership via the returned handle.
  static func create(using context: inout CreationContext) -> Handle
}

/// Shorthand for entities that don't require any context to create.
extension EntityViewWithImmutableThrowingCreationContext where CreationContext == () {
  /// Creates a new entity in the store and returns its handle.
  static func create() throws -> Handle {
    return try create(using: ())
  }
}

/// Shorthand for entities that don't require any context to create.
extension EntityViewWithImmutableNonThrowingCreationContext where CreationContext == () {
  /// Creates a new entity in the store and returns its handle.
  static func create() -> Handle {
    return create(using: ())
  }
}

/// Identifies an entity of given type in an `EntityStore`.
public struct EntityID<Entity: EntityView>: Hashable, Sendable {
  fileprivate let raw: Int

  /// Forms a new entity ID with the given raw value.
  fileprivate init(_ raw: Int) {
    self.raw = raw
  }
}

extension EntityView {
  /// The identity of an instance of `Self`.
  public typealias ID = EntityID<Self>
}
