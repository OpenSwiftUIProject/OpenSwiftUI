//
//  ModifierTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - AnyTransition + modifier

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    /// Returns a transition defined between an active modifier and an identity
    /// modifier.
    public static func modifier<E>(active: E, identity: E) -> AnyTransition where E: ViewModifier {
        .init(ModifierTransition(activeModifier: active, identityModifier: identity))
    }
}

// MARK: - ModifierTransition

/// A transition defined between an active modifier and an identity modifier.
struct ModifierTransition<Modifier>: Transition where Modifier: ViewModifier {
    /// The modifier applied when the view is not in the identity phase.
    var activeModifier: Modifier

    /// The modifier applied when the view is in the identity phase.
    var identityModifier: Modifier

    /// Creates a transition defined between an active modifier and an identity
    /// modifier.
    init(activeModifier: Modifier, identityModifier: Modifier) {
        self.activeModifier = activeModifier
        self.identityModifier = identityModifier
    }

    func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(phase.isIdentity ? identityModifier : activeModifier)
    }
}

@available(*, unavailable)
extension ModifierTransition: Sendable {}

