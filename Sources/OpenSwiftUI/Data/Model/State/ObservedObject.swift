//
//  ObservedObject.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by DynamicProperty

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

/// A property wrapper type that subscribes to an observable object and
/// invalidates a view whenever the observable object changes.
///
/// Add the `@ObservedObject` attribute to a parameter of a OpenSwiftUI ``View``
/// when the input is an
/// [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
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
/// [Observable](https://developer.apple.com/documentation/Observation/Observable)
/// protocol with `@ObservedObject`. OpenSwiftUI automatically tracks dependencies
/// to `Observable` objects used within body and updates dependent views when
/// their data changes. Attempting to wrap an `Observable` object with
/// `@ObservedObject` may cause a compiler error, because it requires that its
/// wrapped object to conform to the
/// [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// protocol.
/// >
/// > If the view needs a binding to a property of an `Observable` object in
/// its body, wrap the object with the ``Bindable`` property wrapper instead;
/// for example, `@Bindable var model: DataModel`. For more information, see
/// <doc:Managing-model-data-in-your-app>.
@propertyWrapper
@frozen
public struct ObservedObject<ObjectType> where ObjectType: ObservableObject {
    /// A wrapper of the underlying observable object that can create bindings
    /// to its properties.
    @dynamicMemberLookup
    @frozen
    public struct Wrapper {
        let root: ObjectType

        /// Gets a binding to the value of a specified key path.
        ///
        /// - Parameter keyPath: A key path to a specific  value.
        ///
        /// - Returns: A new binding.
        public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>) -> Binding<Subject> {
            Binding(root, keyPath: keyPath)
        }
    }

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

    @usableFromInline
    var _seed = 0

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
    @MainActor(unsafe)
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
    @MainActor(unsafe)
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        .init(root: wrappedValue)
    }
}

extension ObservedObject: DynamicProperty {
    public static func _makeProperty(in _: inout _DynamicPropertyBuffer, container _: _GraphValue<some Any>, fieldOffset _: Int, inputs _: inout _GraphInputs) {
        // TODO
    }

    public static var _propertyBehaviors: UInt32 { 2 }
}

extension Binding {
    init<ObjectType: ObservableObject>(_ root: ObjectType, keyPath: ReferenceWritableKeyPath<ObjectType, Value>) {
        let location = ObservableObjectLocation(base: root, keyPath: keyPath)
        let box = LocationBox(location: location)
        self.init(value: location.get(), location: box)
    }
}
