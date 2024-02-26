//
//  Binding.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 5436F2B399369BE3B016147A5F8FE9F2

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
/// > Note: To create bindings to properties of a type that conforms to the
/// [Observable](https://developer.apple.com/documentation/Observation/Observable)
/// protocol, use the ``Bindable`` property wrapper. For more information,
/// see <doc:Migrating-from-the-observable-object-protocol-to-the-observable-macro>.
@frozen
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value> {
    /// The binding's transaction.
    ///
    /// The transaction captures the information needed to update the view when
    /// the binding value changes.
    public var transaction: Transaction
    var location: AnyLocation<Value>
    private var _value: Value

    /// Creates a binding with closures that read and write the binding value.
    ///
    /// - Parameters:
    ///   - get: A closure that retrieves the binding value. The closure has no
    ///     parameters, and returns a value.
    ///   - set: A closure that sets the binding value. The closure has the
    ///     following parameter:
    ///       - newValue: The new value of the binding value.
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        let location = FunctionalLocation(getValue: get) { value, _ in set(value) }
        let box = LocationBox(location: location)
        self.init(value: get(), location: box)
    }

    /// Creates a binding with a closure that reads from the binding value, and
    /// a closure that applies a transaction when writing to the binding value.
    ///
    /// - Parameters:
    ///   - get: A closure to retrieve the binding value. The closure has no
    ///     parameters, and returns a value.
    ///   - set: A closure to set the binding value. The closure has the
    ///     following parameters:
    ///       - newValue: The new value of the binding value.
    ///       - transaction: The transaction to apply when setting a new value.
    public init(get: @escaping () -> Value, set: @escaping (Value, Transaction) -> Void) {
        let location = FunctionalLocation(getValue: get, setValue: set)
        let box = LocationBox(location: location)
        self.init(value: get(), location: box)
    }

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
        let box = LocationBox(location: location)
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

extension Binding: Identifiable where Value: Identifiable {
    /// The stable identity of the entity associated with this instance,
    /// corresponding to the `id` of the binding's wrapped value.
    public var id: Value.ID { wrappedValue.id }

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    public typealias ID = Value.ID
}

extension Binding: Sequence where Value: MutableCollection {
    public typealias Element = Binding<Value.Element>
    public typealias Iterator = IndexingIterator<Binding<Value>>
    public typealias SubSequence = Slice<Binding<Value>>
}

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

extension Binding: BidirectionalCollection where Value: BidirectionalCollection, Value: MutableCollection {
    public func index(before index: Binding<Value>.Index) -> Binding<Value>.Index {
        wrappedValue.index(before: index)
    }

    public func formIndex(before index: inout Binding<Value>.Index) {
        wrappedValue.formIndex(before: &index)
    }
}

extension Binding: RandomAccessCollection where Value: MutableCollection, Value: RandomAccessCollection {}

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
    }
    
    private struct Box: DynamicPropertyBox {
        var location: LocationBox<ScopedLocation>?

        typealias Property = Binding
        func destroy() {}
        func reset() {}
        mutating func update(property: inout Property, phase: _GraphInputs.Phase) -> Bool {
            if let location {
                if location.location.base !== property.location {
                    self.location = LocationBox(location: ScopedLocation(base: property.location))
                    if location.wasRead {
                        self.location!.wasRead = true
                    }
                }
            } else {
                location = LocationBox(location: ScopedLocation(base: property.location))
            }
            let (value, isUpdated) = location!.update()
            property.location = location!
            property._value = value
            return isUpdated ? location!.wasRead : false
        }
    }
    
    public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {
        buffer.append(Box(), fieldOffset: fieldOffset)
    }
}

// MARK: - Binding Internal API

extension Binding {
    init(value: Value, location: AnyLocation<Value>, transaction: Transaction = Transaction()) {
        self.transaction = transaction
        self.location = location
        self._value = value
    }

    private func readValue() -> Value {
        if GraphHost.isUpdating {
            location.wasRead = true
            return _value
        } else {
            return location.get()
        }
    }

    func projecting<P: Projection>(_ p: P) -> Binding<P.Projected> where P.Base == Value {
        Binding<P.Projected>(value: p.get(base: _value), location: location.projecting(p), transaction: transaction)
    }
}
