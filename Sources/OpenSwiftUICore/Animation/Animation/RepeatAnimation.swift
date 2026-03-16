//
//  RepeatAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 245300C05C5988649DCF97F905A0452C (SwiftUICore)

import Foundation

// MARK: - View + repeat Animation

@available(OpenSwiftUI_v1_0, *)
extension Animation {

    /// Repeats the animation for a specific number of times.
    ///
    /// Use this method to repeat the animation a specific number of times. For
    /// example, in the following code, the animation moves a truck from one
    /// edge of the view to the other edge. It repeats this animation three
    /// times.
    ///
    ///     struct ContentView: View {
    ///         @State private var driveForward = true
    ///
    ///         private var driveAnimation: Animation {
    ///             .easeInOut
    ///             .repeatCount(3, autoreverses: true)
    ///             .speed(0.5)
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(alignment: driveForward ? .leading : .trailing, spacing: 40) {
    ///                 Image(systemName: "box.truck")
    ///                     .font(.system(size: 48))
    ///                     .animation(driveAnimation, value: driveForward)
    ///
    ///                 HStack {
    ///                     Spacer()
    ///                     Button("Animate") {
    ///                         driveForward.toggle()
    ///                     }
    ///                     Spacer()
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-16-repeat-count.mp4", poster: "animation-16-repeat-count.png", alt: "A video that shows a box truck moving from the leading edge of a view to the trailing edge, and back again before looping in the opposite direction.")
    ///
    /// The first time the animation runs, the truck moves from the leading
    /// edge to the trailing edge of the view. The second time the animation
    /// runs, the truck moves from the trailing edge to the leading edge
    /// because `autoreverse` is `true`. If `autoreverse` were `false`, the
    /// truck would jump back to leading edge before moving to the trailing
    /// edge. The third time the animation runs, the truck moves from the
    /// leading to the trailing edge of the view.
    ///
    /// - Parameters:
    ///   - repeatCount: The number of times that the animation repeats. Each
    ///   repeated sequence starts at the beginning when `autoreverse` is
    ///  `false`.
    ///   - autoreverses: A Boolean value that indicates whether the animation
    ///   sequence plays in reverse after playing forward. Autoreverse counts
    ///   towards the `repeatCount`. For instance, a `repeatCount` of one plays
    ///   the animation forward once, but it doesn’t play in reverse even if
    ///   `autoreverse` is `true`. When `autoreverse` is `true` and
    ///   `repeatCount` is `2`, the animation moves forward, then reverses, then
    ///   stops.
    /// - Returns: An animation that repeats for specific number of times.
    public func repeatCount(_ repeatCount: Int, autoreverses: Bool = true) -> Animation {
        modifier(RepeatAnimation(repeatCount: repeatCount, autoreverses: autoreverses))
    }

    /// Repeats the animation for the lifespan of the view containing the
    /// animation.
    ///
    /// Use this method to repeat the animation until the instance of the view
    /// no longer exists, or the view’s explicit or structural identity
    /// changes. For example, the following code continuously rotates a
    /// gear symbol for the lifespan of the view.
    ///
    ///     struct ContentView: View {
    ///         @State private var rotationDegrees = 0.0
    ///
    ///         private var animation: Animation {
    ///             .linear
    ///             .speed(0.1)
    ///             .repeatForever(autoreverses: false)
    ///         }
    ///
    ///         var body: some View {
    ///             Image(systemName: "gear")
    ///                 .font(.system(size: 86))
    ///                 .rotationEffect(.degrees(rotationDegrees))
    ///                 .onAppear {
    ///                     withAnimation(animation) {
    ///                         rotationDegrees = 360.0
    ///                     }
    ///                 }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-17-repeat-forever.mp4", poster: "animation-17-repeat-forever.png", alt: "A video that shows a gear that continuously rotates clockwise.")
    ///
    /// - Parameter autoreverses: A Boolean value that indicates whether the
    /// animation sequence plays in reverse after playing forward.
    /// - Returns: An animation that continuously repeats.
    public func repeatForever(autoreverses: Bool = true) -> Animation {
        modifier(RepeatAnimation(repeatCount: nil, autoreverses: autoreverses))
    }
}

// MARK: - RepeatAnimation

struct RepeatAnimation: CustomAnimationModifier {
    var repeatCount: Int?

    var autoreverses: Bool

    func animate<V, B>(
        base: B,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic, B: CustomAnimation {
        let repeatState = context.repeatState
        let elapsed = time - repeatState.timeOffset
        let isReversed = (repeatState.index % 2 == 1) && autoreverses
        guard let newValue = base.animate(value: value, time: elapsed, context: &context) else {
            context.state = .init()
            let index = repeatState.index + 1
            context.repeatState = .init(index: index, timeOffset: time)
            if let repeatCount, index >= repeatCount {
                return nil
            }
            return isReversed ? .zero : value
        }
        return isReversed ? value - newValue : newValue
    }

    func function(base: Animation.Function) -> Animation.Function {
        .repeat(
            count: repeatCount.map { Double($0) } ?? .infinity,
            autoreverses: autoreverses,
            base
        )
    }
}

// MARK: - RepeatState

struct RepeatState<Value>: AnimationStateKey where Value: VectorArithmetic {
    static var defaultValue: RepeatState {
        RepeatState(index: 0, timeOffset: 0)
    }

    var index: Int

    var timeOffset: Double
}

extension AnimationContext {
    fileprivate var repeatState: RepeatState<Value> {
        get { state[RepeatState.self] }
        set { state[RepeatState.self] = newValue }
    }
}
