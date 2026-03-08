//
//  AsymmetricTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 144244338250150A46EBD0B28C550067 (SwiftUICore)

// MARK: - AnyTransition + asymmetric

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    /// Provides a composite transition that uses a different transition for
    /// insertion versus removal.
    public static func asymmetric(insertion: AnyTransition, removal: AnyTransition) -> AnyTransition {
        var insertionVisitor = InsertionVisitor(removal: removal, result: nil)
        insertion.visitBase(applying: &insertionVisitor)
        return insertionVisitor.result!
    }

    private struct InsertionVisitor: TransitionVisitor {
        var removal: AnyTransition
        var result: AnyTransition?

        mutating func visit<T>(_ transition: T) where T: Transition {
            var removalVisitor = RemovalVisitor(insertion: transition, result: nil)
            removal.visitBase(applying: &removalVisitor)
            result = removalVisitor.result
        }
    }

    private struct RemovalVisitor<Insertion>: TransitionVisitor where Insertion: Transition {
        let insertion: Insertion
        var result: AnyTransition?

        mutating func visit<T>(_ transition: T) where T: Transition {
            result = AnyTransition(AsymmetricTransition(insertion: insertion, removal: transition))
        }
    }
}

// MARK: - AsymmetricTransition

/// A composite `Transition` that uses a different transition for
/// insertion versus removal.
@available(OpenSwiftUI_v5_0, *)
public struct AsymmetricTransition<Insertion, Removal>: Transition where Insertion: Transition, Removal: Transition {
    /// The `Transition` defining the insertion phase of `self`.
    public var insertion: Insertion

    /// The `Transition` defining the removal phase of `self`.
    public var removal: Removal

    /// Creates a composite `Transition` that uses a different transition for
    /// insertion versus removal.
    public init(insertion: Insertion, removal: Removal) {
        self.insertion = insertion
        self.removal = removal
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        removal.apply(
            content: insertion.apply(
                content: content,
                phase: phase != .didDisappear ? phase : .identity
            ),
            phase: phase == .didDisappear ? phase : .identity
        )
    }

    public static var properties: TransitionProperties {
        Insertion.properties.union(Removal.properties)
    }

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        switch transition.operation {
        case .hasContentTransition:
            transition.result = .bool(insertion.hasContentTransition || removal.hasContentTransition)
        case .effects(let style, let size):
            var effects: [ContentTransition.Effect] = []
            let insertionEffects = insertion.contentTransitionEffects(style: style, size: size)
            for effect in insertionEffects {
                effects.append(
                    ContentTransition.Effect(
                        type: effect.type,
                        begin: effect.begin,
                        duration: effect.duration,
                        events: .add,
                        flags: effect.flags
                    )
                )
            }
            let removalEffects = removal.contentTransitionEffects(style: style, size: size)
            for effect in removalEffects {
                effects.append(
                    ContentTransition.Effect(
                        type: effect.type,
                        begin: effect.begin,
                        duration: effect.duration,
                        events: .remove,
                        flags: effect.flags
                    )
                )
            }
            transition.result = .effects(effects)
        }
    }
}

@available(*, unavailable)
extension AsymmetricTransition: Sendable {}
