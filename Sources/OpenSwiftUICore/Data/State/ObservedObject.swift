//
//  ObservedObject.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by addTreeValueSlow
//  ID: C212C242BFEB175E53A59438AB276A7C (SwiftUICore)

import OpenAttributeGraphShims
#if OPENSWIFTUI_OPENCOMBINE
public import OpenCombine
#else
public import Combine
#endif

// MARK: - ObservedObject

/// A property wrapper type that subscribes to an observable object and
/// invalidates a view whenever the observable object changes.
///
/// Add the `@ObservedObject` attribute to a parameter of an OpenSwiftUI ``View``
/// when the input is an
/// [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
/// and you want the view to update when the object's published properties
/// change. You typically do this to pass a ``StateObject`` into a subview.
///
/// The following example defines a data model as an observable object,
/// instantiates the model in a view as a state object, and then passes
/// the instance to a subview as an observed object:
///
///     class DataModel: ObservableObject {
///         @Published var name = "Some Name"
///         @Published var isEnabled = false
///     }
///
///     struct MyView: View {
///         @StateObject private var model = DataModel()
///
///         var body: some View {
///             Text(model.name)
///             MySubView(model: model)
///         }
///     }
///
///     struct MySubView: View {
///         @ObservedObject var model: DataModel
///
///         var body: some View {
///             Toggle("Enabled", isOn: $model.isEnabled)
///         }
///     }
///
/// When any published property of the observable object changes, OpenSwiftUI
/// updates any view that depends on the object. Subviews can
/// also make updates to the model properties, like the ``Toggle`` in the
/// above example, that propagate to other observers throughout the view
/// hierarchy.
///
/// Don't specify a default or initial value for the observed object. Use the
/// attribute only for a property that acts as an input for a view, as in the
/// above example.
///
/// > Note: Don't wrap objects conforming to the
/// [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
/// protocol with `@ObservedObject`. OpenSwiftUI automatically tracks dependencies
/// to `Observable` objects used within body and updates dependent views when
/// their data changes. Attempting to wrap an `Observable` object with
/// `@ObservedObject` may cause a compiler error, because it requires that its
/// wrapped object to conform to the
/// [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
/// protocol.
/// >
/// > If the view needs a binding to a property of an `Observable` object in
/// its body, wrap the object with the ``Bindable`` property wrapper instead;
/// for example, `@Bindable var model: DataModel`. For more information, see
/// <doc:Managing-model-data-in-your-app>.
@available(OpenSwiftUI_v1_0, *)
@preconcurrency
@MainActor
@propertyWrapper
@frozen
public struct ObservedObject<ObjectType>: DynamicProperty where ObjectType: ObservableObject {

    /// A wrapper of the underlying observable object that can create bindings
    /// to its properties.
    @preconcurrency
    @MainActor
    @dynamicMemberLookup
    @frozen
    public struct Wrapper {

        let root: ObjectType

        init(root: ObjectType) {
            self.root = root
        }

        /// Gets a binding to the value of a specified key path.
        ///
        /// - Parameter keyPath: A key path to a specific  value.
        ///
        /// - Returns: A new binding.
        public subscript<Subject>(
            dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>
        ) -> Binding<Subject> {
            Binding(root, keyPath: keyPath)
        }
    }

    @usableFromInline
    var _seed = 0

    /// Creates an observed object with an initial value.
    ///
    /// This initializer has the same behavior as the ``init(wrappedValue:)``
    /// initializer. See that initializer for more information.
    ///
    /// - Parameter initialValue: An initial value.
    @_alwaysEmitIntoClient
    public init(initialValue: ObjectType) {
        self.init(wrappedValue: initialValue)
    }

