//
//  LogicalCompletionAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3EFC07053803547BE79DCD198FF8190A (SwiftUICore)

public import Foundation

@available(OpenSwiftUI_v5_0, *)
extension Animation {
    /// Causes the animation to report logical completion after the specified
    /// duration, if it has not already logically completed.
    ///
    /// Note that the indicated duration will not cause the animation to
    /// continue running after the base animation has fully completed.
    ///
    /// If the animation is removed before the given duration is reached,
    /// logical completion will be reported immediately.
    ///
    /// - Parameters:
    ///   - duration: The duration after which the animation should  report
    ///     that it is logically complete.
    /// - Returns: An animation that reports logical completion after the
    ///   given duration.
    public func logicallyComplete(after duration: TimeInterval) -> Animation {
        modifier(LogicalCompletionModifier(duration: duration))
    }
}

private struct LogicalCompletionModifier: CustomAnimationModifier {
    var duration: Double

    func animate<V, B>(
        base: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic, B: CustomAnimation {
        let currentValue = base.animate(value: value, time: time, context: &context)
        if !context.isLogicallyComplete {
            context.isLogicallyComplete = duration <= time
        }
        return currentValue
    }

    func function(base: Animation.Function) -> Animation.Function {
        base
    }
}
