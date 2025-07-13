//
//  CustomAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complte

public import Foundation

/// A type that defines how an animatable value changes over time.
///
/// Use this protocol to create a type that changes an animatable value over
/// time, which produces a custom visual transition of a view. For example, the
/// follow code changes an animatable value using an elastic ease-in ease-out
/// function:
///
///     struct ElasticEaseInEaseOutAnimation: CustomAnimation {
///         let duration: TimeInterval
///
///         func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
///             if time > duration { return nil } // The animation has finished.
///
///             let p = time / duration
///             let s = sin((20 * p - 11.125) * ((2 * Double.pi) / 4.5))
///             if p < 0.5 {
///                 return value.scaled(by: -(pow(2, 20 * p - 10) * s) / 2)
///             } else {
///                 return value.scaled(by: (pow(2, -20 * p + 10) * s) / 2 + 1)
///             }
///         }
///     }
///
/// > Note: To maintain state during the life span of a custom animation, use
/// the ``AnimationContext/state`` property available on the `context`
/// parameter value. You can also use context's
/// ``AnimationContext/environment`` property to retrieve environment values
/// from the view that created the custom animation. For more information, see
/// ``AnimationContext``.
///
/// To create an ``Animation`` instance of a custom animation, use the
/// ``Animation/init(_:)`` initializer, passing in an instance of a custom
/// animation; for example:
///
///     Animation(ElasticEaseInEaseOutAnimation(duration: 5.0))
///
/// To help make view code more readable, extend ``Animation`` and add a static
/// property and function that returns an `Animation` instance of a custom
/// animation. For example, the following code adds the static property
/// `elasticEaseInEaseOut` that returns the elastic ease-in ease-out animation
/// with a default duration of `0.35` seconds. Next, the code adds a method
/// that returns the animation with a specified duration.
///
///     extension Animation {
///         static var elasticEaseInEaseOut: Animation { elasticEaseInEaseOut(duration: 0.35) }
///         static func elasticEaseInEaseOut(duration: TimeInterval) -> Animation {
///             Animation(ElasticEaseInEaseOutAnimation(duration: duration))
///         }
///     }
///
/// To animate a view with the elastic ease-in ease-out animation, a view calls
/// either `.elasticEaseInEaseOut` or `.elasticEaseInEaseOut(duration:)`. For
/// example, the follow code includes an Animate button that, when clicked,
/// animates a circle as it moves from one edge of the view to the other,
/// using the elastic ease-in ease-out animation with a duration of `5`
/// seconds:
///
///     struct ElasticEaseInEaseOutView: View {
///         @State private var isActive = false
///
///         var body: some View {
///             VStack(alignment: isActive ? .trailing : .leading) {
///                 Circle()
///                     .frame(width: 100.0)
///                     .foregroundColor(.accentColor)
///
///                 Button("Animate") {
///                     withAnimation(.elasticEaseInEaseOut(duration: 5.0)) {
///                         isActive.toggle()
///                     }
///                 }
///                 .frame(maxWidth: .infinity)
///             }
///             .padding()
///         }
///     }
///
/// @Video(source: "animation-20-elastic.mp4", poster: "animation-20-elastic.png", alt: "A video that shows a circle that moves from one edge of the view to the other using an elastic ease-in ease-out animation. The circle's initial position is near the leading edge of the view. The circle begins moving slightly towards the leading, then towards trail edges of the view before it moves off the leading edge showing only two-thirds of the circle. The circle then moves quickly to the trailing edge of the view, going slightly beyond the edge so that only two-thirds of the circle is visible. The circle bounces back into full view before settling into position near the trailing edge of the view. The circle repeats this animation in reverse, going from the trailing edge of the view to the leading edge.")
@available(OpenSwiftUI_v5_0, *)
@preconcurrency
public protocol CustomAnimation: Hashable, Sendable {
    /// Calculates the value of the animation at the specified time.
    ///
    /// Implement this method to calculate and return the value of the
    /// animation at a given point in time. If the animation has finished,
    /// return `nil` as the value. This signals to the system that it can
    /// remove the animation.
    ///
    /// If your custom animation needs to maintain state between calls to the
    /// `animate(value:time:context:)` method, store the state data in
    /// `context`. This makes the data available to the method next time
    /// the system calls it. To learn more about managing state data in a
    /// custom animation, see ``AnimationContext``.
    ///
    /// - Parameters:
    ///   - value: The vector to animate towards.
    ///   - time: The elapsed time since the start of the animation.
    ///   - context: An instance of ``AnimationContext`` that provides access
    ///   to state and the animation environment.
    /// - Returns: The current value of the animation, or `nil` if the
    ///   animation has finished.
    nonisolated func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic

    /// Calculates the velocity of the animation at a specified time.
    ///
    /// Implement this method to provide the velocity of the animation at a
    /// given time. Should subsequent animations merge with the animation,
    /// the system preserves continuity of the velocity between animations.
    ///
    /// The default implementation of this method returns `nil`.
    ///
    /// > Note: State and environment data is available to this method via the
    /// `context` parameter, but `context` is read-only. This behavior is
    /// different than with ``animate(value:time:context:)`` and
    /// ``shouldMerge(previous:value:time:context:)`` where `context` is
    /// an `inout` parameter, letting you change the context including state
    /// data of the animation. For more information about managing state data
    /// in a custom animation, see ``AnimationContext``.
    ///
    /// - Parameters:
    ///   - value: The vector to animate towards.
    ///   - time: The amount of time since the start of the animation.
    ///   - context: An instance of ``AnimationContext`` that provides access
    ///   to state and the animation environment.
    /// - Returns: The current velocity of the animation, or `nil` if the
    ///   animation has finished.
    nonisolated func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic

    /// Determines whether an instance of the animation can merge with other
    /// instance of the same type.
    ///
    /// When a view creates a new animation on an animatable value that already
    /// has a running animation of the same animation type, the system calls
    /// the `shouldMerge(previous:value:time:context:)` method on the new
    /// instance to determine whether it can merge the two instance. Implement
    /// this method if the animation can merge with another instance. The
    /// default implementation returns `false`.
    ///
    /// If `shouldMerge(previous:value:time:context:)` returns `true`, the
    /// system merges the new animation instance with the previous animation.
    /// The system provides to the new instance the state and elapsed time from
    /// the previous one. Then it removes the previous animation.
    ///
    /// If this method returns `false`, the system doesn't merge the animation
    /// with the previous one. Instead, both animations run together and the
    /// system combines their results.
    ///
    /// If your custom animation needs to maintain state between calls to the
    /// `shouldMerge(previous:value:time:context:)` method, store the state
    /// data in `context`. This makes the data available to the method next
    /// time the system calls it. To learn more, see ``AnimationContext``.
    ///
    /// - Parameters:
    ///   - previous: The previous running animation.
    ///   - value: The vector to animate towards.
    ///   - time: The amount of time since the start of the previous animation.
    ///   - context: An instance of ``AnimationContext`` that provides access
    ///   to state and the animation environment.
    /// - Returns: A Boolean value of `true` if the animation should merge with
    ///   the previous animation; otherwise, `false`.
    nonisolated func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic
}

package protocol InternalCustomAnimation: CustomAnimation {
    var function: Animation.Function { get }
}

@available(OpenSwiftUI_v5_0, *)
extension CustomAnimation {
    public func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        nil
    }

    public func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        false
    }
}
