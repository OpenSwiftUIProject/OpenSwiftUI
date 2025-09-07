//
//  TransitionPhase.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// An indication of which the current stage of a transition.
///
/// When a view is appearing with a transition, the transition will first be
/// shown with the `willAppear` phase, then will be immediately moved to the
/// `identity` phase. When a view is being removed, its transition is changed
/// from the `identity` phase to the `didDisappear` phase. If a view is removed
/// while it is still transitioning in, then its phase will change to
/// `didDisappear`. If a view is re-added while it is transitioning out, its
/// phase will change back to `identity`.
///
/// In the `identity` phase, transitions should generally not make any visual
/// change to the view they are applied to, since the transition's view
/// modifications in the `identity` phase will be applied to the view as long as
/// it is visible. In the `willAppear` and `didDisappear` phases, transitions
/// should apply a change that will be animated to create the transition. If no
/// animatable change is applied, then the transition will be a no-op.
///
/// - See Also: `Transition`
/// - See Also: `AnyTransition`
@available(OpenSwiftUI_v5_0, *)
@frozen
public enum TransitionPhase {
    /// The transition is being applied to a view that is about to be inserted
    /// into the view hierarchy.
    ///
    /// In this phase, a transition should show the appearance that will be
    /// animated from to make the appearance transition.
    case willAppear

    /// The transition is being applied to a view that is in the view hierarchy.
    ///
    /// In this phase, a transition should show its steady state appearance,
    /// which will generally not make any visual change to the view.
    case identity

    /// The transition is being applied to a view that has been requested to be
    /// removed from the view hierarchy.
    ///
    /// In this phase, a transition should show the appearance that will be
    /// animated to to make the disappearance transition.
    case didDisappear

    /// A Boolean that indicates whether the transition should have an identity
    /// effect, i.e. not change the appearance of its view.
    ///
    /// This is true in the `identity` phase.
    public var isIdentity: Bool {
        self == .identity
    }
}

@available(OpenSwiftUI_v5_0, *)
extension TransitionPhase: Equatable {}

@available(OpenSwiftUI_v5_0, *)
extension TransitionPhase: Hashable {}

@available(OpenSwiftUI_v5_0, *)
extension TransitionPhase {
    /// A value that can be used to multiply effects that are applied
    /// differently depending on the phase.
    ///
    /// - Returns: Zero when in the `identity` case, -1.0 for `willAppear`,
    ///   and 1.0 for `didDisappear`.
    public var value: Double {
        switch self {
        case .willAppear: return -1.0
        case .identity: return 0.0
        case .didDisappear: return 1.0
        }
    }
}
