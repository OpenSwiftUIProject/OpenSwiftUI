//
//  TransitionTraitKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - View + transition

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Associates a transition with the view.
    ///
    /// When this view appears or disappears, the transition will be applied to
    /// it, allowing for animating it in and out.
    ///
    /// The following code will conditionally show MyView, and when it appears
    /// or disappears, will use a slide transition to show it.
    ///
    ///     if isActive {
    ///         MyView()
    ///             .transition(.slide)
    ///     }
    ///     Button("Toggle") {
    ///         withAnimation {
    ///             isActive.toggle()
    ///         }
    ///     }
    @inlinable
    @_disfavoredOverload
    nonisolated public func transition(_ t: AnyTransition) -> some View {
        return _trait(TransitionTraitKey.self, t)
    }

    /// Associates a transition with the view.
    ///
    /// When this view appears or disappears, the transition will be applied to
    /// it, allowing for animating it in and out.
    ///
    /// The following code will conditionally show MyView, and when it appears
    /// or disappears, will use a custom RotatingFadeTransition transition to
    /// show it.
    ///
    ///     if isActive {
    ///         MyView()
    ///             .transition(RotatingFadeTransition())
    ///     }
    ///     Button("Toggle") {
    ///         withAnimation {
    ///             isActive.toggle()
    ///         }
    ///     }
    @available(OpenSwiftUI_v5_0, *)
    @_alwaysEmitIntoClient
    nonisolated public func transition<T>(_ transition: T) -> some View where T: Transition {
        self.transition(AnyTransition(transition))
    }
}

// MARK: - TransitionTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct TransitionTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: AnyTransition { .opacity }
}

@available(*, unavailable)
extension TransitionTraitKey: Sendable {}

// MARK: - CanTransitionTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct CanTransitionTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: Bool { false }
}

@available(*, unavailable)
extension CanTransitionTraitKey: Sendable {}

// MARK: - ViewTraitCollection + canTransition

extension ViewTraitCollection {
    package var canTransition: Bool {
        get { self[CanTransitionTraitKey.self] }
        set { self[CanTransitionTraitKey.self] = newValue }
    }
}

// MARK: - ViewTraitCollection + transition

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
