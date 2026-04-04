//
//  DisplayListAnimations.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B86250B2E056EB47628ECF46032DFA4C (SwiftUICore)

import Foundation

// MARK: - EffectAnimation

/// A private protocol that bridges animatable effect values to the display
/// list animation system.
///
/// Conforming types represent a transition between two effect values (e.g.
/// offset, scale, rotation, opacity) driven by a ``Animation``.
///
/// The protocol provides default implementations for ``ProtobufMessage``
/// encoding/decoding and for ``_DisplayList_AnyEffectAnimator`` creation
/// via ``EffectAnimator``.
private protocol EffectAnimation: _DisplayList_AnyEffectAnimation {
    /// The animatable effect value type
    associatedtype Value: Animatable, ProtobufMessage

    /// Creates an effect animation with the given endpoints and curve.
    init(from: Value, to: Value, animation: Animation)

    /// The starting effect value of the animation.
    var from: Value { get }

    /// The ending effect value of the animation.
    var to: Value { get set }

    /// The animation curve driving the transition from ``from`` to ``to``.
    var animation: Animation { get }

    /// Converts a current effect value and viewport size into a concrete
    /// display list effect.
    static func effect(value: Value, size: CGSize) -> DisplayList.Effect
}

extension EffectAnimation {
    func makeAnimator() -> any _DisplayList_AnyEffectAnimator {
        EffectAnimator<Self>(state: .pending)
    }

    func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, from)
        try encoder.messageField(2, to)
        let codableAnimation = CodableAnimation(base: animation)
        try encoder.messageField(3, codableAnimation)
    }

    init(from decoder: inout ProtobufDecoder) throws {
        var fromValue: Value?
        var toValue: Value?
        var animationValue: Animation?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                fromValue = try decoder.messageField(field)
            case 2:
                toValue = try decoder.messageField(field)
            case 3:
                let codable: CodableAnimation = try decoder.messageField(field)
                animationValue = codable.base
            default:
                try decoder.skipField(field)
            }
        }
        guard let fromValue, let toValue, let animationValue else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.init(from: fromValue, to: toValue, animation: animationValue)
    }
}

extension EffectAnimation where Value: GeometryEffect {
    static func effect(value: Value, size: CGSize) -> DisplayList.Effect {
        var origin = CGPoint.zero
        return DefaultGeometryEffectProvider<Value>.resolve(
            effect: value,
            origin: &origin,
            size: size,
            layoutDirection: .leftToRight
        )
    }
}

// MARK: - DisplayList + Animation

extension DisplayList {
    struct OffsetAnimation: EffectAnimation {
        static var leafProtobufTag: CodableEffectAnimation.Tag? { .init(rawValue: 1) }
        var from: _OffsetEffect
        var to: _OffsetEffect
        var animation: Animation
    }

    struct ScaleAnimation: EffectAnimation {
        static var leafProtobufTag: CodableEffectAnimation.Tag? { .init(rawValue: 2) }
        var from: _ScaleEffect
        var to: _ScaleEffect
        var animation: Animation
    }

    struct RotationAnimation: EffectAnimation {
        static var leafProtobufTag: CodableEffectAnimation.Tag? { .init(rawValue: 3) }
        var from: _RotationEffect
        var to: _RotationEffect
        var animation: Animation
    }

    struct OpacityAnimation: EffectAnimation {
        static var leafProtobufTag: CodableEffectAnimation.Tag? { .init(rawValue: 4) }
        var from: _OpacityEffect
        var to: _OpacityEffect
        var animation: Animation

        static func effect(value: _OpacityEffect, size: CGSize) -> DisplayList.Effect {
            value.effectValue(size: size)
        }
    }
}

// MARK: - EffectAnimator

/// Drives the frame-by-frame evaluation of an ``EffectAnimation``.
private struct EffectAnimator<Animation>: DisplayList.AnyEffectAnimator where Animation: EffectAnimation {
    enum State {
        /// No ``AnimatorState`` yet. On the first ``evaluate`` call the
        /// animator computes the animatable interval
        /// (`to.animatableData − from.animatableData`) and creates an
        /// ``AnimatorState`` starting at `Time.zero`.
        case pending

        /// An ``AnimatorState`` exists and is updated each frame. The
        /// animator interpolates the effect value and returns the
        /// corresponding ``DisplayList/Effect``.
        case active(AnimatorState<Animation.Value.AnimatableData>)

        /// ``AnimatorState/update`` returned `true`. The animator returns
        /// the final `to` effect value with no further interpolation.
        case finished
    }

    var state: State

    mutating func evaluate(
        _ animation: any DisplayList.AnyEffectAnimation,
        at time: Time,
        size: CGSize
    ) -> (DisplayList.Effect, finished: Bool) {
        guard let animation = animation as? Animation else {
            return (.identity, true)
        }

        if case .pending = state {
            let fromData = animation.from.animatableData
            var interval = animation.to.animatableData
            interval -= fromData
            state = .active(AnimatorState(
                animation: animation.animation,
                interval: interval,
                at: .zero,
                in: Transaction()
            ))
        }
        var toValue = animation.to
        let finished: Bool
        switch state {
        case .pending:
            _openSwiftUIUnreachableCode()
        case let .active(animState):
            var animatableData = toValue.animatableData
            finished = animState.update(&animatableData, at: time, environment: nil)
            if finished {
                state = .finished
            } else {
                toValue.animatableData = animatableData
            }
        case .finished:
            finished = true
        }
        return (Animation.effect(value: toValue, size: size), finished)
    }
}
