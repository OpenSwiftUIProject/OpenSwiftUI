//
//  StateObject.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by DynamicProperty

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

/// A property wrapper type that instantiates an observable object.
///
/// Use a state object as the single source of truth for a reference type that
/// you store in a view hierarchy. Create a state object in an ``App``,
/// ``Scene``, or ``View`` by applying the `@StateObject` attribute to a
/// property declaration and providing an initial value that conforms to the
/// [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// protocol. Declare state objects as private to prevent setting them from a
/// memberwise initializer, which can conflict with the storage management that
/// OpenSwiftUI provides:
///
///     class DataModel: ObservableObject {
///         @Published var name = "Some Name"
///         @Published var isEnabled = false
///     }
///
///     struct MyView: View {
///         @StateObject private var model = DataModel() // Create the state object.
///
///         var body: some View {
///             Text(model.name) // Updates when the data model changes.
///             MySubView()
///                 .environmentObject(model)
///         }
///     }
///
/// OpenSwiftUI creates a new instance of the model object only once during the
/// lifetime of the container that declares the state object. For example,
/// OpenSwiftUI doesn't create a new instance if a view's inputs change, but does
/// create a new instance if the identity of a view changes. When published
/// properties of the observable object change, OpenSwiftUI updates any view that
/// depends on those properties, like the ``Text`` view in the above example.
///
/// > Note: If you need to store a value type, like a structure, string, or
///   integer, use the ``State`` property wrapper instead. Also use ``State``
///   if you need to store a reference type that conforms to the
///   [Observable](https://developer.apple.com/documentation/observation/observable())
///   protocol. To learn more about Observation in OpenSwiftUI, see
///   <doc:Managing-model-data-in-your-app>.
///
/// ### Share state objects with subviews
///
/// You can pass a state object into a subview through a property that has the
/// ``ObservedObject`` attribute. Alternatively, add the object to the
/// environment of a view hierarchy by applying the
/// ``View/environmentObject(_:)`` modifier to a view, like `MySubView` in the
/// above code. You can then read the object inside `MySubView` or any of its
/// descendants using the ``EnvironmentObject`` attribute:
///
///     struct MySubView: View {
///         @EnvironmentObject var model: DataModel
///
///         var body: some View {
///             Toggle("Enabled", isOn: $model.isEnabled)
///         }
///     }
///
/// Get a ``Binding`` to the state object's properties using the dollar sign
/// (`$`) operator. Use a binding when you want to create a two-way connection.
/// In the above code, the ``Toggle`` controls the model's `isEnabled` value
/// through a binding.
///
/// ### Initialize state objects using external data
///
/// When a state object's initial state depends on data that comes from
/// outside its container, you can call the object's initializer
/// explicitly from within its container's initializer. For example,
/// suppose the data model from the previous example takes a `name`
/// input during initialization and you want to use a value for that
/// name that comes from outside the view. You can do this with
/// a call to the state object's initializer inside an explicit initializer
/// that you create for the view:
///
///     struct MyInitializableView: View {
///         @StateObject private var model: DataModel
///
///         init(name: String) {
///             // OpenSwiftUI ensures that the following initialization uses the
///             // closure only once during the lifetime of the view, so
///             // later changes to the view's name input have no effect.
///             _model = StateObject(wrappedValue: DataModel(name: name))
///         }
///
///         var body: some View {
///             VStack {
///                 Text("Name: \(model.name)")
///             }
///         }
///     }
///
/// Use caution when doing this. OpenSwiftUI only initializes a state object
/// the first time you call its initializer in a given view. This
/// ensures that the object provides stable storage even as the view's
/// inputs change. However, it might result in unexpected behavior or
/// unwanted side effects if you explicitly initialize the state object.
///
/// In the above example, if the `name` input to `MyInitializableView`
/// changes, OpenSwiftUI reruns the view's initializer with the new value. However,
/// OpenSwiftUI runs the autoclosure that you provide to the state object's
/// initializer only the first time you call the state object's initializer, so
/// the model's stored `name` value doesn't change.
///
/// Explicit state object initialization works well when the external data
/// that the object depends on doesn't change for a given instance of the
/// object's container. For example, you can create two views with different
/// constant names:
///
///     var body: some View {
///         VStack {
///             MyInitializableView(name: "Ravi")
///             MyInitializableView(name: "Maria")
///         }
///     }
///
/// > Important: Even for a configurable state object, you still declare it
///   as private. This ensures that you can't accidentally set the parameter
///   through a memberwise initializer of the view, because doing so can
///   conflict with the framework's storage management and produce unexpected
///   results.
///
/// ### Force reinitialization by changing view identity
///
/// If you want OpenSwiftUI to reinitialize a state object when a view input
/// changes, make sure that the view's identity changes at the same time.
/// One way to do this is to bind the view's identity to the value that changes
/// using the ``View/id(_:)`` modifier. For example, you can ensure that
/// the identity of an instance of `MyInitializableView` changes when its
/// `name` input changes:
///
///     MyInitializableView(name: name)
///         .id(name) // Binds the identity of the view to the name property.
///
/// > NOTE: If your view appears inside a ``ForEach``, it implicitly receives an
///   ``View/id(_:)`` modifier that uses the identifier of the corresponding
///   data element.
///
/// If you need the view to reinitialize state based on changes in more than
/// one value, you can combine the values into a single identifier using a
/// [Hasher](https://developer.apple.com/documentation/swift/hasher). For example,
/// if you want to update the data model in `MyInitializableView` when the
/// values of either `name` or `isEnabled` change, you can combine both
/// variables into a single hash:
///
///     var hash: Int {
///         var hasher = Hasher()
///         hasher.combine(name)
///         hasher.combine(isEnabled)
///         return hasher.finalize()
///     }
///
/// Then apply the combined hash to the view as an identifier:
///
///     MyInitializableView(name: name, isEnabled: isEnabled)
///         .id(hash)
///
/// Be mindful of the performance cost of reinitializing the state object every
/// time the input changes. Also, changing view identity can have side
/// effects. For example, OpenSwiftUI doesn't automatically animate
/// changes inside the view if the view's identity changes at the same time.
/// Also, changing the identity resets _all_ state held by the view, including
/// values that you manage as ``State``, ``FocusState``, ``GestureState``,
/// and so on.
@frozen
@propertyWrapper
public struct StateObject<ObjectType> where ObjectType: ObservableObject {
    @usableFromInline
    @frozen
    enum Storage {
        case initially(() -> ObjectType)
        case object(ObservedObject<ObjectType>)
    }

