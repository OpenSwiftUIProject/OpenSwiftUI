//
//  EnvironmentObject.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1BEC77534769ADF54BD6111359D32D97 (SwiftUICore)

import OpenAttributeGraphShims
#if OPENSWIFTUI_OPENCOMBINE
public import OpenCombine
#else
public import Combine
#endif

// MARK: - EnvironmentObject

/// A property wrapper type for an observable object that a parent or ancestor
/// view supplies.
///
/// An environment object invalidates the current view whenever the observable
/// object that conforms to
/// [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
/// changes. If you declare a property as an environment object, be sure
/// to set a corresponding model object on an ancestor view by calling its
/// ``View/environmentObject(_:)`` modifier.
///
/// > Note: If your observable object conforms to the
/// [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
/// protocol, use ``Environment`` instead of `EnvironmentObject` and set the
/// model object in an ancestor view by calling its ``View/environment(_:)``
/// or ``View/environment(_:_:)`` modifiers.
@available(OpenSwiftUI_v1_0, *)
@frozen
@propertyWrapper
@preconcurrency
@MainActor
public struct EnvironmentObject<ObjectType>: DynamicProperty where ObjectType: ObservableObject {

    /// A wrapper of the underlying environment object that can create bindings
    /// to its properties using dynamic member lookup.
    @dynamicMemberLookup
    @frozen
    @preconcurrency
    @MainActor
    public struct Wrapper {
        let root: ObjectType

        /// Returns a binding to the resulting value of a given key path.
        ///
        /// - Parameter keyPath: A key path to a specific resulting value.
        ///
        /// - Returns: A new binding.
        public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>) -> Binding<Subject> {
            Binding(root, keyPath: keyPath)
        }
    }

    /// The underlying value referenced by the environment object.
    ///
    /// This property provides primary access to the value's data. However, you
    /// don't access `wrappedValue` directly. Instead, you use the property
    /// variable created with the ``EnvironmentObject`` attribute.
    ///
    /// When a mutable value changes, the new value is immediately available.
    /// However, a view displaying the value is updated asynchronously and may
    /// not show the new value immediately.
    @inlinable
    public var wrappedValue: ObjectType {
        guard let store = _store else { error() }
        return store
    }
    
    @inlinable
    var optionalWrappedValue: ObjectType? {
        _store
    }
    
    @usableFromInline
    var _store: ObjectType?
    
    @usableFromInline
    var _seed: Int = 0

    /// A projection of the environment object that creates bindings to its
    /// properties using dynamic member lookup.
    ///
    /// Use the projected value to pass an environment object down a view
    /// hierarchy.
    public var projectedValue: Wrapper {
        guard let store = _store else { error() }
        return .init(root: store)
    }
    
    @usableFromInline
    func error() -> Never {
        preconditionFailure("No ObservableObject of type \(ObjectType.self) found. A View.environmentObject(_:) for \(ObjectType.self) may be missing as an ancestor of this view.")
    }

    /// Creates an environment object.
    public init() {
        _openSwiftUIEmptyStub()
    }

    nonisolated public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        let attribute = Attribute(value: ())
        let box = StoreBox<ObjectType>(
            host: .currentHost,
            environment: inputs.environment,
            signal: WeakAttribute(attribute)
        )
        buffer.append(box, fieldOffset: fieldOffset)
        addTreeValue(
            attribute,
            as: ObjectType.self,
            at: fieldOffset,
            in: V.self,
            flags: .environmentObjectSignal
        )
    }
}

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentObject {
    @MainActor
    @preconcurrency
    public static var _propertyBehaviors: UInt32 {
        DynamicPropertyBehaviors.requiresMainThread.rawValue
    }
}

// MARK: - StoreBox

private struct StoreBox<ObjectType>: DynamicPropertyBox where ObjectType: ObservableObject {

    typealias Upstream = ObjectType.ObjectWillChangePublisher

    typealias Property = EnvironmentObject<ObjectType>

    @Attribute var environment: EnvironmentValues

    let signal: WeakAttribute<()>

    let subscriber: AttributeInvalidatingSubscriber<Upstream>

    let lifetime: SubscriptionLifetime<Upstream> = .init()

    var seed: Int = .zero

    var oldStore: ObjectType?

    init(
        host: GraphHost,
        environment: Attribute<EnvironmentValues>,
        signal: WeakAttribute<()>
    ) {
        self._environment = environment
        self.signal = signal
        self.subscriber = .init(host: host, attribute: signal)
    }

    mutating func reset() {
        oldStore = nil
    }

    mutating func update(property: inout Property, phase: ViewPhase) -> Bool {
        let (env, envChanged) = $environment.changedValue()
        var changed = envChanged
        if let oldStore, !envChanged {
            property._store = oldStore
        } else {
            let store = env[keyPath: ObjectType.environmentStore]
            property._store = store
            if oldStore === store {
                changed = false
            }
        }
        let newStore = property._store
        if let newStore {
            let shouldForceSubscription = isLinkedOnOrAfter(.v6) ? false : !ObjectType.hasDefaultPublisher
            let isUninitialized = oldStore == nil
            if oldStore == nil || isUninitialized || newStore !== oldStore || shouldForceSubscription {
                lifetime.subscribe(subscriber: subscriber, to: newStore.objectWillChange)
            }
        }
        let signalChanged = signal.changedValue()?.changed ?? false
        changed = changed || signalChanged
        if changed {
            seed &+= 1
        }
        property._seed = seed
        oldStore = newStore
        return changed
    }
}

// MARK: - View + environmentObject

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Supplies an observable object to a view's hierarchy.
    ///
    /// Use this modifier to add an observable object to a view's environment.
    /// The object must conform to the
    /// [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
    /// protocol.
    ///
    /// Adding an object to a view's environment makes the object available to
    /// subviews in the view's hierarchy. To retrieve the object in a subview,
    /// use the ``EnvironmentObject`` property wrapper.
    ///
    /// > Note: If the observable object conforms to the
    /// [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
    /// protocol, use either ``View/environment(_:)`` or the
    /// ``View/environment(_:_:)`` modifier to add the object to the view's
    /// environment.
    ///
    /// - Parameter object: The object to store and make available to
    ///     the view's hierarchy.
    @inlinable
    nonisolated public func environmentObject<T>(_ object: T) -> some View where T: ObservableObject {
        environment(T.environmentStore, object)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension ObservableObject {
    @usableFromInline
    static var environmentStore: WritableKeyPath<EnvironmentValues, Self?> {
        \EnvironmentValues[EnvironmentObjectKey<Self>()]
    }

    static var hasDefaultPublisher: Bool {
        ObjectWillChangePublisher.self == ObservableObjectPublisher.self
    }
}
