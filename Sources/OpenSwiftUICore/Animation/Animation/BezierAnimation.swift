//
//  BezierAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

@available(OpenSwiftUI_v1_0, *)
extension Animation {
    /// An animation with a specified duration that combines the behaviors of
    /// in and out easing animations.
    ///
    /// An easing animation provides motion with a natural feel by varying
    /// the acceleration and deceleration of the animation, which matches
    /// how things tend to move in reality. An ease in and out animation
    /// starts slowly, increasing its speed towards the halfway point, and
    /// finally decreasing the speed towards the end of the animation.
    ///
    /// Use `easeInOut(duration:)` when you want to specify the time it takes
    /// for the animation to complete. Otherwise, use ``easeInOut`` to perform
    /// the animation for a default length of time.
    ///
    /// The following code shows an example of animating the size changes of
    /// a ``Circle`` using an ease in and out animation with a duration of
    /// one second.
    ///
    ///     struct ContentView: View {
    ///         @State private var scale = 0.5
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Circle()
    ///                     .scale(scale)
    ///                     .animation(.easeInOut(duration: 1.0), value: scale)
    ///                 HStack {
    ///                     Button("+") { scale += 0.1 }
    ///                     Button("-") { scale -= 0.1 }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-13-easeineaseout-duration.mp4", poster: "animation-13-easeineaseout-duration.png", alt: "A video that shows a circle enlarging for one second, then shrinking for another second to its original size using an ease-in ease-out animation.")
    ///
    /// - Parameter duration: The length of time, expressed in seconds, that
    /// the animation takes to complete.
    ///
    /// - Returns: An ease-in ease-out animation with a specified duration.
    public static func easeInOut(duration: TimeInterval) -> Animation {
        Animation(BezierAnimation(
            curve: .init(
                startControlPoint: .init(x: 0.42, y: 0),
                endControlPoint: .init(x: 0.58, y: 1)
            ),
            duration: duration
        ))

    }

    /// An animation that combines the behaviors of in and out easing
    /// animations.
    ///
    /// An easing animation provides motion with a natural feel by varying
    /// the acceleration and deceleration of the animation, which matches
    /// how things tend to move in reality. An ease in and out animation
    /// starts slowly, increasing its speed towards the halfway point, and
    /// finally decreasing the speed towards the end of the animation.
    ///
    /// The `easeInOut` animation has a default duration of 0.35 seconds. To
    /// specify the duration, use the ``easeInOut(duration:)`` method.
    ///
    /// The following code shows an example of animating the size changes of a
    /// ``Circle`` using an ease in and out animation.
    ///
    ///     struct ContentView: View {
    ///         @State private var scale = 0.5
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Circle()
    ///                     .scale(scale)
    ///                     .animation(.easeInOut, value: scale)
    ///                 HStack {
    ///                     Button("+") { scale += 0.1 }
    ///                     Button("-") { scale -= 0.1 }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-12-easeineaseout.mp4", poster: "animation-12-easeineaseout.png", alt: "A video that shows a circle enlarging, then shrinking to its original size using an ease-in ease-out animation.")
    ///
    /// - Returns: An ease-in ease-out animation with the default duration.
    public static var easeInOut: Animation {
        easeInOut(duration: 0.35)
    }

