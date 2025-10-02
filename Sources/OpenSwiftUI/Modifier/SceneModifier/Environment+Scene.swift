#if OPENSWIFTUI_OPENCOMBINE
public import OpenCombine
#else
public import Combine
#endif

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
        _openSwiftUIUnimplementedFailure()
    }
}
