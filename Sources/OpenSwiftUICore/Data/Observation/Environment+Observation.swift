//
//  Environment+Observable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenObservation

// MARK: - Environment + Observable

extension Environment {

    /// Creates an environment property to read an observable object from the
    /// environment.
    ///
    /// - Important: This initializer only accepts objects conforming to the
    ///   `Observable` protocol. For reading environment objects that conform to
    ///   `ObservableObject`, use ``EnvironmentObject`` instead.
    ///
    /// Don’t call this initializer directly. Instead, declare a property with
    /// the ``Environment`` property wrapper, passing the object's type to the
    /// wrapper (using this syntax, the object type can be omitted from the end
    /// of property declaration):
    ///
    ///     @Observable final class Profile { ... }
    ///
    ///     struct MyView: View {
    ///         @Environment(Profile.self) private var currentProfile
    ///
    ///         // ...
    ///     }
    ///
    /// - Warning: If no object has been set in the view's environment, this
    /// property will issue a fatal error when accessed. To safely check for the
    /// existence of an environment object, initialize the environment property
    /// with an optional object type instead.
    ///
    /// OpenSwiftUI automatically updates any parts of `MyView` that depend on the
    /// property when the associated environment object changes.
    ///
    /// You can't modify the environment object using a property like this.
    /// Instead, use the ``View/environment(_:)`` view modifier on a view
    /// to set an object for a view hierarchy.
    ///
    /// - Parameter objectType: The type of the `Observable` object to read
    ///   from the environment.
    @available(OpenSwiftUI_v4_0, *)
    public init(_ objectType: Value.Type) where Value: AnyObject, Value: Observable {
        self.init(\EnvironmentValues[forceUnwrapping: EnvironmentObjectKey<Value>()])
    }

    /// Creates an environment property to read an observable object from the
    /// environment, returning `nil` if no corresponding object has been set in
    /// the current view's environment.
    ///
    /// - Important: This initializer only accepts objects conforming to the
    ///   `Observable` protocol. For reading environment objects that conform to
    ///   `ObservableObject`, use ``EnvironmentObject`` instead.
    ///
    /// Don’t call this initializer directly. Instead, declare an optional
    /// property with the ``Environment`` property wrapper, passing the object's
    /// type to the wrapper:
    ///
    ///     @Observable final class Profile { ... }
    ///
    ///     struct MyView: View {
    ///         @Environment(Profile.self) private var currentProfile: Profile?
    ///
    ///         // ...
    ///     }
    ///
    /// If no object has been set in the view's environment, this property will
    /// return `nil` as its wrapped value.
    ///
    /// OpenSwiftUI automatically updates any parts of `MyView` that depend on the
    /// property when the associated environment object changes.
    ///
    /// You can't modify the environment object using a property like this.
    /// Instead, use the ``View/environment(_:)`` view modifier on a view
    /// to set an object for a view hierarchy.
    ///
    /// - Parameter objectType: The type of the `Observable` object to read
    ///   from the environment.
    @available(OpenSwiftUI_v4_0, *)
    public init<T>(_ objectType: T.Type) where Value == T?, T: AnyObject, T: Observable {
        self.init(\EnvironmentValues[EnvironmentObjectKey<T>()])
    }
}

@available(OpenSwiftUI_v4_0, *)
extension EnvironmentValues {

    /// Reads an observable object of the specified type from the environment.
    ///
    /// - Important: This subscript only supports reading objects that conform
    ///   to the `Observable` protocol.
    ///
    /// Use this subscript to read the environment object of a specific type
    /// from an instance of ``EnvironmentValues``, such as when accessing the
    /// ``GraphicsContext/environment`` property of a graphics context:
    ///
    ///     @Observable final class Profile { ... }
    ///
    ///     Canvas { context, size in
    ///         let currentProfile = context.environment[Profile.self]
    ///         ...
    ///     }
    ///
    /// - Parameter objectType: The type of the `Observable` object to read
    ///   from the environment.
    ///
    /// - Returns: The environment object of the specified type, or `nil` if no
    ///   object of that type has been set in this environment.
    @available(OpenSwiftUI_v4_0, *)
    public subscript<T>(objectType: T.Type) -> T? where T: AnyObject, T: Observable {
        get { self[objectType: T.self] }
        set { self[objectType: T.self] = newValue }
    }
}

@available(OpenSwiftUI_v4_0, *)
extension View {
    /// Places an observable object in the view's environment.
    ///
    /// Use this modifier to place an object that you declare with the
    /// [Observable()](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable())
    /// macro into a view's environment. For example, you can add an instance
    /// of a custom observable `Profile` class to the environment of a
    /// `ContentView`:
    ///
    ///     @Observable class Profile { ... }
    ///
    ///     struct RootView: View {
    ///         @State private var currentProfile: Profile?
    ///
    ///         var body: some View {
    ///             ContentView()
    ///                 .environment(currentProfile)
    ///         }
    ///     }
    ///
    /// You then read the object inside `ContentView` or one of its descendants
    /// using the ``Environment`` property wrapper:
    ///
    ///     struct ContentView: View {
    ///         @Environment(Profile.self) private var currentProfile: Profile
    ///
    ///         var body: some View { ... }
    ///     }
    ///
    /// This modifier affects the given view, as well as that view's descendant
    /// views. It has no effect outside the view hierarchy on which you call it.
    /// The environment of a given view hierarchy holds only one observable
    /// object of a given type.
    ///
    /// - Note: This modifier takes an object that conforms to the
    ///   [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
    ///   protocol. To add environment objects that conform to the
    ///   [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
    ///   protocol, use ``View/environmentObject(_:)`` instead.
    ///
    /// - Parameter object: The object to set for this object's type in the
    ///   environment, or `nil` to clear an object of this type from the
    ///   environment.
    ///
    /// - Returns: A view that has the specified object in its environment.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func environment<T>(_ object: T?) -> some View where T: AnyObject, T: Observable {
        environment(\EnvironmentValues[EnvironmentObjectKey<T>()], object)
    }
}
