//
//  CustomAnimationModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

package protocol CustomAnimationModifier: Hashable {
    func animate<V, B>(
        base: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic, B: CustomAnimation

    func velocity<V, B>(
        base: B,
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic, B: CustomAnimation

    func shouldMerge<V, B>(
        base: B,
        previous: Self,
        previousBase: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic, B: CustomAnimation

    func function(base: Animation.Function) -> Animation.Function
}

extension CustomAnimationModifier {
    package func velocity<V, B>(
        base: B,
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic, B: CustomAnimation {
        nil
    }

    package func shouldMerge<V, B>(
        base: B,
        previous: Self,
        previousBase: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic, B: CustomAnimation {
        self == previous && base.shouldMerge(
            previous: Animation(previousBase),
            value: value,
            time: time,
            context: &context
        )
    }
}

extension Animation {
    package func modifier<M>(_ modifier: M) -> Animation where M: CustomAnimationModifier {
        box.modifier(modifier)
    }
}

package struct CustomAnimationModifiedContent<Base, Modifier>: InternalCustomAnimation
    where Base: CustomAnimation, Modifier: CustomAnimationModifier {
    package var base: Base

    package var modifier: Modifier

    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        modifier.animate(
            base: base,
            value: value,
            time: time,
            context: &context
        )
    }

    package func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        modifier.velocity(
            base: base,
            value: value,
            time: time,
            context: context
        )
    }

    package func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        guard let previousBase = previous.base as? Base else {
            return false
        }
        return modifier.shouldMerge(
            base: base,
            previous: modifier,
            previousBase: previousBase,
            value: value,
            time: time,
            context: &context
        )
    }

    package var function: Animation.Function {
        modifier.function(base: .custom(base))
    }
}

extension CustomAnimationModifiedContent: EncodableAnimation {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        let encodableAnimation: any EncodableAnimation
        if let encodableBase = base as? EncodableAnimation {
            encodableAnimation = encodableBase
        } else {
            encodableAnimation = DefaultAnimation()
        }
        try encodableAnimation.encodeAnimation(to: &encoder)
        if let encodableModifier = modifier as? ProtobufEncodableMessage {
            try encodableModifier.encode(to: &encoder)
        }
    }
}

package struct InternalCustomAnimationModifiedContent<Base, Modifier>: InternalCustomAnimation where Base: InternalCustomAnimation, Modifier: CustomAnimationModifier {
    package typealias _Base = CustomAnimationModifiedContent<Base, Modifier>

    package var _base: _Base

    package init(base: Base, modifier: Modifier) {
        _base = _Base(base: base, modifier: modifier)
    }

    package var base: Base {
        _base.base
    }

    package var modifier: Modifier {
        _base.modifier
    }

    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        modifier.animate(
            base: base,
            value: value,
            time: time,
            context: &context
        )
    }

    package func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        modifier.velocity(
            base: base,
            value: value,
            time: time,
            context: context
        )
    }

    package func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        guard let previousBase = previous.base as? Base else {
            return false
        }
        return modifier.shouldMerge(
            base: base,
            previous: modifier,
            previousBase: previousBase,
            value: value,
            time: time,
            context: &context
        )
    }

    package var function: Animation.Function {
        modifier.function(base: base.function)
    }
}

extension InternalCustomAnimationModifiedContent: EncodableAnimation {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try _base.encode(to: &encoder)
    }
}
