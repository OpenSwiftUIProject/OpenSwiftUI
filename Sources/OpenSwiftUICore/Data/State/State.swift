//
//  State.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete
//  ID: 08168374F4710A99DCB15B5E8768D632

import OpenAttributeGraphShims

/// A property wrapper type that can read and write a value managed by OpenSwiftUI.
///
/// Use state as the single source of truth for a given value type that you
/// store in a view hierarchy. Create a state value in an ``App``, ``Scene``,
/// or ``View`` by applying the `@State` attribute to a property declaration
/// and providing an initial value. Declare state as private to prevent setting
/// it in a memberwise initializer, which can conflict with the storage
/// management that OpenSwiftUI provides:
///
///     struct PlayButton: View {
///         @State private var isPlaying: Bool = false // Create the state.
///
///         var body: some View {
///             Button(isPlaying ? "Pause" : "Play") { // Read the state.
///                 isPlaying.toggle() // Write the state.
///             }
///         }
///     }
///
/// OpenSwiftUI manages the property's storage. When the value changes, OpenSwiftUI
/// updates the parts of the view hierarchy that depend on the value.
/// To access a state's underlying value, you use its ``wrappedValue`` property.
/// However, as a shortcut Swift enables you to access the wrapped value by
/// referring directly to the state instance. The above example reads and
/// writes the `isPlaying` state property's wrapped value by referring to the
/// property directly.
///
/// Declare state as private in the highest view in the view hierarchy that
/// needs access to the value. Then share the state with any subviews that also
/// need access, either directly for read-only access, or as a binding for
/// read-write access. You can safely mutate state properties from any thread.
///
/// > Note: If you need to store a reference type, like an instance of a class,
///   use a ``StateObject`` instead.
///
/// ### Share state with subviews
///
/// If you pass a state property to a subview, OpenSwiftUI updates the subview
/// any time the value changes in the container view, but the subview can't
/// modify the value. To enable the subview to modify the state's stored value,
/// pass a ``Binding`` instead. You can get a binding to a state value by
/// accessing the state's ``projectedValue``, which you get by prefixing the
/// property name with a dollar sign (`$`).
///
/// For example, you can remove the `isPlaying` state from the play button in
/// the above example, and instead make the button take a binding:
///
///     struct PlayButton: View {
///         @Binding var isPlaying: Bool // Play button now receives a binding.
///
///         var body: some View {
///             Button(isPlaying ? "Pause" : "Play") {
///                 isPlaying.toggle()
///             }
///         }
///     }
///
/// Then you can define a player view that declares the state and creates a
/// binding to the state using the dollar sign prefix:
///
///     struct PlayerView: View {
///         @State private var isPlaying: Bool = false // Create the state here now.
///
///         var body: some View {
///             VStack {
///                 PlayButton(isPlaying: $isPlaying) // Pass a binding.
///
///                 // ...
///             }
///         }
///     }
///
/// Like you do for a ``StateObject``, declare ``State`` as private to prevent
/// setting it in a memberwise initializer, which can conflict with the storage
/// management that OpenSwiftUI provides. Unlike a state object, always
/// initialize state by providing a default value in the state's
/// declaration, as in the above examples. Use state only for storage that's
/// local to a view and its subviews.
@frozen
@propertyWrapper
public struct State<Value> {
    /// The current or initial (if box == nil) value of the state
    @usableFromInline
    var _value: Value

    /// The value's location, or nil if not yet known.
    @usableFromInline
    var _location: AnyLocation<Value>?

    /// Creates a state property that stores an initial wrapped value.
    ///
    /// You don't call this initializer directly. Instead, OpenSwiftUI
    /// calls it for you when you declare a property with the `@State`
    /// attribute and provide an initial value:
    ///
    ///     struct MyView: View {
    ///         @State private var isPlaying: Bool = false
    ///
    ///         // ...
    ///     }
    ///
    /// OpenSwiftUI initializes the state's storage only once for each
    /// container instance that you declare. In the above code, OpenSwiftUI
    /// creates `isPlaying` only the first time it initializes a particular
    /// instance of `MyView`. On the other hand, each instance of `MyView`
    /// creates a distinct instance of the state. For example, each of
    /// the views in the following ``VStack`` has its own `isPlaying` value:
    ///
    ///     var body: some View {
    ///         VStack {
    ///             MyView()
    ///             MyView()
    ///         }
    ///     }
    ///
    /// - Parameter value: An initial value to store in the state
    ///   property.
    public init(wrappedValue value: Value) {
        _value = value
        _location = nil
    }

