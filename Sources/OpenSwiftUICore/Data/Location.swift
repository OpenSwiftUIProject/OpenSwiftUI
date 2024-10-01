//
//  Location.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete
//  ID: 3C10A6E9BB0D4644A364890A9BD57D68

// MARK: - Location

package protocol Location<Value>: Equatable {
    associatedtype Value
    var wasRead: Bool { get set }
    func get() -> Value
    func set(_ value: Value, transaction: Transaction)
    func update() -> (Value, Bool)
}

extension Location {
    package func update() -> (Value, Bool) {
        (get(), true)
    }
}

// MARK: - AnyLocationBase

/// The base type of all type-erased locations.
@_documentation(visibility: private)
open class AnyLocationBase {}

@available(*, unavailable)
extension AnyLocationBase: Sendable {}

// MARK: - AnyLocation

/// The base type of all type-erased locations with value-type Value.
/// It is annotated as `@unchecked Sendable` so that user types such as
/// `State`, and `SceneStorage` can be cleanly `Sendable`. However, it is
/// also the user types' responsibility to ensure that `get`, and `set` does
/// not access the graph concurrently (`get` should not be called while graph
/// is updating, for example).
@_documentation(visibility: private)
open class AnyLocation<Value>: AnyLocationBase, @unchecked Sendable {
    @_spi(ForOpenSwiftUIOnly)
    open var wasRead: Bool {
        get { fatalError() }
        set { fatalError() }
    }
    
    @_spi(ForOpenSwiftUIOnly)
    open func get() -> Value { fatalError() }
    
    @_spi(ForOpenSwiftUIOnly)
    open func set(_ value: Value, transaction: Transaction) { fatalError() }
    
    @_spi(ForOpenSwiftUIOnly)
    open func projecting<P>(_ projection: P) -> AnyLocation<P.Projected> where Value == P.Base, P: Projection {
        fatalError()
    }
    
    @_spi(ForOpenSwiftUIOnly)
    open func update() -> (Value, Bool) { fatalError() }
    
    @_spi(ForOpenSwiftUIOnly)
    open func isEqual(to other: AnyLocation<Value>) -> Bool { self === other }
    
    package override init() {
        super.init()
    }
}

extension AnyLocation: Equatable {
    public static func == (lhs: AnyLocation<Value>, rhs: AnyLocation<Value>) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

@available(*, unavailable)
extension AnyLocation: Sendable {}

// MARK: - LocationBox

final package class LocationBox<L>: AnyLocation<L.Value>, Location, @unchecked Sendable where L: Location {
    final internal(set) package var location: L
    
    @AtomicBox
    var cache = LocationProjectionCache()

    package init(_ location: L) {
        self.location = location
    }

    override final package var wasRead: Bool {
        get { location.wasRead }
        set { location.wasRead = newValue }
    }

    override final package func get() -> L.Value {
        location.get()
    }

    override final package func set(_ value: L.Value, transaction: Transaction) {
        location.set(value, transaction: transaction)
    }

    override final package func projecting<P>(_ projection: P) -> AnyLocation<P.Projected> where P: Projection, L.Value == P.Base {
        cache.reference(for: projection, on: location)
    }

    override final package func update() -> (L.Value, Bool) {
        location.update()
    }
    
    override final package func isEqual(to other: AnyLocation<L.Value>) -> Bool {
        // TODO: Blocked by Semantics.v5
        if _SemanticFeature_v5.isEnabled {
            if let otherBox = other as? LocationBox<L> {
                location == otherBox.location
            } else {
                false
            }
        } else {
            other === self
        }
    }
    
    package typealias Value = L.Value
}

// MARK: - LocationProjectionCache

package struct LocationProjectionCache {
    var cache: [AnyHashable: WeakBox<AnyLocationBase>]
    
    package mutating func reference<P, L>(for projection: P, on location: L) -> AnyLocation<P.Projected> where P: Projection, L: Location, P.Base == L.Value {
        if let box = cache[projection],
           let base = box.base,
           let result = base as? AnyLocation<P.Projected> {
            return result
        } else {
            let projectedLocation = ProjectedLocation(location: location, projection: projection)
            let box = LocationBox(projectedLocation)
            cache[projection as AnyHashable] = WeakBox(box)
            return box
        }
    }
    package mutating func reset() {
        cache = [:]
    }
    
    package init() {
        cache = [:]
    }
}

private struct ProjectedLocation<L: Location, P: Projection>: Location where P.Base == L.Value {
    var location: L
    var projection: P

    init(location: L, projection: P) {
        self.location = location
        self.projection = projection
    }

    typealias Value = P.Projected

    var wasRead: Bool {
        get { location.wasRead }
        set { location.wasRead = newValue }
    }

    func get() -> Value { projection.get(base: location.get()) }

    func set(_ value: Value, transaction _: Transaction) {
        var base = location.get()
        projection.set(base: &base, newValue: value)
    }

    func update() -> (Value, Bool) {
        let (base, result) = location.update()
        let value = projection.get(base: base)
        return (value, result)
    }
}

// MARK: - FlattenedCollectionLocation

package struct FlattenedCollectionLocation<Value, Base>: Location where Base: Collection, Base: Equatable, Base.Element: AnyLocation<Value> {
    package typealias Value = Value
    
    package let base: Base
    
    package init(base: [AnyLocation<Value>]) {
        self.base = base as! Base
    }
    
    private var primaryLocation: Base.Element { base.first! }
    
    package var wasRead: Bool {
        get { primaryLocation.wasRead }
        set { primaryLocation.wasRead = newValue }
    }
    
    package func get() -> Value {
        primaryLocation.get()
    }
    
    package func set(_ newValue: Value, transaction: Transaction) {
        for location in base {
            location.set(newValue, transaction: transaction)
        }
    }
    
    package func update() -> (Value, Bool) {
        primaryLocation.update()
    }
}
