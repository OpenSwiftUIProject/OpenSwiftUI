//
//  DelayAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3EFC07053803547BE79DCD198FF8190A (SwiftUICore)

public import Foundation

@available(OpenSwiftUI_v1_0, *)
extension Animation {
    /// Delays the start of the animation by the specified number of seconds.
    ///
    /// Use this method to delay the start of an animation. For example, the
    /// following code animates the height change of two capsules.
    /// Animation of the first ``Capsule`` begins immediately. However,
    /// animation of the second one doesn't begin until a half second later.
    ///
    ///     struct ContentView: View {
    ///         @State private var adjustBy = 100.0
    ///
    ///         var body: some View {
    ///             VStack(spacing: 40) {
    ///                 HStack(alignment: .bottom) {
    ///                     Capsule()
    ///                         .frame(width: 50, height: 175 - adjustBy)
    ///                         .animation(.easeInOut, value: adjustBy)
    ///                     Capsule()
    ///                         .frame(width: 50, height: 175 + adjustBy)
    ///                         .animation(.easeInOut.delay(0.5), value: adjustBy)
    ///                 }
    ///
    ///                 Button("Animate") {
    ///                     adjustBy *= -1
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-15-delay.mp4", poster: "animation-15-delay.png", alt: "A video that shows two capsules side by side that animate using the ease-in ease-out animation. The capsule on the left is short, while the capsule on the right is tall. As they animate, the short capsule grows upwards to match the height of the tall capsule. Then the tall capsule shrinks to match the original height of the short capsule. Then the capsule on the left shrinks to its original height, followed by the capsule on the right growing to its original height.")
    ///
    /// - Parameter delay: The number of seconds to delay the start of the
    /// animation.
    /// - Returns: An animation with a delayed start.
    public func delay(_ delay: TimeInterval) -> Animation {
        modifier(DelayAnimation(delay: delay))
    }
}

struct DelayAnimation: CustomAnimationModifier {
    var delay: TimeInterval

    @inline(__always)
    private func delayedTime(_ time: TimeInterval) -> TimeInterval {
        max(0, time - delay)
    }

    func animate<V, B>(
        base: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic, B: CustomAnimation {
        base.animate(
            value: value,
            time: delayedTime(time),
            context: &context
        )
    }

    func shouldMerge<V, B>(base: B, previous: DelayAnimation, previousBase: B, value: V, time: TimeInterval, context: inout AnimationContext<V>) -> Bool where V : VectorArithmetic, B : CustomAnimation {
        self == previous && base.shouldMerge(
            previous: Animation(previousBase),
            value: value,
            time: delayedTime(time),
            context: &context
        )
    }

    func function(base: Animation.Function) -> Animation.Function {
        base
    }
}
