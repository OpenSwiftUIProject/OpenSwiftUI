//
//  TransitionTraitKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - ViewTraitCollection + canTransition

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct CanTransitionTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: Bool { false }
}

@available(*, unavailable)
extension CanTransitionTraitKey: Sendable {}

extension ViewTraitCollection {
    package var canTransition: Bool {
        get { self[CanTransitionTraitKey.self] }
        set { self[CanTransitionTraitKey.self] = newValue }
    }
}

// MARK: - ViewTraitCollection + transition

struct TransitionTraitKey: _ViewTraitKey {
    static var defaultValue: AnyTransition { .opacity }
}

extension ViewTraitCollection {
    package var transition: AnyTransition {
        self[TransitionTraitKey.self]
    }

    package func optionalTransition(ignoringIdentity: Bool) -> AnyTransition? {
        guard canTransition else {
            return nil
        }
        let transition = transition
        if ignoringIdentity, transition.isIdentity {
            return nil
        }
        return transition
    }

    package func optionalTransition() -> AnyTransition? {
        optionalTransition(ignoringIdentity: true)
    }
}
