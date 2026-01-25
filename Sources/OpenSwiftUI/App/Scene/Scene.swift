//
//  Scene.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0097A5536FDAF33A03BB54B9D6A80407 (SwiftUI)

#if canImport(CoreTransferable)
import CoreTransferable
#endif
import COpenSwiftUI
import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - Scene

/// A part of an app's user interface with a life cycle managed by the
/// system.
///
/// You create an ``OpenSwiftUI/App`` by combining one or more instances
/// that conform to the `Scene` protocol in the app's
/// ``OpenSwiftUI/App/body-swift.property``. You can use the built-in scenes that
/// OpenSwiftUI provides, like ``OpenSwiftUI/WindowGroup``, along with custom scenes
/// that you compose from other scenes. To create a custom scene, declare a
/// type that conforms to the `Scene` protocol. Implement the required
/// ``OpenSwiftUI/Scene/body-swift.property`` computed property and provide the
/// content for your custom scene:
///
///     struct MyScene: Scene {
///         var body: some Scene {
///             WindowGroup {
///                 MyRootView()
///             }
///         }
///     }
///
/// A scene acts as a container for a view hierarchy that you want to display
/// to the user. The system decides when and how to present the view hierarchy
/// in the user interface in a way that's platform-appropriate and dependent
/// on the current state of the app. For example, for the window group shown
/// above, the system lets the user create or remove windows that contain
/// `MyRootView` on platforms like macOS and iPadOS. On other platforms, the
/// same view hierarchy might consume the entire display when active.
///
/// Read the ``OpenSwiftUI/EnvironmentValues/scenePhase`` environment
/// value from within a scene or one of its views to check whether a scene is
/// active or in some other state. You can create a property that contains the
/// scene phase, which is one of the values in the ``OpenSwiftUI/ScenePhase``
/// enumeration, using the ``OpenSwiftUI/Environment`` attribute:
///
///     struct MyScene: Scene {
///         @Environment(\.scenePhase) private var scenePhase
///
///         // ...
///     }
///
/// The `Scene` protocol provides scene modifiers, defined as protocol methods
/// with default implementations, that you use to configure a scene. For
/// example, you can use the ``OpenSwiftUI/Scene/onChange(of:perform:)`` modifier to
/// trigger an action when a value changes. The following code empties a cache
/// when all of the scenes in the window group have moved to the background:
///
///     struct MyScene: Scene {
///         @Environment(\.scenePhase) private var scenePhase
///         @StateObject private var cache = DataCache()
///
///         var body: some Scene {
///             WindowGroup {
///                 MyRootView()
///             }
///             .onChange(of: scenePhase) { newScenePhase in
///                 if newScenePhase == .background {
///                     cache.empty()
///                 }
///             }
///         }
///     }
///
/// A type conforming to this protocol inherits `@preconcurrency @MainActor`
/// isolation from the protocol if the conformance is included in the type's
/// base declaration:
///
///     struct MyCustomType: Transition {
///         // `@preconcurrency @MainActor` isolation by default
///     }
///
/// Isolation to the main actor is the default, but it's not required. Declare
/// the conformance in an extension to opt out of main actor isolation:
///
///     extension MyCustomType: Transition {
///         // `nonisolated` by default
///     }
///
@available(OpenSwiftUI_v2_0, *)
@MainActor
@preconcurrency
public protocol Scene {

    /// The type of scene that represents the body of this scene.
    ///
    /// When you create a custom scene, Swift infers this type from your
    /// implementation of the required ``OpenSwiftUI/Scene/body-swift.property``
    /// property.
    associatedtype Body: Scene

    /// The content and behavior of the scene.
    ///
    /// For any scene that you create, provide a computed `body` property that
    /// defines the scene as a composition of other scenes. You can assemble a
    /// scene from built-in scenes that OpenSwiftUI provides, as well as other
    /// scenes that you've defined.
    ///
    /// Swift infers the scene's ``OpenSwiftUI/Scene/Body-swift.associatedtype``
    /// associated type based on the contents of the `body` property.
    @SceneBuilder
    var body: Body { get }

    /// Creates the outputs that the graph should represent for a given scene.
    ///
    /// - Note: clients should not implement this directly. Instead, OpenSwiftUI
    ///         provides a default implementation of this method.
    nonisolated static func _makeScene(
        scene: _GraphValue<Self>,
        inputs: _SceneInputs
    ) -> _SceneOutputs
}

@available(OpenSwiftUI_v2_0, *)
extension Scene {

    nonisolated public static func _makeScene(
        scene: _GraphValue<Self>,
        inputs: _SceneInputs
    ) -> _SceneOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = makeBody(scene: scene, inputs: &inputs.base, fields: fields)

        defer {
            buffer?.traceMountedProperties(to: scene, fields: fields)
        }
        let outputs = Body._makeScene(scene: body, inputs: inputs)
        return outputs
    }

    nonisolated private static func makeBody(
        scene: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        precondition(
            Metadata(Self.self).isValueType,
            "apps must be value types: \(Self.self)"
        )
        let accessor = SceneBodyAccessor<Self>()
        return accessor.makeBody(container: scene, inputs: &inputs, fields: fields)
    }
}

// MARK: - PrimitiveScene

@available(OpenSwiftUI_v2_0, *)
extension Never: Scene {}

protocol PrimitiveScene: Scene where Body == Never {}

extension PrimitiveScene {
    public var body: Never {
        sceneBodyError()
    }
}

extension Scene {
    func sceneBodyError() -> Never {
        preconditionFailure("body() should not be called on \(Self.self).")
    }
}

// MARK: - SceneTypeVisitor

protocol SceneTypeVisitor {
    mutating func visit<S>(type: S.Type) where S: Scene
}

// MARK: - CommandsDescriptor

struct SceneDescriptor: TupleDescriptor {
    static var typeCache: [ObjectIdentifier: TupleTypeDescription<SceneDescriptor>] = [:]

    static var descriptor: UnsafeRawPointer {
        _sceneProtocolDescriptor()
    }
}

// MARK: - TypeConformance + SceneDescriptor

extension TypeConformance where P == SceneDescriptor {
    func visitType<V>(visitor: UnsafeMutablePointer<V>) where V: SceneTypeVisitor {
        visitor.pointee.visit(type: unsafeBitCast(self, to: (any Scene.Type).self))
    }
}

// MARK: - SceneBodyAccessor

private struct SceneBodyAccessor<Content>: BodyAccessor where Content: Scene {

    typealias Container = Content

    typealias Body = Content.Body

    init() {
        _openSwiftUIEmptyStub()
    }

    func updateBody(of container: Content, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body
        }
    }
}