    @usableFromInline
    var storage: StateObject<ObjectType>.Storage

    /// Creates a new state object with an initial wrapped value.
    ///
    /// You typically don’t call this initializer directly. Instead, OpenSwiftUI
    /// calls it for you when you declare a property with the `@StateObject`
    /// attribute in an ``App``, ``Scene``, or ``View`` and provide an initial
    /// value:
    ///
    ///     struct MyView: View {
    ///         @StateObject private var model = DataModel()
    ///
    ///         // ...
    ///     }
    ///
    /// OpenSwiftUI creates only one instance of the state object for each
    /// container instance that you declare. In the above code, OpenSwiftUI
    /// creates `model` only the first time it initializes a particular
    /// instance of `MyView`. On the other hand, each instance of `MyView`
    /// creates a distinct instance of the data model. For example, each of
    /// the views in the following ``VStack`` has its own model storage:
    ///
    ///     var body: some View {
    ///         VStack {
    ///             MyView()
    ///             MyView()
    ///         }
    ///     }
    ///
    /// ### Initialize using external data
    ///
    /// If the initial state of a state object depends on external data, you can
    /// call this initializer directly. However, use caution when doing this,
    /// because OpenSwiftUI only initializes the object once during the lifetime of
    /// the view --- even if you call the state object initializer more than
    /// once --- which might result in unexpected behavior. For more information
    /// and an example, see ``StateObject``.
    ///
    /// - Parameter thunk: An initial value for the state object.
    @inlinable
    public init(wrappedValue thunk: @autoclosure @escaping () -> ObjectType) {
        storage = .initially(thunk)
    }

    /// The underlying value referenced by the state object.
    ///
    /// The wrapped value property provides primary access to the value's data.
    /// However, you don't typically access it directly. Instead,
    /// OpenSwiftUI accesses this property for you when you refer to the variable
    /// that you create with the `@StateObject` attribute:
    ///
    ///     @StateObject private var contact = Contact()
    ///
    ///     var body: some View {
    ///         Text(contact.name) // Reads name from contact's wrapped value.
    ///     }
    ///
    /// When you change a wrapped value, you can access the new
    /// value immediately. However, OpenSwiftUI updates views that display the value
    /// asynchronously, so the interface might not update immediately.
    @MainActor
    public var wrappedValue: ObjectType {
        objectValue.wrappedValue
    }

    /// A projection of the state object that creates bindings to its
    /// properties.
    ///
    /// Use the projected value to get a ``Binding`` to a property of a state
    /// object. To access the projected value, prefix the property name
    /// with a dollar sign (`$`). For example, you can get a binding to a
    /// model's `isEnabled` Boolean so that a ``Toggle`` can control the value:
    ///
    ///     struct MyView: View {
    ///         @StateObject private var model = DataModel()
    ///
    ///         var body: some View {
    ///             Toggle("Enabled", isOn: $model.isEnabled)
    ///         }
    ///     }
    ///
    @MainActor
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        objectValue.projectedValue
    }
}

extension StateObject: DynamicProperty {
    public static func _makeProperty(in _: inout _DynamicPropertyBuffer, container _: _GraphValue<some Any>, fieldOffset _: Int, inputs _: inout _GraphInputs) {
        // TODO:
    }

    public static var _propertyBehaviors: UInt32 { 2 }
}

extension StateObject {
    var objectValue: ObservedObject<ObjectType> {
        switch storage {
        case let .initially(thunk):
            Log.runtimeIssues("Accessing StateObject's object without being installed on a View. This will create a new instance each time.")
            return ObservedObject(wrappedValue: thunk())
        case let .object(value):
            return value
        }
    }
}
