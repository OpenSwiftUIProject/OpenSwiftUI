//
//  PushTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenCoreGraphicsShims

// MARK: - AnyTransition + push

@available(OpenSwiftUI_v4_0, *)
extension AnyTransition {

    /// Creates a transition that when added to a view will animate the
    /// view's insertion by moving it in from the specified edge while
    /// fading it in, and animate its removal by moving it out towards
    /// the opposite edge and fading it out.
    ///
    /// - Parameters:
    ///   - edge: the edge from which the view will be animated in.
    ///
    /// - Returns: A transition that animates a view by moving and
    ///   fading it.
    public static func push(from edge: Edge) -> AnyTransition {
        .init(PushTransition(edge: edge))
    }
}

// MARK: - Transition + push

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == PushTransition {

    /// Creates a transition that when added to a view will animate the
    /// view's insertion by moving it in from the specified edge while
    /// fading it in, and animate its removal by moving it out towards
    /// the opposite edge and fading it out.
    ///
    /// - Parameters:
    ///   - edge: the edge from which the view will be animated in.
    ///
    /// - Returns: A transition that animates a view by moving and
    ///   fading it.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static func push(from edge: Edge) -> Self {
        Self(edge: edge)
    }
}

// MARK: - PushTransition

/// A transition that when added to a view will animate the view's insertion by
/// moving it in from the specified edge while fading it in, and animate its
/// removal by moving it out towards the opposite edge and fading it out.
@available(OpenSwiftUI_v5_0, *)
public struct PushTransition: Transition {

    /// The edge from which the view will be animated in.
    public var edge: Edge

    /// Creates a transition that animates a view by moving and fading it.
    public init(edge: Edge) {
        self.edge = edge
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        let moveEdge: Edge? = switch phase {
        case .willAppear: edge
        case .identity: nil
        case .didDisappear: edge.opposite
        }
        content
            .modifier(MoveTransition.MoveLayout(edge: moveEdge))
            .opacity(phase.isIdentity ? 1 : 0)
    }

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        guard case let .effects(style, size) = transition.operation else {
            transition.result = .bool(true)
            return
        }
        var effectiveSize = edge.translationOffset(for: size)
        if style != .default {
            effectiveSize.width *= 0.4
            effectiveSize.height *= 0.4
        }
        let insertionEffect = ContentTransition.Effect(
            .translation(effectiveSize),
            appliesOnInsertion: true,
            appliesOnRemoval: false
        )
        let removalEffect = ContentTransition.Effect(
            .translation(-effectiveSize),
            appliesOnInsertion: false,
            appliesOnRemoval: true
        )
        let opacityEffect = ContentTransition.Effect(.opacity)
        transition.result = .effects([insertionEffect, removalEffect, opacityEffect])
    }
}

@available(*, unavailable)
extension PushTransition: Sendable {}
