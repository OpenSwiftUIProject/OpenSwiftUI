//
//  Location.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3C10A6E9BB0D4644A364890A9BD57D68 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Location

/// A protocol representing a location that stores and manages a value with transaction support.
///
/// `Location` types provide a unified interface for reading and writing values
/// with optional change tracking through transactions.
package protocol Location<Value>: Equatable {
    associatedtype Value
    
    /// Indicates whether the location has been read.
    var wasRead: Bool { get set }
    
    /// Retrieves the current value from the location.
    ///
    /// - Returns: The current value stored at this location.
    func get() -> Value
    
    /// Sets a new value at the location within a transaction.
    ///
    /// - Parameters:
    ///   - value: The new value to store.
    ///   - transaction: The transaction context for the update.
    func set(_ value: Value, transaction: Transaction)
    
    /// Updates and retrieves the current value with change status.
    ///
    /// - Returns: A tuple containing the current value and a boolean indicating whether the value changed.
    func update() -> (Value, Bool)
}

extension Location {
    package func update() -> (Value, Bool) {
        (get(), true)
    }
}

// MARK: - AnyLocationBase

/// The base type of all type-erased locations.
@available(OpenSwiftUI_v1_0, *)
@_documentation(visibility: private)
open class AnyLocationBase {
    init() {
        _openSwiftUIEmptyStub()
    }
}

@available(*, unavailable)
extension AnyLocationBase: Sendable {}

// MARK: - AnyLocation

/// The base type of all type-erased locations with value-type Value.
/// It is annotated as `@unchecked Sendable` so that user types such as
/// `State`, and `SceneStorage` can be cleanly `Sendable`. However, it is
/// also the user types' responsibility to ensure that `get`, and `set` does
/// not access the graph concurrently (`get` should not be called while graph
/// is updating, for example).
@available(OpenSwiftUI_v1_0, *)
@_documentation(visibility: private)
open class AnyLocation<Value>: AnyLocationBase, @unchecked Sendable {
    @_spi(ForOpenSwiftUIOnly)
    open var wasRead: Bool {
        get { _openSwiftUIBaseClassAbstractMethod() }
        set { _openSwiftUIBaseClassAbstractMethod() }
    }
    
    @_spi(ForOpenSwiftUIOnly)
    open func get() -> Value {
        _openSwiftUIBaseClassAbstractMethod()
    }

    @_spi(ForOpenSwiftUIOnly)
    open func projecting<P>(_ projection: P) -> AnyLocation<P.Projected> where Value == P.Base, P: Projection {
        _openSwiftUIBaseClassAbstractMethod()
    }

    @_spi(ForOpenSwiftUIOnly)
    open func set(_ newValue: Value, transaction: Transaction) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    @_spi(ForOpenSwiftUIOnly)
    open func update() -> (Value, Bool) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    @_spi(ForOpenSwiftUIOnly)
    open func isEqual(to other: AnyLocation<Value>) -> Bool {
        self === other
    }

    package override init() {
        super.init()
    }
}

