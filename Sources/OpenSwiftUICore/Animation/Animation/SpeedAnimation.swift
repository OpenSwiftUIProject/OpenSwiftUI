//
//  SpeedAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation

// MARK: - View + speed Animation

@available(OpenSwiftUI_v1_0, *)
extension Animation {
    /// Changes the duration of an animation by adjusting its speed.
    ///
    /// Setting the speed of an animation changes the duration of the animation
    /// by a factor of `speed`. A higher speed value causes a faster animation
    /// sequence due to a shorter duration. For example, a one-second animation
    /// with a speed of `2.0` completes in half the time (half a second).
    ///
    ///     struct ContentView: View {
    ///         @State private var adjustBy = 100.0
    ///
    ///         private var oneSecondAnimation: Animation {
    ///            .easeInOut(duration: 1.0)
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing: 40) {
    ///                 HStack(alignment: .bottom) {
    ///                     Capsule()
    ///                         .frame(width: 50, height: 175 - adjustBy)
    ///                     Capsule()
    ///                         .frame(width: 50, height: 175 + adjustBy)
    ///                 }
    ///                 .animation(oneSecondAnimation.speed(2.0), value: adjustBy)
    ///
    ///                 Button("Animate") {
    ///                     adjustBy *= -1
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-18-speed.mp4", poster: "animation-18-speed.png", alt: "A video that shows two capsules side by side that animate using the ease-in ease-out animation. The capsule on the left is short, while the capsule on the right is tall. They animate for half a second with the short capsule growing upwards to match the height of the tall capsule. Then the tall capsule shrinks to match the original height of the short capsule. For another half second, the capsule on the left shrinks to its original height, followed by the capsule on the right growing to its original height.")
    ///
    /// Setting `speed` to a lower number slows the animation, extending its
    /// duration. For example, a one-second animation with a speed of `0.25`
    /// takes four seconds to complete.
    ///
    ///     struct ContentView: View {
    ///         @State private var adjustBy = 100.0
    ///
    ///         private var oneSecondAnimation: Animation {
    ///            .easeInOut(duration: 1.0)
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing: 40) {
    ///                 HStack(alignment: .bottom) {
    ///                     Capsule()
    ///                         .frame(width: 50, height: 175 - adjustBy)
    ///                     Capsule()
    ///                         .frame(width: 50, height: 175 + adjustBy)
    ///                 }
    ///                 .animation(oneSecondAnimation.speed(0.25), value: adjustBy)
    ///
    ///                 Button("Animate") {
    ///                     adjustBy *= -1
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-19-speed-slow.mp4", poster: "animation-19-speed-slow.png", alt: "A video that shows two capsules side by side that animate using the ease-in ease-out animation. The capsule on the left is short, while the right-side capsule is tall. They animate for four seconds with the short capsule growing upwards to match the height of the tall capsule. Then the tall capsule shrinks to match the original height of the short capsule. For another four seconds, the capsule on the left shrinks to its original height, followed by the capsule on the right growing to its original height.")
    ///
    /// - Parameter speed: The speed at which OpenSwiftUI performs the animation.
    /// - Returns: An animation with the adjusted speed.
    public func speed(_ speed: Double) -> Animation {
        modifier(SpeedAnimation(speed: speed))
    }
}

// MARK: - SpeedAnimation

struct SpeedAnimation: CustomAnimationModifier {
    var speed: Double

    @inline(__always)
    private func speededTime(_ time: TimeInterval) -> TimeInterval {
        time * speed
    }

    func animate<V, B>(
        base: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic, B: CustomAnimation {
        base.animate(
            value: value,
            time: speededTime(time),
            context: &context
        )
    }

    func shouldMerge<V, B>(
        base: B,
        previous: SpeedAnimation,
        previousBase: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic, B: CustomAnimation {
        self == previous && base.shouldMerge(
            previous: Animation(previousBase),
            value: value,
            time: speededTime(time),
            context: &context
        )
    }

    func function(base: Animation.Function) -> Animation.Function {
        .speed(speed, base)
    }
}
