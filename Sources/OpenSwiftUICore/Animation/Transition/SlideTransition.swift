//
//  SlideTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    /// A transition that inserts by moving in from the leading edge, and
    /// removes by moving out towards the trailing edge.
    ///
    /// - SeeAlso: `AnyTransition.move(edge:)`
    public static var slide: AnyTransition {
        .init(SlideTransition())
    }
}

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == SlideTransition {

    /// A transition that inserts by moving in from the leading edge, and
    /// removes by moving out towards the trailing edge.
    ///
    /// - SeeAlso: `AnyTransition.move(edge:)`
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var slide: SlideTransition {
        Self()
    }
}

/// A transition that inserts by moving in from the leading edge, and
/// removes by moving out towards the trailing edge.
///
/// - SeeAlso: `MoveTransition`
@available(OpenSwiftUI_v5_0, *)
public struct SlideTransition: Transition {

    public init() {
        _openSwiftUIEmptyStub()
    }

    public func body(
        content: Content,
        phase: TransitionPhase
    ) -> some View {
        let edge: Edge? = switch phase {
        case .willAppear: .leading
        case .identity: nil
        case .didDisappear: .trailing
        }
        content.modifier(MoveTransition.MoveLayout(edge: edge))
    }
}

@available(*, unavailable)
extension SlideTransition: Sendable {}
