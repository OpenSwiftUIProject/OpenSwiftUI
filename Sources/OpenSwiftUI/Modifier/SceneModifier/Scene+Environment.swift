//
//  Scene+Environment.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if OPENSWIFTUI_OPENCOMBINE
public import OpenCombine
#else
public import Combine
#endif
public import OpenObservation
import OpenSwiftUICore

extension Scene {

    /// Supplies an `ObservableObject` to a view subhierarchy.
    ///
    /// The object can be read by any child by using `EnvironmentObject`:
    ///
    ///     final class Profile: ObservableObject { ... }
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         var body: some View {
    ///             WindowGroup {
    ///                 ContentView()
    ///             }
    ///             .environment(ProfileService.currentProfile)
    ///         }
    ///     }
    ///
    /// You then read the object inside `ContentView` or one of its descendants
    /// using the ``EnvironmentObject`` property wrapper:
    ///
    ///     struct ContentView: View {
    ///         @EnvironmentObject private var currentAccount: Account
    ///
    ///         var body: some View { ... }
    ///     }
    ///
    /// - Parameter object: the object to store and make available to
    ///   the scene's subhierarchy.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func environmentObject<T>(_ object: T) -> some Scene where T: ObservableObject {
        environment(T.environmentStore, object)
    }
}

extension Scene {

    /// Places an observable object in the scene's environment.
    ///
    /// Use this modifier to place an object that you declare with the
    /// [Observable()](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable())
    /// macro into a scene's environment. For example, you can add an instance
    /// of a custom observable `Profile` class to the environment of a
    /// ``WindowGroup`` scene:
    ///
    ///     @Observable class Profile { ... }
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         var body: some View {
    ///             WindowGroup {
    ///                 ContentView()
    ///             }
    ///             .environment(Profile.currentProfile)
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
    /// This modifier affects the given scene, as well as the scene's descendant
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
    /// - Returns: A scene that has the specified object in its environment.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func environment<T>(_ object: T?) -> some Scene where T: AnyObject, T: Observable {
        environment(\EnvironmentValues[EnvironmentObjectKey<T>()], object)
    }
}
