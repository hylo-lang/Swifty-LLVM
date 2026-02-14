
/// Extends `EntityStore` with bidirectional Handle↔ID lookup.
///
/// Use this when you frequently need to look up entity IDs from handles,
/// such as when interoperating with C APIs that return opaque pointers.
public struct BidirectionalEntityStore<Entity: EntityView>: ~Copyable where Entity.Handle: Hashable {
  private var store = EntityStore<Entity>()
  /// The id for each handle present in the store.
  ///
  /// Note: Elements are removed while the entity is in use since it gets temporarily extracted.
  private var handleToID: [Entity.Handle: Entity.ID] = [:]

  /// Creates an empty entity store.
  public init() {}

  /// Inserts an entity handle into the store and returns its ID.
  /// 
  /// Precondition: `handle` must not be already managed by this store.
  public mutating func insert(_ handle: Entity.Handle) -> Entity.ID {
    precondition(!handleToID.keys.contains(handle), "Attempting to insert an already present handle.")
    let id = store.insert(handle)
    handleToID[handle] = id
    return id
  }

  /// Removes and destroys the entity in the store with the given `id`.
  ///
  /// - Requires: Entity with `id` is present in the store.
  public mutating func remove(_ id: Entity.ID) {
    handleToID.removeValue(forKey: store.handle(for: id)!)
    store.remove(id)
  }

  /// Extracts the entity with given `id` for the duration of `witness`.
  ///
  /// - Requires: Entity with `id` is present in the store.
  public mutating func projecting<R>(_ id: Entity.ID, _ witness: (inout Entity) throws -> R)
    rethrows -> R
  {
    let handle = store.handle(for: id)!
    handleToID.removeValue(forKey: handle)
    defer { handleToID[handle] = id }  // Safety: Required to be run even if `witness` throws.
    return try store.projecting(id, witness)
  }

  /// Extracts the entity with given `id` for the duration of `witness`.
  ///
  /// - Requires: Entity with `id` is present in the store.
  public mutating func projecting<R>(
    _ id: Entity.ID, _ witness: (inout Entity, inout Self) throws -> R
  )
    rethrows -> R
  {
    let e = unsafeExtract(id)
    defer { unsafeRestore(id, e) }  // Safety: Required to be run even if `witness` throws.
    var entity = Entity(wrappingTemporarily: e)
    return try witness(&entity, &self)
  }

  /// Temporarily extracts and projects the entity with given `id`.
  public subscript(_ id: Entity.ID) -> Entity {
    mutating _read {
      let handle = store.handle(for: id)!
      handleToID.removeValue(forKey: handle)
      defer { handleToID[handle] = id }  // Safety: Required to be run even if the caller throws.
      yield store[id]
    }
    _modify {
      let handle = store.handle(for: id)!
      handleToID.removeValue(forKey: handle)
      defer { handleToID[handle] = id }  // Safety: Required to be run even if the caller throws.
      yield &store[id]
    }
  }

  /// Extracts the entity with given `id` for temporary use, without destroying it.
  ///
  /// - Requires: Entity with `id` is present in the store.
  /// - Note: You must either restore the handle or destroy it yourself to avoid leaking resources.
  public mutating func unsafeExtract(_ id: Entity.ID) -> Entity.Handle {
    let handle = store.unsafeExtract(id)
    handleToID.removeValue(forKey: handle)
    return handle
  }

  /// Restores an entity with given `id` and `handle` to the store.
  ///
  /// - Requires: 
  ///   - Entity with `id` has been extracted from this store and not yet
  ///     been restored since the last extraction.
  ///   - `id` used to correspond to the given `handle` before extraction.
  public mutating func unsafeRestore(_ id: Entity.ID, _ handle: Entity.Handle) {
    store.unsafeRestore(id, handle)
    handleToID[handle] = id
  }

  /// Returns true iff the store contains an entity with given `id`.
  public func contains(_ id: Entity.ID) -> Bool {
    store.contains(id)
  }

  /// Returns true iff the store contains an entity with given `handle`.
  public func contains(handle: Entity.Handle) -> Bool {
    handleToID.keys.contains(handle)
  }

  /// Returns the ID of the entity with given `handle`, if it is present in the store.
  public func id(for handle: Entity.Handle) -> Entity.ID? {
    handleToID[handle]
  }
}

extension BidirectionalEntityStore {
  /// Extracts the entity with given `handle` for the duration of `witness`.
  ///
  /// - Requires: Entity with `handle` is present in the store.
  public mutating func projecting<R>(
    handle: Entity.Handle,
    _ witness: (inout Entity) throws -> R
  ) rethrows -> R {
    guard let id = id(for: handle) else {
      fatalError("Handle not in store.")
    }
    return try projecting(id, witness)
  }

  /// Extracts the entity with given `handle` for the duration of `witness`.
  /// 
  /// - Requires: Entity with `handle` is present in the store.
  public mutating func projecting<R>(
    handle: Entity.Handle,
    _ witness: (inout Entity, inout Self) throws -> R
  ) rethrows -> R {
    guard let id = id(for: handle) else {
      fatalError("Handle not in store.")
    }
    return try projecting(id, witness)
  }

  /// Temporarily extracts and projects the entity with given `handle`.
  public subscript(handle: Entity.Handle) -> Entity {
    mutating _read {
      guard let id = id(for: handle) else {
        fatalError("Handle not in store.")
      }
      yield store[id]
    }
    _modify {
      guard let id = id(for: handle) else {
        fatalError("Handle not in store.")
      }
      yield &store[id]
    }
  }
}
