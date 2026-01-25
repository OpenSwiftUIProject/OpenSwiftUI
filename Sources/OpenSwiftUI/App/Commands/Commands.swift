//
//  Commands.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by MainMenuItem and Scene
//  ID: 0E12E75FDDFA412408873260803B3C8B (SwiftUI)

import OpenAttributeGraphShims
import COpenSwiftUI
@_spi(Private)
public import OpenSwiftUICore

#if canImport(CoreTransferable)
import CoreTransferable
#endif

// MARK: - Commands

/// Conforming types represent a group of related commands that can be exposed
/// to the user via the main menu on macOS and key commands on iOS.
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
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@preconcurrency
@MainActor
public protocol Commands {

    /// The type of commands that represents the body of this command hierarchy.
    ///
    /// When you create custom commands, Swift infers this type from your
    /// implementation of the required ``OpenSwiftUI/Commands/body-swift.property``
    /// property.
    associatedtype Body: Commands

    /// The contents of the command hierarchy.
    ///
    /// For any commands that you create, provide a computed `body` property
    /// that defines the scene as a composition of other scenes. You can
    /// assemble a command hierarchy from built-in commands that OpenSwiftUI
    /// provides, as well as other commands that you've defined.
    @CommandsBuilder
    var body: Body { get }

    /// Creates the outputs that the graph should represent for a given command
    /// hierarchy.
    ///
    /// - Note: clients should not implement this directly. Instead, OpenSwiftUI
    ///         provides a default implementation of this method.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated static func _makeCommands(
        content: _GraphValue<Self>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs

    func _resolve(into resolved: inout _ResolvedCommands)
}

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Commands {

    @available(OpenSwiftUI_v3_0, *)
    public static func _makeCommands(
        content: _GraphValue<Self>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = makeBody(commands: content, inputs: &inputs.base, fields: fields)
        defer {
            buffer?.traceMountedProperties(to: content, fields: fields)
        }
        let outputs = Body._makeCommands(content: body, inputs: inputs)
        return outputs
    }

    nonisolated private static func makeBody(
        commands: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        precondition(
            Metadata(Self.self).isValueType,
            "commands must be value types: \(Self.self)"
        )
        let accessor = CommandsBodyAccessor<Self>()
        return accessor.makeBody(container: commands, inputs: &inputs, fields: fields)
    }

    public func _resolve(
        into resolved: inout _ResolvedCommands
    ) {
        body._resolve(into: &resolved)
    }
}

// MARK: - PrimitiveCommands

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Never: Commands {}

protocol PrimitiveCommands: Commands where Body == Never {}

extension PrimitiveCommands {
    public var body: Never {
        _openSwiftUIUnreachableCode()
    }
}

// MARK: - EmptyCommands

/// An empty group of commands.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct EmptyCommands: PrimitiveCommands {

    @available(OpenSwiftUI_v3_0, *)
    nonisolated public static func _makeCommands(
        content: _GraphValue<Self>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        return .init()
    }

    /// Creates an empty command hierarchy.
    nonisolated public init() {
        _openSwiftUIEmptyStub()
    }

    @MainActor
    @preconcurrency
    public func _resolve(into: inout _ResolvedCommands) {
        _openSwiftUIEmptyStub()
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension EmptyCommands: Sendable {}

// MARK: - _ResolvedCommands [WIP]

/// The resolved value of flattening multiple `Commands`s into a single
/// result.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct _ResolvedCommands {
    var topLevelCommands: [CommandGroupPlacementBox] = []
    var storage: [CommandGroupPlacementBox: CommandAccumulator]
    var flags: Set<CommandFlag>

    func mainMenuItems(env: EnvironmentValues) -> [MainMenuItem] {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(*, unavailable)
extension _ResolvedCommands: Sendable {}

// MARK: - Scene + commands [WIP]

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Scene {

    /// Adds commands to the scene.
    ///
    /// Commands are realized in different ways on different platforms. On
    /// macOS, the main menu uses the available command menus and groups to
    /// organize its main menu items. Each menu is represented as a top-level
    /// menu bar menu, and each command group has a corresponding set of menu
    /// items in one of the top-level menus, delimited by separator menu items.
    ///
    /// On iPadOS, commands with keyboard shortcuts are exposed in the shortcut
    /// discoverability HUD that users see when they hold down the Command (⌘)
    /// key.
    nonisolated public func commands<Content>(
        @CommandsBuilder content: () -> Content
    ) -> some Scene where Content: Commands {
        // CommandModifier
        _openSwiftUIUnimplementedWarning()
        return self
    }
}

// MARK: - CommandsBuilder

/// Constructs command sets from multi-expression closures. Like `ViewBuilder`,
/// it supports up to ten expressions in the closure body.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@resultBuilder
public struct CommandsBuilder {
    @_alwaysEmitIntoClient
    public static func buildExpression<Content>(_ content: Content) -> Content where Content: Commands {
        content
    }

    @available(*, unavailable, message: "this expression does not conform to 'Commands'")
    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public static func buildExpression(_ invalid: Any) -> some Commands {
        buildBlock()
    }

    @_alwaysEmitIntoClient
    public static func buildBlock() -> EmptyCommands {
        EmptyCommands()
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C>(_ content: C) -> C where C: Commands {
        content
    }
}

@available(*, unavailable)
extension CommandsBuilder: Sendable {}

// MARK: - CommandsTypeVisitor

protocol CommandsTypeVisitor {
    mutating func visit<Content>(type: Content.Type) where Content: Commands
}

// MARK: - CommandsDescriptor

struct CommandsDescriptor: TupleDescriptor {
    static var typeCache: [ObjectIdentifier: TupleTypeDescription<CommandsDescriptor>] = [:]

    static var descriptor: UnsafeRawPointer {
        _commandsProtocolDescriptor()
    }
}

// MARK: - TypeConformance + CommandsDescriptor

extension TypeConformance where P == CommandsDescriptor {
    func visitType<V>(visitor: UnsafeMutablePointer<V>) where V: CommandsTypeVisitor {
        visitor.pointee.visit(type: unsafeExistentialMetatype((any Commands.Type).self))
    }
}

// MARK: - CommandsModifier [WIP]

struct CommandsModifier<Content>: PrimitiveSceneModifier where Content: Commands {
    var content: Content

    nonisolated static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        _openSwiftUIUnimplementedFailure()
    }

    private struct UpdateList: Rule {
        @Attribute var list: CommandsList

        var value: (inout CommandsList) -> () {
            { $0.items.append(contentsOf: list.items) }
        }
    }
}

// MARK: - CommandsKey

struct CommandsKey: HostPreferenceKey {
    typealias Value = (inout _ResolvedCommands) -> ()

    static var defaultValue: Value {
        { _ in }
    }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        let v1 = value
        let v2 = nextValue()
        value = { resolved in
            v1(&resolved)
            v2(&resolved)
        }
    }
}

// MARK: - CommandsBodyAccessor

private struct CommandsBodyAccessor<Content>: BodyAccessor where Content: Commands {

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