    /// Creates an observed object with an initial wrapped value.
    ///
    /// Don't call this initializer directly. Instead, declare
    /// an input to a view with the `@ObservedObject` attribute, and pass a
    /// value to this input when you instantiate the view. Unlike a
    /// ``StateObject`` which manages data storage, you use an observed
    /// object to refer to storage that you manage elsewhere, as in the
    /// following example:
    ///
    ///     class DataModel: ObservableObject {
    ///         @Published var name = "Some Name"
    ///         @Published var isEnabled = false
    ///     }
    ///
    ///     struct MyView: View {
    ///         @StateObject private var model = DataModel()
    ///
    ///         var body: some View {
    ///             Text(model.name)
    ///             MySubView(model: model)
    ///         }
    ///     }
    ///
    ///     struct MySubView: View {
    ///         @ObservedObject var model: DataModel
    ///
    ///         var body: some View {
    ///             Toggle("Enabled", isOn: $model.isEnabled)
    ///         }
    ///     }
    ///
    /// Explicitly calling the observed object initializer in `MySubView` would
    /// behave correctly, but would needlessly recreate the same observed object
    /// instance every time OpenSwiftUI calls the view's initializer to redraw the
    /// view.
    ///
    /// - Parameter wrappedValue: An initial value for the observable object.
    public init(wrappedValue: ObjectType) {
        self.wrappedValue = wrappedValue
    }

    /// The underlying value that the observed object references.
    ///
    /// The wrapped value property provides primary access to the observed
    /// object's data. However, you don't typically access it by name. Instead,
    /// OpenSwiftUI accesses this property for you when you refer to the variable
    /// that you create with the `@ObservedObject` attribute.
    ///
    ///     struct MySubView: View {
    ///         @ObservedObject var model: DataModel
    ///
    ///         var body: some View {
    ///             Text(model.name) // Reads name from model's wrapped value.
    ///         }
    ///     }
    ///
    /// When you change a wrapped value, you can access the new value
    /// immediately. However, OpenSwiftUI updates views that display the value
    /// asynchronously, so the interface might not update immediately.
    public var wrappedValue: ObjectType

    /// A projection of the observed object that creates bindings to its
    /// properties.
    ///
    /// Use the projected value to get a ``Binding`` to a property of an
    /// observed object. To access the projected value, prefix the property
    /// variable with a dollar sign (`$`). For example, you can get a binding
    /// to a model's `isEnabled` Boolean so that a ``Toggle`` can control its
    /// value:
    ///
    ///     struct MySubView: View {
    ///         @ObservedObject var model: DataModel
    ///
    ///         var body: some View {
    ///             Toggle("Enabled", isOn: $model.isEnabled)
    ///         }
    ///     }
    ///
    /// > Important: A `Binding` created by the projected value must only be
    /// read from, or written to by the main actor. Failing to do so may result
    /// in undefined behavior, or data loss. When this occurs, OpenSwiftUI will
    /// issue a runtime warning. In a future release, a crash will occur
    /// instead.
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        .init(root: wrappedValue)
    }
}

extension ObservedObject {
    public static func _makeProperty<Value>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<Value>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        let attribute = Attribute(value: ())
        let box = ObservedObjectPropertyBox<ObjectType>(
            host: .currentHost,
            invalidation: WeakAttribute(attribute)
        )
        buffer.append(box, fieldOffset: fieldOffset)
        // TODO: addTreeValueSlow
    }
}

extension ObservableObject {
    public static var _propertyBehaviors: UInt32 {
        DynamicPropertyBehaviors.requiresMainThread.rawValue
    }
}

// MARK: - ObservedObjectPropertyBox

private struct ObservedObjectPropertyBox<ObjectType>: DynamicPropertyBox where ObjectType: ObservableObject {
    typealias Upstream = ObjectType.ObjectWillChangePublisher

    let subscriber: AttributeInvalidatingSubscriber<Upstream>

    let lifetime: SubscriptionLifetime<Upstream> = .init()

    var seed: Int = .zero

    var lastObject: ObjectType?

    init(host: GraphHost, invalidation: WeakAttribute<()>) {
        subscriber = .init(host: host, attribute: invalidation)
    }

    typealias Property = ObservedObject<ObjectType>

    mutating func update(property: inout Property, phase: ViewPhase) -> Bool {
        let object = property.wrappedValue
        let shouldForceSubscription = isLinkedOnOrAfter(.v6) ? false : Upstream.self != ObservableObjectPublisher.self
        if object !== lastObject || lifetime.isUninitialized || shouldForceSubscription {
            lifetime.subscribe(subscriber: subscriber, to: object.objectWillChange)
        }
        lastObject = object
        let changed = subscriber.attribute.changedValue()?.changed ?? false
        if changed {
            seed &+= 1
        }
        property._seed = seed
        return changed
    }
}
