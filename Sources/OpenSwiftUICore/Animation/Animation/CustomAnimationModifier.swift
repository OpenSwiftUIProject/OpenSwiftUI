//
//  CustomAnimationModifier.swift
//  OpenSwiftUICore
//
//  Status: WIP

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
        _openSwiftUIUnimplementedFailure()
    }

    package func shouldMerge<V, B>(
        base: B,
        previous: Self,
        previousBase: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic, B: CustomAnimation {
        _openSwiftUIUnimplementedFailure()
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
        _openSwiftUIUnimplementedFailure()
    }

    package func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        _openSwiftUIUnimplementedFailure()
    }

    package func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        _openSwiftUIUnimplementedFailure()
    }

    package var function: Animation.Function {
        _openSwiftUIUnimplementedFailure()
    }

    package func hash(into hasher: inout Hasher) {
        _openSwiftUIUnimplementedFailure()
    }

    package static func == (a: CustomAnimationModifiedContent<Base, Modifier>, b: CustomAnimationModifiedContent<Base, Modifier>) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package var hashValue: Int {
        _openSwiftUIUnimplementedFailure()
    }
}

extension CustomAnimationModifiedContent {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

package struct InternalCustomAnimationModifiedContent<Base, Modifier>: InternalCustomAnimation where Base: InternalCustomAnimation, Modifier: CustomAnimationModifier {
    package typealias _Base = CustomAnimationModifiedContent<Base, Modifier>
    package var _base: InternalCustomAnimationModifiedContent<Base, Modifier>._Base

    package init(base: Base, modifier: Modifier) {
        _openSwiftUIUnimplementedFailure()
    }

    package var base: Base {
        _openSwiftUIUnimplementedFailure()
    }

    package var modifier: Modifier {
        _openSwiftUIUnimplementedFailure()
    }

    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        _openSwiftUIUnimplementedFailure()
    }

    package func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        _openSwiftUIUnimplementedFailure()
    }

    package func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        _openSwiftUIUnimplementedFailure()
    }

    package var function: Animation.Function {
        _openSwiftUIUnimplementedFailure()
    }

    package func hash(into hasher: inout Hasher) {
        _openSwiftUIUnimplementedFailure()
    }

    package static func == (a: InternalCustomAnimationModifiedContent<Base, Modifier>, b: InternalCustomAnimationModifiedContent<Base, Modifier>) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package var hashValue: Int {
        _openSwiftUIUnimplementedFailure()
    }
}

extension InternalCustomAnimationModifiedContent {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}
