//
//  Commands.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 0E12E75FDDFA412408873260803B3C8B (SwiftUI)

package import OpenSwiftUICore

// MARK: - Commands [WIP]

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
        _openSwiftUIUnimplementedFailure()
    }

    public func _resolve(
        into resolved: inout _ResolvedCommands
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - PrimitiveCommands

extension Never: Commands {
    public typealias Body = Never
}

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
//    var topLevelCommands: [CommandGroupPlacementBox] = []
//    var storage: [CommandGroupPlacementBox: CommandAccumulator]
//    var flags: Set<CommandFlag>
    //func mainMenuItems(env: EnvironmentValues) -> [MainMenuItem]
}

@available(*, unavailable)
extension _ResolvedCommands: Sendable {}

// MARK: - Scene + commands [WIP]

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Scene {
    nonisolated public func commands<Content>(
        @CommandsBuilder content: () -> Content
    ) -> some Scene where Content: Commands {
        // CommandModifier
        _openSwiftUIUnimplementedWarning()
        return self
    }
}
