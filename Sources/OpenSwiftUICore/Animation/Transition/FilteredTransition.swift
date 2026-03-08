//
//  FilteredTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B9F0F810276E171D84377A7686E819B9 (SwiftUICore)

// MARK: - AnyTransition + animation

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    /// Attaches an animation to this transition.
    public func animation(_ animation: Animation?) -> AnyTransition {
        var filterVisitor = FilterVisitor(filter: { t, _ in
            t.animation = animation
        }, result: nil)
        visitBase(applying: &filterVisitor)
        return filterVisitor.result!
    }

    private struct FilterVisitor: TransitionVisitor {
        var filter: (inout Transaction, TransitionPhase) -> Void
        var result: AnyTransition?

        mutating func visit<T>(_ transition: T) where T: Transition {
            result = AnyTransition(FilteredTransition(transition: transition, filter: filter))
        }
    }
}

// MARK: - Transition + animation

@available(OpenSwiftUI_v5_0, *)
extension Transition {

    /// Attaches an animation to this transition.
    @MainActor
    @preconcurrency
    public func animation(_ animation: Animation?) -> some Transition {
        transaction { t, _ in
            t.animation = animation
        }
    }

    func transaction(_ modify: @escaping (inout Transaction, TransitionPhase) -> Void) -> FilteredTransition<Self> {
        FilteredTransition(transition: self, filter: modify)
    }
}

// MARK: - FilteredTransition

/// A transition that applies a transaction filter.
struct FilteredTransition<Base>: Transition where Base: Transition {
    var transition: Base
    var filter: (inout Transaction, TransitionPhase) -> Void

    init(transition: Base, filter: @escaping (inout Transaction, TransitionPhase) -> Void) {
        self.transition = transition
        self.filter = filter
    }

    func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            ApplyTransitionModifier(transition: transition, phase: phase)
                .transaction { filter(&$0, phase) }
        )
    }

    static var properties: TransitionProperties {
        Base.properties
    }

    func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        self.transition._makeContentTransition(transition: &transition)
    }
}

@available(*, unavailable)
extension FilteredTransition: Sendable {}