    /// An animation with a specified duration that starts slowly and then
    /// increases speed towards the end of the movement.
    ///
    /// An easing animation provides motion with a natural feel by varying
    /// the acceleration and deceleration of the animation, which matches
    /// how things tend to move in reality. With an ease in animation, the
    /// motion starts slowly and increases its speed towards the end.
    ///
    /// Use `easeIn(duration:)` when you want to specify the time it takes
    /// for the animation to complete. Otherwise, use ``easeIn`` to perform the
    /// animation for a default length of time.
    ///
    /// The following code shows an example of animating the size changes of
    /// a ``Circle`` using an ease in animation with a duration of one
    /// second.
    ///
    ///     struct ContentView: View {
    ///         @State private var scale = 0.5
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Circle()
    ///                     .scale(scale)
    ///                     .animation(.easeIn(duration: 1.0), value: scale)
    ///                 HStack {
    ///                     Button("+") { scale += 0.1 }
    ///                     Button("-") { scale -= 0.1 }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-09-easein-duration.mp4", poster: "animation-09-easein-duration.png", alt: "A video that shows a circle enlarging for one second, then shrinking for another second to its original size using an ease-in animation.")
    ///
    /// - Parameter duration: The length of time, expressed in seconds, that
    /// the animation takes to complete.
    ///
    /// - Returns: An ease-in animation with a specified duration.
    public static func easeIn(duration: TimeInterval) -> Animation {
        Animation(BezierAnimation(
            curve: .init(
                startControlPoint: .init(x: 0.42, y: 0),
                endControlPoint: .init(x: 1, y: 1)
            ),
            duration: duration
        ))
    }

    /// An animation that starts slowly and then increases speed towards the
    /// end of the movement.
    ///
    /// An easing animation provides motion with a natural feel by varying
    /// the acceleration and deceleration of the animation, which matches
    /// how things tend to move in reality. With an ease in animation, the
    /// motion starts slowly and increases its speed towards the end.
    ///
    /// The `easeIn` animation has a default duration of 0.35 seconds. To
    /// specify a different duration, use ``easeIn(duration:)``.
    ///
    /// The following code shows an example of animating the size changes of
    /// a ``Circle`` using the ease in animation.
    ///
    ///     struct ContentView: View {
    ///         @State private var scale = 0.5
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Circle()
    ///                     .scale(scale)
    ///                     .animation(.easeIn, value: scale)
    ///                 HStack {
    ///                     Button("+") { scale += 0.1 }
    ///                     Button("-") { scale -= 0.1 }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-08-easein.mp4", poster: "animation-08-easein.png", alt: "A video that shows a circle enlarging, then shrinking to its original size using an ease-in animation.")
    ///
    /// - Returns: An ease-in animation with the default duration.
    public static var easeIn: Animation {
        easeIn(duration: 0.35)
    }

    /// An animation with a specified duration that starts quickly and then
    /// slows towards the end of the movement.
    ///
    /// An easing animation provides motion with a natural feel by varying
    /// the acceleration and deceleration of the animation, which matches
    /// how things tend to move in reality. With an ease out animation, the
    /// motion starts quickly and decreases its speed towards the end.
    ///
    /// Use `easeOut(duration:)` when you want to specify the time it takes
    /// for the animation to complete. Otherwise, use ``easeOut`` to perform
    /// the animation for a default length of time.
    ///
    /// The following code shows an example of animating the size changes of
    /// a ``Circle`` using an ease out animation with a duration of one
    /// second.
    ///
    ///     struct ContentView: View {
    ///         @State private var scale = 0.5
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Circle()
    ///                     .scale(scale)
    ///                     .animation(.easeOut(duration: 1.0), value: scale)
    ///                 HStack {
    ///                     Button("+") { scale += 0.1 }
    ///                     Button("-") { scale -= 0.1 }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-09-easein-duration.mp4", poster: "animation-09-easein-duration.png", alt: "A video that shows a circle enlarging for one second, then shrinking for another second to its original size using an ease-in animation.")
    ///
    /// - Parameter duration: The length of time, expressed in seconds, that
    /// the animation takes to complete.
    ///
    /// - Returns: An ease-out animation with a specified duration.
    public static func easeOut(duration: TimeInterval) -> Animation {
        Animation(BezierAnimation(
            curve: .init(
                startControlPoint: .init(x: 0, y: 0),
                endControlPoint: .init(x: 0.58, y: 1)
            ),
            duration: duration
        ))
    }

