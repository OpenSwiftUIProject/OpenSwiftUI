//
//  SceneBuilder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

/// A result builder for composing a collection of scenes into a single
/// composite scene.
@available(OpenSwiftUI_v2_0, *)
@resultBuilder
public enum SceneBuilder {

    /// Builds an expression within the builder.
    @_alwaysEmitIntoClient
    public static func buildExpression<Content>(_ content: Content) -> Content where Content: Scene {
        content
    }

    @available(*, unavailable, message: "Provide at leas one scene")
    public static func buildBlock() -> some Scene {
        fatalError("Unavailable")
    }

    /// Passes a single scene written as a child scene through unmodified.
    public static func buildBlock<Content>(_ content: Content) -> Content where Content: Scene {
        content
    }

    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public static func buildBlock<each Content>(_ content: repeat each Content) -> some Scene where repeat each Content: Scene {
        _TupleScene((repeat each content))
    }
}

@available(*, unavailable)
extension SceneBuilder: Swift.Sendable {}

@available(OpenSwiftUI_v2_0, *)
extension SceneBuilder {

    /// Produces an optional scene for conditional statements in multi-statement
    /// closures that's only visible when the condition evaluates to true.
    ///
    /// Conditional statements in a ``SceneBuilder`` can contain an `if` statement
    /// but not an `else` statement, and the condition can only perform a compiler
    /// check for availability, like in the following code:
    ///
    ///     var body: some Scene {
    ///         if #available(iOS 16, *) {
    ///             WindowGroup {
    ///                 ContentView()
    ///             }
    ///         }
    ///     }
    @_alwaysEmitIntoClient
    public static func buildOptional(_ scene: (any Scene & _LimitedAvailabilitySceneMarker)?) -> some Scene {
        if #available(iOS 16.1, macOS 13.0, watchOS 9.1, tvOS 16.1, *) {
            guard let scene else {
                fatalError("""
                    if #available in SceneBuilder includes an unknown OS version
                    """)
            }
            return scene as! LimitedAvailabilityScene
        } else {
            return _EmptyScene()
        }
    }

    @available(*, unavailable, message: "if statements in a SceneBuilder can only be used with #available clauses")
    public static func buildOptional<S>(_ scene: S?) where S: Scene {
        fatalError("Unavailable")
    }

    /// Processes scene content for a conditional compiler-control statement
    /// that performs an availability check.
    @available(OpenSwiftUI_v4_1, *)
    @_alwaysEmitIntoClient
    public static func buildLimitedAvailability(_ scene: some Scene) -> any Scene & _LimitedAvailabilitySceneMarker {
        return LimitedAvailabilityScene(scene)
    }

    @available(iOS, deprecated: 14.0, obsoleted: 16.1, message: "this code may crash on earlier versions of the OS; specify '#available(iOS 16.1, *)' or newer instead")
    @available(macOS, deprecated: 11.0, obsoleted: 13.0, message: "this code may crash on earlier versions of the OS; specify '#available(macOS 13.0, *)' or newer instead")
    @available(watchOS, deprecated: 7.0, obsoleted: 9.1, message: "this code may crash on earlier versions of the OS; specify '#available(watchOS 9.1, *)' or newer instead")
    @available(tvOS, deprecated: 14.0, obsoleted: 16.1, message: "this code may crash on earlier versions of the OS; specify '#available(tvOS 16.1, *)' or newer instead")
    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public static func buildLimitedAvailability(_ scene: any Scene) -> any Scene & _LimitedAvailabilitySceneMarker {
        fatalError("Unavailable")
    }
}

@_marker
public protocol _LimitedAvailabilitySceneMarker {}
