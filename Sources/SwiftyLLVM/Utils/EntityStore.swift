/// Manages the lifecycle of entities of a given type, allowing
/// temporary extraction and restoration of entities.
public struct EntityStore<Entity: LLVMEntity>: ~Copyable {

  /// The ever-growing list of entity handles, identified by their index in the list via `Entity.ID`.
  ///
  /// Note: There is no reuse of indices except for borrowing an entity for temporary use.
  private var handles: [Entity.Handle?] = []

  /// Creates a new empty entity store.
  public init() {}

  /// Inserts an entity handle into the store and starts managing it, returning its new ID.
  ///
  /// Precondition: `handle` must not be already managed by this store.
  internal mutating func insert(_ handle: Entity.Handle) -> Entity.ID {
    let id = Entity.ID(uncheckedFrom: .init(handles.count))
    handles.append(handle)
    return id
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
  internal mutating func unsafeExtract(_ id: Entity.ID) -> Entity.Handle {
    guard let handle = handle(for: id) else {
      fatalError("Attempting to extract entity with ID \(id) that is not present in the store.")
    }

    handles[Int(id.raw)] = nil
    return handle
  }

  /// Restores an entity with given `id` and `handle` to the store.
  ///
  /// - Requires: Entity with `id` has been extracted from this store and not yet
  ///   been restored since the last extraction.
  internal mutating func unsafeRestore(_ id: Entity.ID, _ handle: Entity.Handle) {
    guard self.handle(for: id) == nil else {
      fatalError("Attempting to restore entity with ID \(id) that is already present in the store.")
    }

    handles[Int(id.raw)] = handle
  }

  /// Checks if the store contains an entity with given `id`.
  ///
  /// Note: Temporarily extracted entities are not considered to be contained.
  public func contains(_ id: Entity.ID) -> Bool {
    guard id.raw < handles.count else { return false }
    return handles[Int(id.raw)] != nil
  }

  /// Returns the handle of the entity with given `id`, if it is present in the store.
  public func handle(for id: Entity.ID) -> Entity.Handle? {
    guard contains(id) else { return nil }
    return handles[Int(id.raw)]
  }
}