    /// An animation that starts quickly and then slows towards the end of the
    /// movement.
    ///
    /// An easing animation provides motion with a natural feel by varying
    /// the acceleration and deceleration of the animation, which matches
    /// how things tend to move in reality. With an ease out animation, the
    /// motion starts quickly and decreases its speed towards the end.
    ///
    /// The `easeOut` animation has a default duration of 0.35 seconds. To
    /// specify a different duration, use ``easeOut(duration:)``.
    ///
    /// The following code shows an example of animating the size changes of
    /// a ``Circle`` using an ease out animation.
    ///
    ///     struct ContentView: View {
    ///         @State private var scale = 0.5
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Circle()
    ///                     .scale(scale)
    ///                     .animation(.easeOut, value: scale)
    ///                 HStack {
    ///                     Button("+") { scale += 0.1 }
    ///                     Button("-") { scale -= 0.1 }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-10-easeout.mp4", poster: "animation-10-easeout.png", alt: "A video that shows a circle enlarging, then shrinking to its original size using an ease-out animation.")
    ///
    /// - Returns: An ease-out animation with the default duration.
    public static var easeOut: Animation {
        easeOut(duration: 0.35)
    }

    /// An animation that moves at a constant speed during a specified
    /// duration.
    ///
    /// A linear animation provides a mechanical feel to the motion because its
    /// speed is consistent from start to finish of the animation. This
    /// constant speed makes a linear animation ideal for animating the
    /// movement of objects where changes in the speed might feel awkward, such
    /// as with an activity indicator.
    ///
    /// Use `linear(duration:)` when you want to specify the time it takes
    /// for the animation to complete. Otherwise, use ``linear`` to perform the
    /// animation for a default length of time.
    ///
    /// The following code shows an example of using linear animation with a
    /// duration of two seconds to animate the movement of a circle as it moves
    /// between the leading and trailing edges of the view. The color of the
    /// circle also animates from red to blue as it moves across the view.
    ///
    ///     struct ContentView: View {
    ///         @State private var isActive = false
    ///
    ///         var body: some View {
    ///             VStack(alignment: isActive ? .trailing : .leading) {
    ///                 Circle()
    ///                     .fill(isActive ? Color.red : Color.blue)
    ///                     .frame(width: 50, height: 50)
    ///
    ///                 Button("Animate") {
    ///                     withAnimation(.linear(duration: 2.0)) {
    ///                         isActive.toggle()
    ///                     }
    ///                 }
    ///                 .frame(maxWidth: .infinity)
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-07-linear-duration.mp4", poster: "animation-07-linear-duration.png", alt: "A video that shows a circle moving from the leading edge of the view to the trailing edge. The color of the circle also changes from red to blue as it moves across the view. Then the circle moves from the trailing edge back to the leading edge while also changing colors from blue to red.")
    ///
    /// - Parameter duration: The length of time, expressed in seconds, that
    /// the animation takes to complete.
    ///
    /// - Returns: A linear animation with a specified duration.
    public static func linear(duration: TimeInterval) -> Animation {
        Animation(BezierAnimation(
            curve: .init(
                startControlPoint: .init(x: 0, y: 0),
                endControlPoint: .init(x: 1, y: 1)
            ),
            duration: duration
        ))
    }

