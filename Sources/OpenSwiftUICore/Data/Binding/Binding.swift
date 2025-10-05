//
//  Binding.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5436F2B399369BE3B016147A5F8FE9F2 (SwiftUI)
//  ID: C453EE81E759852CCC6400C47D93A43E (SwiftUICore)

#if OPENSWIFTUI_ENABLE_RUNTIME_CONCURRENCY_CHECK
public import class Foundation.UserDefaults
#endif

/// A property wrapper type that can read and write a value owned by a source of
/// truth.
///
/// Use a binding to create a two-way connection between a property that stores
/// data, and a view that displays and changes the data. A binding connects a
/// property to a source of truth stored elsewhere, instead of storing data
/// directly. For example, a button that toggles between play and pause can
/// create a binding to a property of its parent view using the `Binding`
/// property wrapper.
///
///     struct PlayButton: View {
///         @Binding var isPlaying: Bool
///
///         var body: some View {
///             Button(isPlaying ? "Pause" : "Play") {
///                 isPlaying.toggle()
///             }
///         }
///     }
///
/// The parent view declares a property to hold the playing state, using the
/// ``State`` property wrapper to indicate that this property is the value's
/// source of truth.
///
///     struct PlayerView: View {
///         var episode: Episode
///         @State private var isPlaying: Bool = false
///
///         var body: some View {
///             VStack {
///                 Text(episode.title)
///                     .foregroundStyle(isPlaying ? .primary : .secondary)
///                 PlayButton(isPlaying: $isPlaying) // Pass a binding.
///             }
///         }
///     }
///
/// When `PlayerView` initializes `PlayButton`, it passes a binding of its state
/// property into the button's binding property. Applying the `$` prefix to a
/// property wrapped value returns its ``State/projectedValue``, which for a
/// state property wrapper returns a binding to the value.
///
/// Whenever the user taps the `PlayButton`, the `PlayerView` updates its
/// `isPlaying` state.
///
/// A binding conforms to ``Sendable`` only if its wrapped value type also
/// conforms to ``Sendable``. It is always safe to pass a sendable binding
/// between different concurrency domains. However, reading from or writing
/// to a binding's wrapped value from a different concurrency domain may or
/// may not be safe, depending on how the binding was created. OpenSwiftUI will
/// issue a warning at runtime if it detects a binding being used in a way
/// that may compromise data safety.
///
/// > Note: To create bindings to properties of a type that conforms to the
/// [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
/// protocol, use the ``Bindable`` property wrapper. For more information,
/// see <doc:Migrating-from-the-observable-object-protocol-to-the-observable-macro>.
///
@available(OpenSwiftUI_v1_0, *)
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value> {

    /// The binding's transaction.
    ///
    /// The transaction captures the information needed to update the view when
    /// the binding value changes.
    public var transaction: Transaction

    package var location: AnyLocation<Value>

    package var _value: Value

    package init(value: Value, location: AnyLocation<Value>, transaction: Transaction) {
        self.transaction = transaction
        self.location = location
        self._value = value
    }

    package init(value: Value, location: AnyLocation<Value>) {
        self.init(value: value, location: location, transaction: Transaction())
    }

    @usableFromInline
    static func getIsolated(@_inheritActorContext _ get: @escaping @isolated(any) @Sendable () -> Value) -> () -> Value {
        {
            let enableRuntimeCheck = false
            let nonisolatedGet = get as () -> Value
            return if let isolation = extractIsolation(get),
                      enableRuntimeCheck {
                isolation.assumeIsolated { _ in
                    nonisolatedGet()
                }
            } else {
                nonisolatedGet()
            }
        }
    }

    #if OPENSWIFTUI_ENABLE_RUNTIME_CONCURRENCY_CHECK
    /// Creates a binding with closures that read and write the binding value.
    ///
    /// A binding conforms to Sendable only if its wrapped value type also
    /// conforms to Sendable. It is always safe to pass a sendable binding
    /// between different concurrency domains. However, reading from or writing
    /// to a binding's wrapped value from a different concurrency domain may or
    /// may not be safe, depending on how the binding was created. OpenSwiftUI will
    /// issue a warning at runtime if it detects a binding being used in a way
    /// that may compromise data safety.
    ///
    /// For a "computed" binding created using get and set closure parameters,
    /// the safety of accessing its wrapped value from a different concurrency
    /// domain depends on whether those closure arguments are isolated to
    /// a specific actor. For example, a computed binding with closure arguments
    /// that are known (or inferred) to be isolated to the main actor must only
    /// ever access its wrapped value on the main actor as well, even if the
    /// binding is also sendable.
    ///
    /// - Parameters:
    ///   - get: A closure that retrieves the binding value. The closure has no
    ///     parameters, and returns a value.
    ///   - set: A closure that sets the binding value. The closure has the
    ///     following parameter:
    ///       - newValue: The new value of the binding value.
    @_alwaysEmitIntoClient
    public init(
        @_inheritActorContext get: @escaping @isolated(any) @Sendable () -> Value,
        @_inheritActorContext set: @escaping @isolated(any) @Sendable (Value) -> Void
    ) {
        self.init(isolatedGet: get, isolatedSet: set)
    }

    @usableFromInline
    @_transparent
    init(
        @_inheritActorContext isolatedGet: @escaping @isolated(any) @Sendable () -> Value,
        @_inheritActorContext isolatedSet: @escaping @isolated(any) @Sendable (Value) -> Void,
    ) {
        let enableRuntimeCheck = UserDefaults.standard.bool(
            forKey: "org.OpenSwiftUIProject.OpenSwiftUI.EnableRuntimeConcurrencyCheck",
        )
        self.init(
            get: {
                let nonisolatedGet = isolatedGet as () -> Value
                return if let isolation = extractIsolation(isolatedGet),
                          enableRuntimeCheck
                {
                    isolation.assumeIsolated { _ in nonisolatedGet() }
                } else {
                    nonisolatedGet()
                }
            },
            set: { value in
                let nonisolatedSet = isolatedSet as (Value) -> Void
                if let isolation = extractIsolation(isolatedSet),
                   enableRuntimeCheck
                {
                    isolation.assumeIsolated { _ in
                        nonisolatedSet(value)
                    }
                } else {
                    nonisolatedSet(value)
                }
            },
        )
    }

    @usableFromInline
    init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        let location = FunctionalLocation(getValue: get) { value, _ in set(value) }
        let box = LocationBox(location)
        self.init(value: get(), location: box)
    }

    /// Creates a binding with a closure that reads from the binding value, and
    /// a closure that applies a transaction when writing to the binding value.
    ///
    /// A binding conforms to Sendable only if its wrapped value type also
    /// conforms to Sendable. It is always safe to pass a sendable binding
    /// between different concurrency domains. However, reading from or writing
    /// to a binding's wrapped value from a different concurrency domain may or
    /// may not be safe, depending on how the binding was created. OpenSwiftUI will
    /// issue a warning at runtime if it detects a binding being used in a way
    /// that may compromise data safety.
    ///
    /// For a "computed" binding created using get and set closure parameters,
    /// the safety of accessing its wrapped value from a different concurrency
    /// domain depends on whether those closure arguments are isolated to
    /// a specific actor. For example, a computed binding with closure arguments
    /// that are known (or inferred) to be isolated to the main actor must only
    /// ever access its wrapped value on the main actor as well, even if the
    /// binding is also sendable.
    ///
    /// - Parameters:
    ///   - get: A closure to retrieve the binding value. The closure has no
    ///     parameters, and returns a value.
    ///   - set: A closure to set the binding value. The closure has the
    ///     following parameters:
    ///       - newValue: The new value of the binding value.
    ///       - transaction: The transaction to apply when setting a new value.
    @_alwaysEmitIntoClient
    public init(
        @_inheritActorContext get: @escaping @isolated(any) @Sendable () -> Value,
        @_inheritActorContext set: @escaping @isolated(any) @Sendable (Value, Transaction) -> Void
    ) {
        self.init(isolatedGet: get, isolatedSet: set)
    }

    @usableFromInline
    @_transparent
    init(
        @_inheritActorContext isolatedGet: @escaping @isolated(any) @Sendable () -> Value,
        @_inheritActorContext isolatedSet: @escaping @isolated(any) @Sendable (Value, Transaction) -> Void,
    ) {
        let enableRuntimeCheck = UserDefaults.standard.bool(
            forKey: "org.OpenSwiftUIProject.OpenSwiftUI.EnableRuntimeConcurrencyCheck",
        )
        self.init(
            get: {
                let nonisolatedGet = isolatedGet as () -> Value
                return if let isolation = extractIsolation(isolatedGet),
                          enableRuntimeCheck
                {
                    isolation.assumeIsolated { _ in nonisolatedGet() }
                } else {
                    nonisolatedGet()
                }
            },
            set: { value, transaction in
                let nonisolatedSet = isolatedSet as (Value, Transaction) -> Void
                if let isolation = extractIsolation(isolatedSet),
                   enableRuntimeCheck
                {
                    isolation.assumeIsolated { _ in
                        nonisolatedSet(value, transaction)
                    }
                } else {
                    nonisolatedSet(value, transaction)
                }
            },
        )
    }

    @usableFromInline
    init(get: @escaping () -> Value, set: @escaping (Value, Transaction) -> Void) {
        let location = FunctionalLocation(getValue: get, setValue: set)
        let box = LocationBox(location)
        self.init(value: get(), location: box)
    }
    #else
    /// Creates a binding with closures that read and write the binding value.
    ///
    /// A binding conforms to Sendable only if its wrapped value type also
    /// conforms to Sendable. It is always safe to pass a sendable binding
    /// between different concurrency domains. However, reading from or writing
    /// to a binding's wrapped value from a different concurrency domain may or
    /// may not be safe, depending on how the binding was created. OpenSwiftUI will
    /// issue a warning at runtime if it detects a binding being used in a way
    /// that may compromise data safety.
    ///
    /// For a "computed" binding created using get and set closure parameters,
    /// the safety of accessing its wrapped value from a different concurrency
    /// domain depends on whether those closure arguments are isolated to
    /// a specific actor. For example, a computed binding with closure arguments
    /// that are known (or inferred) to be isolated to the main actor must only
    /// ever access its wrapped value on the main actor as well, even if the
    /// binding is also sendable.
    ///
    /// - Parameters:
    ///   - get: A closure that retrieves the binding value. The closure has no
    ///     parameters, and returns a value.
    ///   - set: A closure that sets the binding value. The closure has the
    ///     following parameter:
    ///       - newValue: The new value of the binding value.
    @preconcurrency
    public init(
        @_inheritActorContext get: @escaping @isolated(any) @Sendable () -> Value,
        @_inheritActorContext set: @escaping @isolated(any) @Sendable (Value) -> Void
    ) {
        let nonisolatedGet = get as () -> Value
        let nonisolatedSet = set as (Value) -> Void
        let location = FunctionalLocation(getValue: nonisolatedGet) { value, _ in nonisolatedSet(value) }
        let box = LocationBox(location)
        self.init(value: nonisolatedGet(), location: box)
    }

    /// Creates a binding with a closure that reads from the binding value, and
    /// a closure that applies a transaction when writing to the binding value.
    ///
    /// A binding conforms to Sendable only if its wrapped value type also
    /// conforms to Sendable. It is always safe to pass a sendable binding
    /// between different concurrency domains. However, reading from or writing
    /// to a binding's wrapped value from a different concurrency domain may or
    /// may not be safe, depending on how the binding was created. OpenSwiftUI will
    /// issue a warning at runtime if it detects a binding being used in a way
    /// that may compromise data safety.
    ///
    /// For a "computed" binding created using get and set closure parameters,
    /// the safety of accessing its wrapped value from a different concurrency
    /// domain depends on whether those closure arguments are isolated to
    /// a specific actor. For example, a computed binding with closure arguments
    /// that are known (or inferred) to be isolated to the main actor must only
    /// ever access its wrapped value on the main actor as well, even if the
    /// binding is also sendable.
    ///
    /// - Parameters:
    ///   - get: A closure to retrieve the binding value. The closure has no
    ///     parameters, and returns a value.
    ///   - set: A closure to set the binding value. The closure has the
    ///     following parameters:
    ///       - newValue: The new value of the binding value.
    ///       - transaction: The transaction to apply when setting a new value.
    public init(
        @_inheritActorContext get: @escaping @isolated(any) @Sendable () -> Value,
        @_inheritActorContext set: @escaping @isolated(any) @Sendable (Value, Transaction) -> Void
    ) {
        let nonisolatedGet = get as () -> Value
        let nonisolatedSet = set as (Value, Transaction) -> Void
        let location = FunctionalLocation(getValue: nonisolatedGet, setValue: nonisolatedSet)
        let box = LocationBox(location)
        self.init(value: nonisolatedGet(), location: box)
    }
    #endif

    /// Creates a binding with an immutable value.
    ///
    /// Use this method to create a binding to a value that cannot change.
    /// This can be useful when using a ``PreviewProvider`` to see how a view
    /// represents different values.
    ///
    ///     // Example of binding to an immutable value.
    ///     PlayButton(isPlaying: Binding.constant(true))
    ///
    /// - Parameter value: An immutable value.
    public static func constant(_ value: Value) -> Binding<Value> {
        let location = ConstantLocation(value: value)
        let box = LocationBox(location)
        return Binding(value: value, location: box)
    }

    /// The underlying value referenced by the binding variable.
    ///
    /// This property provides primary access to the value's data. However, you
    /// don't access `wrappedValue` directly. Instead, you use the property
    /// variable created with the ``Binding`` attribute. In the
    /// following code example, the binding variable `isPlaying` returns the
    /// value of `wrappedValue`:
    ///
    ///     struct PlayButton: View {
    ///         @Binding var isPlaying: Bool
    ///
    ///         var body: some View {
    ///             Button(isPlaying ? "Pause" : "Play") {
    ///                 isPlaying.toggle()
    ///             }
    ///         }
    ///     }
    ///
    /// When a mutable binding value changes, the new value is immediately
    /// available. However, updates to a view displaying the value happens
    /// asynchronously, so the view may not show the change immediately.
    public var wrappedValue: Value {
        get {
            readValue()
        }
        nonmutating set {
            location.set(newValue, transaction: transaction)
        }
    }

    /// A projection of the binding value that returns a binding.
    ///
    /// Use the projected value to pass a binding value down a view hierarchy.
    /// To get the `projectedValue`, prefix the property variable with `$`. For
    /// example, in the following code example `PlayerView` projects a binding
    /// of the state property `isPlaying` to the `PlayButton` view using
    /// `$isPlaying`.
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var isPlaying: Bool = false
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                     .foregroundStyle(isPlaying ? .primary : .secondary)
    ///                 PlayButton(isPlaying: $isPlaying)
    ///             }
    ///         }
    ///     }
    ///
    public var projectedValue: Binding<Value> { self }

    /// Creates a binding from the value of another binding.
    @_alwaysEmitIntoClient
    public init(projectedValue: Binding<Value>) {
        self = projectedValue
    }

    /// Returns a binding to the resulting value of a given key path.
    ///
    /// - Parameter keyPath: A key path to a specific resulting value.
    ///
    /// - Returns: A new binding.
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        projecting(keyPath)
    }

    private func readValue() -> Value {
        if Update.threadIsUpdating {
            location.wasRead = true
            return _value
        } else {
            return location.get()
        }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Binding: @unchecked Sendable where Value: Sendable {}

// MARK: - Binding + Protocols

@available(OpenSwiftUI_v3_0, *)
extension Binding: Identifiable where Value: Identifiable {

    /// The stable identity of the entity associated with this instance,
    /// corresponding to the `id` of the binding's wrapped value.
    public var id: Value.ID { wrappedValue.id }
}

@available(OpenSwiftUI_v3_0, *)
extension Binding: Sequence where Value: MutableCollection {
    public typealias Element = Binding<Value.Element>
    public typealias Iterator = IndexingIterator<Binding<Value>>
    public typealias SubSequence = Slice<Binding<Value>>
}

@available(OpenSwiftUI_v3_0, *)
extension Binding: Collection where Value: MutableCollection {
    public typealias Index = Value.Index
    public typealias Indices = Value.Indices
    public var startIndex: Binding<Value>.Index {
        wrappedValue.startIndex
    }

    public var endIndex: Binding<Value>.Index {
        wrappedValue.endIndex
    }

    public var indices: Value.Indices {
        wrappedValue.indices
    }

    public func index(after index: Binding<Value>.Index) -> Binding<Value>.Index {
        wrappedValue.index(after: index)
    }

    public func formIndex(after index: inout Binding<Value>.Index) {
        wrappedValue.formIndex(after: &index)
    }

    public subscript(position: Binding<Value>.Index) -> Binding<Value>.Element {
        Binding<Value>.Element {
            wrappedValue[position]
        } set: {
            wrappedValue[position] = $0
        }
    }
}

@available(OpenSwiftUI_v3_0, *)
extension Binding: BidirectionalCollection where Value: BidirectionalCollection, Value: MutableCollection {
    public func index(before index: Binding<Value>.Index) -> Binding<Value>.Index {
        wrappedValue.index(before: index)
    }

    public func formIndex(before index: inout Binding<Value>.Index) {
        wrappedValue.formIndex(before: &index)
    }
}

@available(OpenSwiftUI_v3_0, *)
extension Binding: RandomAccessCollection where Value: MutableCollection, Value: RandomAccessCollection {}

// MARK: - Binding + Transaction / Animation

@available(OpenSwiftUI_v1_0, *)
extension Binding {
    /// Specifies a transaction for the binding.
    ///
    /// - Parameter transaction : An instance of a ``Transaction``.
    ///
    /// - Returns: A new binding.
    public func transaction(_ transaction: Transaction) -> Binding<Value> {
        var binding = self
        binding.transaction = transaction
        return binding
    }

    /// Specifies an animation to perform when the binding value changes.
    ///
    /// - Parameter animation: An animation sequence performed when the binding
    ///   value changes.
    ///
    /// - Returns: A new binding.
    public func animation(_ animation: Animation? = .default) -> Binding<Value> {
        var binding = self
        binding.transaction.animation = animation
        return binding
    }
}

// MARK: - Binding + Transform

@available(OpenSwiftUI_v1_0, *)
extension Binding {

    package subscript<Subject>(
        keyPath: WritableKeyPath<Value, Subject?>,
        default defaultValue: Subject
    ) -> Binding<Subject> {
        let projection = keyPath.composed(
            with: BindingOperations.NilCoalescing(
                defaultValue: defaultValue,
            )
        )
        return projecting(projection)
    }

    package func zip<T>(with rhs: Binding<T>) -> Binding<(Value, T)> {
        let value = (self._value, rhs._value)
        let box = LocationBox(ZipLocation(locations: (self.location, rhs.location)))
        return Binding<(Value, T)>(value: value, location: box, transaction: transaction)
    }

    package func projecting<P: Projection>(_ p: P) -> Binding<P.Projected> where P.Base == Value {
        Binding<P.Projected>(
            value: p.get(base: _value),
            location: location.projecting(p),
            transaction: transaction
        )
    }
}

extension Binding {
    package init(flattening source: some Collection<Binding<Value>>) {
        let flattenLocation = FlattenedCollectionLocation<Value, [AnyLocation<Value>]>(base: source.map(\.location))
        let value = flattenLocation.get()
        let location = LocationBox(flattenLocation)
        self.init(value: value, location: location)
    }
}

// MARK: - Binding + DynamicProperty

@available(OpenSwiftUI_v1_0, *)
extension Binding: DynamicProperty {

    private struct ScopedLocation: Location {
        var base: AnyLocation<Value>

        var wasRead: Bool

        init(base: AnyLocation<Value>) {
            self.base = base
            self.wasRead = base.wasRead
        }

        func get() -> Value {
            base.get()
        }

        func set(_ value: Value, transaction: Transaction) {
            base.set(value, transaction: transaction)
        }

        func update() -> (Value, Bool) {
            base.update()
        }

        static func == (lhs: ScopedLocation, rhs: ScopedLocation) -> Bool {
            lhs.base == rhs.base && lhs.wasRead == rhs.wasRead
        }
    }

    private struct Box: DynamicPropertyBox {
        var location: LocationBox<ScopedLocation>?

        typealias Property = Binding<Value>

        mutating func update(property: inout Property, phase: _GraphInputs.Phase) -> Bool {
            let newLocation: LocationBox<ScopedLocation>
            if let location, location.location.base === property.location {
                newLocation = location
            } else {
                let wasRead = location?.wasRead ?? false
                let box = LocationBox(ScopedLocation(base: property.location))
                location = box
                if wasRead {
                    box.wasRead = wasRead
                }
                newLocation = box
            }
            let (value, changed) = newLocation.update()
            property.location = newLocation
            property._value = value
            return changed && newLocation.wasRead
        }
    }

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        buffer.append(Box(), fieldOffset: fieldOffset)
    }
}

