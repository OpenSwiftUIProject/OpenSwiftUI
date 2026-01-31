//
//  EnvironmentSceneModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@available(OpenSwiftUI_v2_0, *)
extension _EnvironmentKeyWritingModifier: PrimitiveSceneModifier {}

extension Scene {

    /// Sets the environment value of the specified key path to the given value.
    ///
    /// Use this modifier to set one of the writable properties of the
    /// ``EnvironmentValues`` structure, including custom values that you
    /// create. For example, you can create a custom environment key
    /// `styleOverrides` to set a value that represents style settings that for
    /// the entire app:
    ///
    ///     WindowGroup {
    ///         ContentView()
    ///     }
    ///     .environment(\.styleOverrides, StyleOverrides())
    ///
    /// You then read the value inside `ContentView` or one of its descendants
    /// using the ``Environment`` property wrapper:
    ///
    ///     struct MyView: View {
    ///         @Environment(\.styleOverrides) var styleOverrides: StyleOverrides
    ///
    ///         var body: some View { ... }
    ///     }
    ///
    /// This modifier affects the given scene,
    /// as well as that scene's descendant views. It has no effect
    /// outside the view hierarchy on which you call it.
    ///
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property of the
    ///     ``EnvironmentValues`` structure to update.
    ///   - value: The new value to set for the item specified by `keyPath`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    @available(OpenSwiftUI_v2_0, *)
    @_alwaysEmitIntoClient
    nonisolated public func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) -> some Scene {
        modifier(_EnvironmentKeyWritingModifier(keyPath: keyPath, value: value))
    }
}

@available(OpenSwiftUI_v5_0, *)
extension _EnvironmentKeyTransformModifier: PrimitiveSceneModifier {}

@available(OpenSwiftUI_v5_0, *)
extension Scene {

    /// Transforms the environment value of the specified key path with the
    /// given function.
    nonisolated public func transformEnvironment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        transform: @escaping (inout V) -> Void
    ) -> some Scene {
        modifier(_EnvironmentKeyTransformModifier(keyPath: keyPath, transform: transform))
    }
}
