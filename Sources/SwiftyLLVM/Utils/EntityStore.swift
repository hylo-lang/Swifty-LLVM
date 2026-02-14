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

  /// Inserts an entity handle into the store and starts managing it, returning its new ID.
  /// 
  /// Precondition: `handle` must not be already managed by this store.
  public mutating func insert(_ handle: Entity.Handle) -> Entity.ID {
    let id = Entity.ID(handles.count)
    handles.append(handle)
    return id
  }

  /// Removes and destroys the entity in the store with the given `id`.
  ///
  /// - Requires: Entity with `id` is present in the store.
  public mutating func remove(_ id: Entity.ID) {
    guard let handle = handle(for: id) else {
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
    let handle = unsafeExtract(id)
    var entity = Entity(wrappingTemporarily: handle)
    defer { unsafeRestore(id, handle) }  // Safety: Required to be run even if `witness` throws.
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
    let handle = unsafeExtract(id)
    var entity = Entity(wrappingTemporarily: handle)
    defer { unsafeRestore(id, handle) }  // Safety: Required to be run even if `witness` throws.
    return try witness(&entity, &self)
  }

  /// Temporarily extracts and projects the entity with given `id`.
  public subscript(_ id: Entity.ID) -> Entity {
    mutating _read {
      let handle = unsafeExtract(id)
      defer { unsafeRestore(id, handle) }
      yield Entity(wrappingTemporarily: handle)
    }
    _modify {
      let handle = unsafeExtract(id)
      var entity = Entity(wrappingTemporarily: handle)
      defer { unsafeRestore(id, handle) }
      yield &entity
    }
  }

  /// Extracts the entity with given `id` for temporary use, without destroying it.
  ///
  /// - Requires: Entity with `id` is present in the store.
  /// - Note: You must either restore the handle or destroy it yourself to avoid leaking resources.
  public mutating func unsafeExtract(_ id: Entity.ID) -> Entity.Handle {
    guard let handle = handle(for: id) else {
      fatalError("Attempting to extract entity with ID \(id) that is not present in the store.")
    }

    handles[id.raw] = nil
    return handle
  }

  /// Restores an entity with given `id` and `handle` to the store.
  ///
  /// - Requires: Entity with `id` has been extracted from this store and not yet
  ///   been restored since the last extraction.
  public mutating func unsafeRestore(_ id: Entity.ID, _ handle: Entity.Handle) {
    guard self.handle(for: id) == nil else {
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

  /// Returns the handle of the entity with given `id`, if it is present in the store.
  public func handle(for id: Entity.ID) -> Entity.Handle? {
    guard contains(id) else { return nil }
    return handles[id.raw]
  }
}

/// A temporary wrapper view around a native handle managed by an `EntityStore`.
public protocol EntityView: ~Copyable {
  /// The native handle being wrapped by the entity, e.g. a pointer.
  associatedtype Handle: Equatable

  /// Wraps a handle for temporary use as an instance of `Self`.
  init(wrappingTemporarily handle: Handle)

  /// Destroys an instance with the given `handle`.
  static func destroy(_ handle: Handle)
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