    /// An animation that moves at a constant speed.
    ///
    /// A linear animation provides a mechanical feel to the motion because its
    /// speed is consistent from start to finish of the animation. This
    /// constant speed makes a linear animation ideal for animating the
    /// movement of objects where changes in the speed might feel awkward, such
    /// as with an activity indicator.
    ///
    /// The following code shows an example of using linear animation to
    /// animate the movement of a circle as it moves between the leading and
    /// trailing edges of the view. The circle also animates its color change
    /// as it moves across the view.
    ///
    ///     struct ContentView: View {
    ///         @State private var isActive = false
    ///
    ///         var body: some View {
    ///             VStack(alignment: isActive ? .trailing : .leading) {
    ///                 Circle()
    ///                     .fill(isActive ? Color.red : Color.blue)
    ///                     .frame(width: 50, height: 50)
    ///
    ///                 Button("Animate") {
    ///                     withAnimation(.linear) {
    ///                         isActive.toggle()
    ///                     }
    ///                 }
    ///                 .frame(maxWidth: .infinity)
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-06-linear.mp4", poster: "animation-06-linear.png", alt: "A video that shows a circle moving from the leading edge of the view to the trailing edge. The color of the circle also changes from red to blue as it moves across the view. Then the circle moves from the trailing edge back to the leading edge while also changing colors from blue to red.")
    ///
    /// The `linear` animation has a default duration of 0.35 seconds. To
    /// specify a different duration, use ``linear(duration:)``.
    ///
    /// - Returns: A linear animation with the default duration.

    public static var linear: Animation {
        linear(duration: 0.35)
    }

    package static func coreAnimationDefault(duration: TimeInterval) -> Animation {
        Animation(BezierAnimation(
            curve: .init(
                startControlPoint: .init(x: 0.25, y: 0.1),
                endControlPoint: .init(x: 0.25, y: 1.0)
            ),
            duration: duration
        ))
    }

    /// An animation created from a cubic Bézier timing curve.
    ///
    /// Use this method to create a timing curve based on the control points of
    /// a cubic Bézier curve. A cubic Bézier timing curve consists of a line
    /// whose starting point is `(0, 0)` and whose end point is `(1, 1)`. Two
    /// additional control points, `(p1x, p1y)` and `(p2x, p2y)`, define the
    /// shape of the curve.
    ///
    /// The slope of the line defines the speed of the animation at that point
    /// in time. A steep slopes causes the animation to appear to run faster,
    /// while a shallower slope appears to run slower. The following
    /// illustration shows a timing curve where the animation starts and
    /// finishes fast, but appears slower through the middle section of the
    /// animation.
    ///
    /// ![An illustration of an XY graph that shows the path of a Bézier timing curve that an animation frame follows over time. The horizontal x-axis has a label with the text Time, and a label with the text Frame appears along the vertical y-axis. The path begins at the graph's origin, labeled as (0.0, 0.0). The path moves upwards, forming a concave down shape. At the point of inflection, the path continues upwards, forming a concave up shape. A label with the text First control point (p1x, p1y) appears above the path. Extending from the label is a dotted line pointing to the position (0.1, 0.75) on the graph. Another label with the text Second control point (p2x, p2y) appears below the path. A dotted line extends from the label to the (0.85, 0.35) position on the graph.](Animation-timingCurve-1)
    ///
    /// The following code uses the timing curve from the previous
    /// illustration to animate a ``Circle`` as its size changes.
    ///
    ///     struct ContentView: View {
    ///         @State private var scale = 1.0
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Circle()
    ///                     .scaleEffect(scale)
    ///                     .animation(
    ///                         .timingCurve(0.1, 0.75, 0.85, 0.35, duration: 2.0),
    ///                         value: scale)
    ///
    ///                 Button("Animate") {
    ///                     if scale == 1.0 {
    ///                         scale = 0.25
    ///                     } else {
    ///                         scale = 1.0
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// @Video(source: "animation-14-timing-curve.mp4", poster: "animation-14-timing-curve.png", alt: "A video that shows a circle shrinking then growing to its original size using a timing curve animation. The first control point of the time curve is (0.1, 0.75) and the second is (0.85, 0.35).")
    ///
    /// - Parameters:
    ///   - p1x: The x-coordinate of the first control point of the cubic
    ///     Bézier curve.
    ///   - p1y: The y-coordinate of the first control point of the cubic
    ///     Bézier curve.
    ///   - p2x: The x-coordinate of the second control point of the cubic
    ///     Bézier curve.
    ///   - p2y: The y-coordinate of the second control point of the cubic
    ///     Bézier curve.
    ///   - duration: The length of time, expressed in seconds, the animation
    ///     takes to complete.
    /// - Returns: A cubic Bézier timing curve animation.
    public static func timingCurve(
        _ p1x: Double,
        _ p1y: Double,
        _ p2x: Double,
        _ p2y: Double,
        duration: TimeInterval = 0.35
    ) -> Animation {
        Animation(BezierAnimation(
            curve: .init(
                startControlPoint: .init(x: p1x, y: p1y),
                endControlPoint: .init(x: p2x, y: p2y)
            ),
            duration: duration
        ))
    }
}

