//
//  CombiningTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E95479797AFE5A67B59EE39088DDE631 (SwiftUICore)

// MARK: - AnyTransition + combined

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    /// Combines this transition with another, returning a new transition that
    /// is the result of both transitions being applied.
    public func combined(with other: AnyTransition) -> AnyTransition {
        var firstVisitor = FirstVisitor(second: other, result: nil)
        visitBase(applying: &firstVisitor)
        return firstVisitor.result!
    }

    private struct FirstVisitor: TransitionVisitor {
        var second: AnyTransition
        var result: AnyTransition?

        mutating func visit<T>(_ transition: T) where T: Transition {
            var secondVisitor = SecondVisitor(first: transition, result: nil)
            second.visitBase(applying: &secondVisitor)
            result = secondVisitor.result
        }
    }

    private struct SecondVisitor<First>: TransitionVisitor where First: Transition {
        let first: First
        var result: AnyTransition?

        mutating func visit<T>(_ transition: T) where T: Transition {
            result = AnyTransition(CombiningTransition(transition1: first, transition2: transition))
        }
    }
}

// MARK: - Transition + combined

@available(OpenSwiftUI_v5_0, *)
extension Transition {

    /// Combines this transition with another, returning a new transition that
    /// is the result of both transitions being applied.
    @MainActor
    @preconcurrency
    public func combined<T>(with other: T) -> some Transition where T: Transition {
        CombiningTransition(transition1: self, transition2: other)
    }
}

// MARK: - CombiningTransition

/// A transition that combines two transitions.
struct CombiningTransition<First, Second>: Transition where First: Transition, Second: Transition {
    var transition1: First
    var transition2: Second

    init(transition1: First, transition2: Second) {
        self.transition1 = transition1
        self.transition2 = transition2
    }

    func body(content: Content, phase: TransitionPhase) -> some View {
        transition2.apply(
            content: transition1.apply(content: content, phase: phase),
            phase: phase
        )
    }

    static var properties: TransitionProperties {
        First.properties.union(Second.properties)
    }

    func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        switch transition.operation {
        case .hasContentTransition:
            transition.result = .bool(transition1.hasContentTransition || transition2.hasContentTransition)
        case .effects(let style, let size):
            var effects: [ContentTransition.Effect] = transition1.contentTransitionEffects(style: style, size: size)
            effects.append(contentsOf: transition2.contentTransitionEffects(style: style, size: size))
            transition.result = .effects(effects)
        }
    }
}

@available(*, unavailable)
extension CombiningTransition: Sendable {}