//
//  Transition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims
package import OpenCoreGraphicsShims

// MARK: - Transition

/// A description of view changes to apply when a view is added to and removed
/// from the view hierarchy.
///
/// A transition should generally be made by applying one or more modifiers to
/// the `content`. For symmetric transitions, the `isIdentity` property on
/// `phase` can be used to change the properties of modifiers. For asymmetric
/// transitions, the phase itself can be used to change those properties.
/// Transitions should not use any identity-affecting changes like `.id`, `if`,
/// and `switch` on the `content`, since doing so would reset the state of the
/// view they're applied to, causing wasted work and potentially surprising
/// behavior when it appears and disappears.
///
/// The following code defines a transition that can be used to change the
/// opacity and rotation when a view appears and disappears.
///
///     struct RotatingFadeTransition: Transition {
///         func body(content: Content, phase: TransitionPhase) -> some View {
///             content
///               .opacity(phase.isIdentity ? 1.0 : 0.0)
///               .rotationEffect(phase.rotation)
///         }
///     }
///     extension TransitionPhase {
///         fileprivate var rotation: Angle {
///             switch self {
///             case .willAppear: return .degrees(30)
///             case .identity: return .zero
///             case .didDisappear: return .degrees(-30)
///             }
///         }
///     }
///
/// A type conforming to this protocol inherits `@preconcurrency @MainActor`
/// isolation from the protocol if the conformance is included in the type's
/// base declaration:
///
///     struct MyCustomType: Transition {
///         // `@preconcurrency @MainActor` isolation by default
///     }
///
/// Isolation to the main actor is the default, but it's not required. Declare
/// the conformance in an extension to opt out of main actor isolation:
///
///     extension MyCustomType: Transition {
///         // `nonisolated` by default
///     }
///
/// - See Also: `TransitionPhase`
/// - See Also: `AnyTransition`
@available(OpenSwiftUI_v5_0, *)
@MainActor
@preconcurrency
public protocol Transition {
    /// The type of view representing the body.
    associatedtype Body: View

    /// Gets the current body of the caller.
    ///
    /// `content` is a proxy for the view that will have the modifier
    /// represented by `Self` applied to it.
    @ViewBuilder
    func body(content: Content, phase: TransitionPhase) -> Body

    /// Returns the properties this transition type has.
    ///
    /// Defaults to `TransitionProperties()`.
    static var properties: TransitionProperties { get }

    /// The content view type passed to `body()`.
    typealias Content = PlaceholderContentView<Self>

    func _makeContentTransition(transition: inout _Transition_ContentTransition)
}

@available(OpenSwiftUI_v5_0, *)
extension Transition {
    public static var properties: TransitionProperties {
        TransitionProperties()
    }

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        guard case .hasContentTransition = transition.operation else {
            return
        }
        transition.result = .bool(false)
    }

    public func apply(content: some View, phase: TransitionPhase) -> some View {
        content.modifier(ApplyTransitionModifier(transition: self, phase: phase))
    }
}

@available(OpenSwiftUI_v5_0, *)
extension Transition {
    package static func makeView(
        view: _GraphValue<Body>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs,
    ) -> _ViewOutputs {
        var bodyInputs = inputs
        bodyInputs.pushModifierBody(PlaceholderContentView<Self>.self, body: body)
        return Body.makeDebuggableView(view: view, inputs: bodyInputs)
    }

    package var hasContentTransition: Bool {
        var contentTransition = _Transition_ContentTransition(operation: .hasContentTransition, result: .none)
        _makeContentTransition(transition: &contentTransition)
        guard case let .bool(result) = contentTransition.result else {
            return false
        }
        return result
    }

    package func contentTransitionEffects(
        style: ContentTransition.Style,
        size: CGSize
    ) -> [ContentTransition.Effect] {
        var contentTransition = _Transition_ContentTransition(operation: .effects(style: style, size: size), result: .none)
        _makeContentTransition(transition: &contentTransition)
        guard case let .effects(effects) = contentTransition.result else {
            return []
        }
        return effects
    }
}

// MARK: - ApplyTransitionModifier

package struct ApplyTransitionModifier<TransitionType>: PrimitiveViewModifier, MultiViewModifier where TransitionType: Transition {
    package var transition: TransitionType

    package var phase: TransitionPhase

    package init(transition: TransitionType, phase: TransitionPhase) {
        self.transition = transition
        self.phase = phase
    }

    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        .init()
    }

    nonisolated package static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        nil
    }

    private struct Child: Rule, AsyncAttribute {
        @Attribute var modifier: ApplyTransitionModifier

        var value: TransitionType.Body {
            withObservation {
                $modifier.syncMainIfReferences { modifier in
                    modifier.transition.body(content: .init(), phase: modifier.phase)
                }
            }
        }
    }
}

// MARK: - _Transition_ContentTransition

@available(OpenSwiftUI_v5_0, *)
public struct _Transition_ContentTransition {
    package enum Operation {
        case hasContentTransition
        case effects(style: ContentTransition.Style, size: CGSize)
    }

    package enum Result {
        case none
        case bool(Bool)
        case effects(_: [ContentTransition.Effect] = [])
    }

    package var operation: Operation

    package var result: Result
}

@available(*, unavailable)
extension _Transition_ContentTransition: Sendable {}

// MARK: - TransitionPhase

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

// MARK: - TransitionProperties

/// The properties a `Transition` can have.
///
/// A transition can have properties that specify high level information about
/// it. This can determine how a transition interacts with other features like
/// Accessibility settings.
///
/// - See Also: `Transition`
@available(OpenSwiftUI_v5_0, *)
public struct TransitionProperties: Sendable {
    /// Whether the transition includes motion.
    ///
    /// When this behavior is included in a transition, that transition will be
    /// replaced by opacity when Reduce Motion is enabled.
    ///
    /// Defaults to `true`.
    public var hasMotion: Bool

    public init(hasMotion: Bool = true) {
        self.hasMotion = hasMotion
    }

    package func union(_ other: TransitionProperties) -> TransitionProperties {
        TransitionProperties(hasMotion: hasMotion || other.hasMotion)
    }
}

// MARK: - IdentityTransition

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {
    /// A transition that returns the input view, unmodified, as the output
    /// view.
    public static let identity: AnyTransition = .init(IdentityTransition())
}

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == IdentityTransition {
    /// A transition that returns the input view, unmodified, as the output
    /// view.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var identity: IdentityTransition {
        IdentityTransition()
    }
}

/// A transition that returns the input view, unmodified, as the output
/// view.
@available(OpenSwiftUI_v5_0, *)
public struct IdentityTransition: Transition {
    public init() {}

    public func body(content: Content, phase: TransitionPhase) -> Content {
        content
    }

    public static let properties: TransitionProperties = .init(hasMotion: false)

    public func _makeContentTransition(transition: inout _Transition_ContentTransition) {
        guard case .hasContentTransition = transition.operation else {
            return
        }
        transition.result = .bool(true)
    }
}

@available(*, unavailable)
extension IdentityTransition: Sendable {}