// NOTE: This is currently not used
struct EnableRuntimeConcurrencyCheck: UserDefaultKeyedFeature {
    static var key: String { "org.OpenSwiftUIProject.OpenSwiftUI.EnableRuntimeConcurrencyCheck" }

    static var cachedValue: Bool?

    static var isEnabled: Bool { true }
}

extension Binding {

    /// Creates a binding by projecting the base value to an optional value.
    ///
    /// - Parameter base: A value to project to an optional value.
    public init<V>(_ base: Binding<V>) where Value == V? {
        self = base.projecting(BindingOperations.ToOptional())
    }

    /// Creates a binding by projecting the base value to an unwrapped value.
    ///
    /// - Parameter base: A value to project to an unwrapped value.
    ///
    /// - Returns: A new binding or `nil` when `base` is `nil`.
    public init?(_ base: Binding<Value?>) {
        guard let _ = base.wrappedValue else {
            return nil
        }
        self = base.projecting(BindingOperations.ForceUnwrapping())
    }

    /// Creates a binding by projecting the base value to a hashable value.
    ///
    /// - Parameters:
    ///   - base: A `Hashable` value to project to an `AnyHashable` value.
    public init(_ base: Binding<some Hashable>) where Value == AnyHashable {
        self = base.projecting(BindingOperations.ToAnyHashable())
    }
}