@available(OpenSwiftUI_v5_0, *)
extension AnyLocation: Equatable {
    public static func == (lhs: AnyLocation<Value>, rhs: AnyLocation<Value>) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

@available(*, unavailable)
extension AnyLocation: Sendable {}

// MARK: - LocationBox

/// A type-erased wrapper that boxes a location for polymorphic storage and usage.
///
/// `LocationBox` allows different location types to be stored and used through
/// a common interface while maintaining type safety for the value type.
final package class LocationBox<L>: AnyLocation<L.Value>, Location, @unchecked Sendable where L: Location {
    final private(set) package var location: L

    @AtomicBox
    private var cache = LocationProjectionCache()

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

/// A cache for projected locations to avoid recreating them on repeated access.
///
/// This cache stores weak references to projected locations, allowing them to be
/// reused efficiently when the same projection is applied multiple times.
package struct LocationProjectionCache {
    var cache: [AnyHashable: WeakBox<AnyLocationBase>]
    
    /// Retrieves or creates a projected location for the given projection and base location.
    ///
    /// - Parameters:
    ///   - projection: The projection to apply.
    ///   - location: The base location to project from.
    /// - Returns: A type-erased location containing the projected value.
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
    
    /// Clears all cached projected locations.
    package mutating func reset() {
        cache = [:]
    }
    
    package init() {
        cache = [:]
    }
}

// MARK: - FlattenedCollectionLocation

/// A location that aggregates multiple locations, using the first as primary for reads.
///
/// When setting values, all locations in the collection are updated. This is useful
/// for scenarios where multiple locations need to be kept in sync.
package struct FlattenedCollectionLocation<Value, Base>: Location where Base: Collection, Base: Equatable, Base.Element: AnyLocation<Value> {
    /// The collection of locations being aggregated.
    package let base: Base

    /// Creates a flattened collection location from an array of locations.
    ///
    /// - Parameter base: The array of locations to aggregate.
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

// MARK: - ZipLocation

/// A location that combines two locations into a single tuple-valued location.
///
/// `ZipLocation` allows treating two independent locations as a single location
/// with a tuple value, coordinating reads and writes across both.
package struct ZipLocation<A, B>: Location {
    /// The pair of locations being combined.
    package let locations: (AnyLocation<A>, AnyLocation<B>)

    /// Creates a zipped location from two locations.
    ///
    /// - Parameter locations: A tuple containing the two locations to combine.
    package init(locations: (AnyLocation<A>, AnyLocation<B>)) {
        self.locations = locations
    }

    package var wasRead: Bool {
        get { locations.0.wasRead || locations.1.wasRead }
        set {
            locations.0.wasRead = newValue
            locations.1.wasRead = newValue
        }
    }

    package func get() -> (A, B) {
        (locations.0.get(), locations.1.get())
    }

    package func set(_ newValue: (A, B), transaction: Transaction) {
        locations.0.set(newValue.0, transaction: transaction)
        locations.1.set(newValue.1, transaction: transaction)
    }

    package func update() -> ((A, B), Bool) {
        let (a, aChanged) = locations.0.update()
        let (b, bChanged) = locations.1.update()
        return ((a, b), aChanged || bChanged)
    }

    package static func == (lhs: ZipLocation<A, B>, rhs: ZipLocation<A, B>) -> Bool {
        lhs.locations == rhs.locations
    }
}

// MARK: - ConstantLocation

/// A location that always returns a constant value and ignores writes.
///
/// `ConstantLocation` is useful for providing a location interface to immutable data
/// or default values that should not be modified.
package struct ConstantLocation<Value>: Location {
    /// The constant value stored in this location.
    package var value: Value

    /// Creates a constant location with the specified value.
    ///
    /// - Parameter value: The constant value to store.
    package init(value: Value) {
        self.value = value
    }

    package var wasRead: Bool {
        get { true }
        nonmutating set {}
    }

    package func get() -> Value { value }

    package func set(_: Value, transaction _: Transaction) {}

    package static func == (lhs: ConstantLocation<Value>, rhs: ConstantLocation<Value>) -> Bool {
        compareValues(lhs.value, rhs.value)
    }
}

// MARK: - FunctionalLocation

/// A location implemented using custom getter and setter functions.
///
/// `FunctionalLocation` provides maximum flexibility by allowing arbitrary
/// logic for reading and writing values through function closures.
package struct FunctionalLocation<Value>: Location {
    /// The functions used to implement location operations.
    package struct Functions {
        /// The function to retrieve the current value.
        package var getValue: () -> Value
        
        /// The function to set a new value with a transaction.
        package var setValue: (Value, Transaction) -> Void
    }

    /// The functions implementing this location's behavior.
    package var functions: Functions

    /// Creates a functional location with the specified getter and setter.
    ///
    /// - Parameters:
    ///   - getValue: A closure that returns the current value.
    ///   - setValue: A closure that sets a new value within a transaction.
    package init(getValue: @escaping () -> Value, setValue: @escaping (Value, Transaction) -> Void) {
        self.functions = .init(getValue: getValue, setValue: setValue)
    }

    package var wasRead: Bool {
        get { true }
        nonmutating set {}
    }

    package func get() -> Value {
        functions.getValue()
    }

    package func set(_ newValue: Value, transaction: Transaction) {
        functions.setValue(newValue, transaction)
    }

    package static func == (lhs: FunctionalLocation<Value>, rhs: FunctionalLocation<Value>) -> Bool {
        compareValues(lhs, rhs)
    }
}

// MARK: - ProjectedLocation

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

    func get() -> Value {
        projection.get(base: location.get())
    }

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