// MARK: - BezierAnimation

package struct BezierAnimation: InternalCustomAnimation {
    package var duration: TimeInterval
    package var curve: UnitCurve.CubicSolver

    package init(curve: UnitCurve.CubicSolver, duration: TimeInterval) {
        self.duration = duration
        self.curve = curve
    }

    package init(
        _ c0x: Double,
        _ c0y: Double,
        _ c1x: Double,
        _ c1y: Double,
        duration: TimeInterval
    ) {
        self.duration = duration
        self.curve = UnitCurve.CubicSolver(
            startControlPoint: UnitPoint(x: c0x, y: c0y),
            endControlPoint: UnitPoint(x: c1x, y: c1y)
        )
    }

    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        fraction(for: time).map { fraction in
            var result = value
            result.scale(by: fraction)
            return result
        }
    }

    package func fraction(for elapsed: TimeInterval) -> Double? {
        guard duration > 0, duration >= elapsed else {
            return nil
        }
        return curve.value(at: (elapsed / duration).clamp(min: 0.0, max: 1.0))
    }

    package var function: Animation.Function {
        .bezier(
            duration: duration,
            cp1: CGPoint(x: curve.startControlPoint.x, y: curve.startControlPoint.y),
            cp2: CGPoint(x: curve.endControlPoint.x, y: curve.endControlPoint.y)
        )
    }
}

// MARK: - BezierTimingFunction

package struct BezierTimingFunction<T>: Equatable where T: BinaryFloatingPoint {
    package var p1x: T, p1y: T, p2x: T, p2y: T

    package init<U>(p1: (U, U), p2: (U, U)) where U: BinaryFloatingPoint {
        self.p1x = T(p1.0)
        self.p1y = T(p1.1)
        self.p2x = T(p2.0)
        self.p2y = T(p2.1)
    }

    package static var linear: BezierTimingFunction<T> {
        BezierTimingFunction(p1: (T(0), T(0)), p2: (T(1), T(1)))
    }

    package var p1: (T, T) {
        get { (p1x, p1y) }
        set { 
            p1x = newValue.0
            p1y = newValue.1
        }
    }

    package var p2: (T, T) {
        get { (p2x, p2y) }
        set { 
            p2x = newValue.0
            p2y = newValue.1
        }
    }
}

// MARK: - BezierAnimation + ProtobufMessage

extension BezierAnimation: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.doubleField(1, duration)
        if curve != .init(
            startControlPoint: UnitPoint(x: 0.0, y: 0.0),
            endControlPoint: UnitPoint(x: 1.0, y: 1.0)
        ) {
            encoder.packedField(2) { encoder in
                curve.encode(to: &encoder)
            }
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var duration: TimeInterval = .zero
        var curve = UnitCurve.CubicSolver(
            startControlPoint: .init(x: 0.0, y: 0.0),
            endControlPoint: .init(x: 1.0, y: 1.0)
        )
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: duration = try decoder.doubleField(field)
            case 2: curve = try decoder.messageField(field) { decoder in
                try UnitCurve.CubicSolver.init(from: &decoder)
            }
            default: try decoder.skipField(field)
            }
        }
        self.init(
            curve: curve,
            duration: duration
        )
    }
}
