//
//  MoveTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenCoreGraphicsShims

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    /// Returns a transition that moves the view away, towards the specified
    /// edge of the view.
    public static func move(edge: Edge) -> AnyTransition {
        .init(MoveTransition(edge: edge))
    }
}

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == MoveTransition {

    /// Returns a transition that moves the view away, towards the specified
    /// edge of the view.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency public static func move(edge: Edge) -> Self {
        Self(edge: edge)
    }
}

/// Returns a transition that moves the view away, towards the specified
/// edge of the view.
@available(OpenSwiftUI_v5_0, *)
public struct MoveTransition: Transition {

    /// The edge to move the view towards.
    public var edge: Edge

    /// Creates a transition that moves the view away, towards the specified
    /// edge of the view.
    public init(edge: Edge) {
        self.edge = edge
    }

    public func body(
        content: Content,
        phase: TransitionPhase
    ) -> some View {
        content.modifier(
            MoveLayout(edge: phase == .identity ? nil : edge)
        )
    }

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        guard case let .effects(_, size) = transition.operation else {
            transition.result = .bool(true)
            return
        }
        let effectiveSize = edge.translationOffset(for: size)
        let effect = ContentTransition.Effect(.translation(effectiveSize))
        transition.result = .effects([effect])
    }

    struct MoveLayout: UnaryLayout {
        let edge: Edge?

        func placement(
            of child: LayoutProxy,
            in context: PlacementContext
        ) -> _Placement {
            let anchorPosition = if let edge {
                CGPoint(edge.translationOffset(for: context.size))
            } else {
                CGPoint.zero
            }
            return _Placement(
                proposedSize: context.proposedSize,
                at: anchorPosition
            )
        }

        func sizeThatFits(
            in proposedSize: _ProposedSize,
            context: SizeAndSpacingContext,
            child: LayoutProxy
        ) -> CGSize {
            child.size(in: proposedSize)
        }
    }
}

@available(*, unavailable)
extension MoveTransition: Sendable {}

extension Edge {
    @inline(__always)
    fileprivate func translationOffset(for size: CGSize) -> CGSize {
        switch self {
        case .top:
            return CGSize(width: 0, height: -size.height)
        case .leading:
            return CGSize(width: -size.width, height: 0)
        case .bottom:
            return CGSize(width: 0, height: size.height)
        case .trailing:
            return CGSize(width: size.width, height: 0)
        }
    }
}