    /// Creates a state property that stores an initial value.
    ///
    /// This initializer has the same behavior as the ``init(wrappedValue:)``
    /// initializer. See that initializer for more information.
    ///
    /// - Parameter value: An initial value to store in the state
    ///   property.
    @_alwaysEmitIntoClient
    public init(initialValue value: Value) {
        _value = value
    }

    /// The underlying value referenced by the state variable.
    ///
    /// This property provides primary access to the value's data. However, you
    /// don't typically access `wrappedValue` explicitly. Instead, you gain
    /// access to the wrapped value by referring to the property variable that
    /// you create with the `@State` attribute.
    ///
    /// In the following example, the button's label depends on the value of
    /// `isPlaying` and the button's action toggles the value of `isPlaying`.
    /// Both of these accesses implicitly access the state property's wrapped
    /// value:
    ///
    ///     struct PlayButton: View {
    ///         @State private var isPlaying: Bool = false
    ///
    ///         var body: some View {
    ///             Button(isPlaying ? "Pause" : "Play") {
    ///                 isPlaying.toggle()
    ///             }
    ///         }
    ///     }
    ///
    public var wrappedValue: Value {
        get {
            getValue(forReading: true)
        }
        nonmutating set {
            guard let _location else {
                return
            }
            _location.set(newValue, transaction: Transaction())
        }
    }

    /// A binding to the state value.
    ///
    /// Use the projected value to get a ``Binding`` to the stored value. The
    /// binding provides a two-way connection to the stored value. To access
    /// the `projectedValue`, prefix the property variable with a dollar
    /// sign (`$`).
    ///
    /// In the following example, `PlayerView` projects a binding of the state
    /// property `isPlaying` to the `PlayButton` view using `$isPlaying`. That
    /// enables the play button to both read and write the value:
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
    public var projectedValue: Binding<Value> {
        let value = getValue(forReading: false)
        guard let _location else {
            Log.runtimeIssues("Accessing State's value outside of being installed on a View. This will result in a constant Binding of the initial value and will not update.")
            return .constant(value)
        }
        return Binding(value: value, location: _location)
    }
}

extension State where Value: ExpressibleByNilLiteral {
    /// Creates a state property without an initial value.
    ///
    /// This initializer behaves like the ``init(wrappedValue:)`` initializer
    /// with an input of `nil`. See that initializer for more information.
    @inlinable
    public init() {
        self.init(wrappedValue: nil)
    }
}

extension State {
    private func getValue(forReading: Bool) -> Value {
        guard let _location else {
            return _value
        }
        if GraphHost.isUpdating {
            if forReading {
                _location.wasRead = true
            }
            return _value
        } else {
            return _location.get()
        }
    }
}

extension State: DynamicProperty {
    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container _: _GraphValue<V>,
        fieldOffset: Int,
        inputs _: inout _GraphInputs
    ) {
        let attribute = Attribute(value: ())
        let box = StatePropertyBox<Value>(signal: WeakAttribute(attribute))
        buffer.append(box, fieldOffset: fieldOffset)
    }
}

private struct StatePropertyBox<Value>: DynamicPropertyBox {
    let signal: WeakAttribute<Void>
    var location: StoredLocation<Value>?

    typealias Property = State<Value>
    func destroy() {}
    mutating func reset() { location = nil }
    mutating func update(property: inout State<Value>, phase: _GraphInputs.Phase) -> Bool {
        let locationChanged = location == nil
        if location == nil {
            location = property._location as? StoredLocation ?? StoredLocation(
                initialValue: property._value,
                host: .currentHost,
                signal: signal
            )
        }
        let signalChanged = signal.changedValue()?.changed ?? false
        property._value = location!.updateValue
        property._location = location!
        return (signalChanged ? location!.wasRead : false) || locationChanged
    }
    func getState<V>(type _: V.Type) -> Binding<V>? {
        guard Value.self == V.self,
              let location
        else {
            return nil
        }
        let value = location.get()
        let binding = Binding(value: value, location: location)
        return binding as? Binding<V>
    }
}
