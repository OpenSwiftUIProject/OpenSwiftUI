//
//  BlurTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A4BD5A1CB1233579E2E5EB40492B5E89 (SwiftUI)

public import Foundation

// MARK: - AnyTransition + blur

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension AnyTransition {

    /// Creates a transition that blurs the view when being inserted or removed.
    ///
    /// - Parameter radius: The blur radius. The default value is `10`.
    ///
    /// - Returns: A transition that applies a blur effect.
    public static func blur(radius: CGFloat = 10) -> AnyTransition {
        .init(BlurAndFadeTransition(radius: radius))
    }
}

// MARK: - Transition + blurReplace

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == BlurReplaceTransition {

    /// A transition that animates the insertion or removal of a view
    /// by combining blurring and scaling effects.
    @MainActor
    @preconcurrency
    public static func blurReplace(_ config: BlurReplaceTransition.Configuration = .downUp) -> Self {
        return Self(configuration: config)
    }

    /// A transition that animates the insertion or removal of a view
    /// by combining blurring and scaling effects.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var blurReplace: BlurReplaceTransition {
        blurReplace(.downUp)
    }
}

// MARK: - BlurReplaceTransition

/// A transition that animates the insertion or removal of a view by
/// combining blurring and scaling effects.
@available(OpenSwiftUI_v5_0, *)
@MainActor
@preconcurrency
public struct BlurReplaceTransition: Transition {

    // MARK: - BlurReplaceTransition.Configuration

    /// Configuration properties for a transition.
    public struct Configuration: Equatable {
        package enum Storage: Equatable {
            case downUp
            case upUp
        }

        package var storage: Storage

        package init(_ storage: Storage) {
            self.storage = storage
        }

        /// A configuration that requests a transition that scales the
        /// view down while removing it and up while inserting it.
        public static let downUp = Configuration(.downUp)

        /// A configuration that requests a transition that scales the
        /// view up while both removing and inserting it.
        public static let upUp = Configuration(.upUp)
    }

    /// The transition configuration.
    public var configuration: Configuration

    /// Creates a new transition.
    ///
    /// - Parameter configuration: the transition configuration.
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        let scale: CGFloat = switch phase {
        case .identity: 1.0
        case .willAppear: 0.9
        case .didDisappear: configuration.storage == .upUp ? 1.1 : 0.9
        }
        content
            .opacity(phase.isIdentity ? 1 : 0)
            .blur(radius: phase.isIdentity ? 0 : 7)
            .scaleEffect(scale)
    }

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        guard case .effects = transition.operation else {
            transition.result = .bool(true)
            return
        }
        transition.result = .effects(configuration.effects)
    }
}

@available(*, unavailable)
extension BlurReplaceTransition: Sendable {}

@available(*, unavailable)
extension BlurReplaceTransition.Configuration: Sendable {}

// MARK: - BlurReplaceTransition.Configuration + effects

@available(OpenSwiftUI_v5_0, *)
extension BlurReplaceTransition.Configuration {

    fileprivate var effects: [ContentTransition.Effect] {
        let opacityEffect = ContentTransition.Effect(
            type: .opacity,
            begin: 0.33,
            duration: 0.67
        )
        let blurEffect = ContentTransition.Effect(
            type: .blur(radius: 7),
            begin: 0.33,
            duration: 0.67
        )
        let scaleEffect = ContentTransition.Effect(
            type: .scale(0.9),
            begin: 0.33,
            duration: 0.67,
            flags: .init(rawValue: storage == .upUp ? 1 : 0)
        )
        return [opacityEffect, blurEffect, scaleEffect]
    }
}

// MARK: - BlurAndFadeTransition

private struct BlurAndFadeTransition: Transition {
    var radius: CGFloat

    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .blur(radius: phase.isIdentity ? 0 : radius)
            .opacity(phase.isIdentity ? 1 : 0)
    }

    func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        guard case .effects = transition.operation else {
            transition.result = .bool(true)
            return
        }
        let blurEffect = ContentTransition.Effect(.blur(radius: radius))
        let opacityEffect = ContentTransition.Effect(.opacity)
        transition.result = .effects([blurEffect, opacityEffect])
    }
}

@available(*, unavailable)
extension BlurAndFadeTransition: Sendable {}
