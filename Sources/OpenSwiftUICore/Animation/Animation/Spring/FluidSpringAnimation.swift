//
//  FluidSpringAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 73E5E3E568519775ECB92F029EBA0DDA (SwiftUICore)

public import Foundation

package struct FluidSpringAnimation: InternalCustomAnimation {
    package var response: Double
    package var dampingFraction: Double
    package var blendDuration: TimeInterval

    package init(
        response: Double,
        dampingFraction: Double,
        blendDuration: TimeInterval
    ) {
        self.response = response
        self.dampingFraction = dampingFraction
        self.blendDuration = blendDuration
    }

    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        var springState = context.springState
        let r: TimeInterval
        if blendDuration > 0, springState.blendInterval != 0 {
            let progress = (time - springState.blendStart) / blendDuration
                .clamp(min: 0.0, max: 1.0)
            let blendValue = springState.blendInterval * (1.0 - progress * progress * (3.0 - progress * 2.0))
            r = response + blendValue
        } else {
            r = .zero
        }
        let stiffness = min(r > 0 ? pow(.tau / r, 2) : 1.0, 45000.0)
        if time - springState.startTime >= r {
            context.isLogicallyComplete = true
        }
        if time - springState.time > 1.0 {
            springState.time = time - 1 / 60
        }
        
        var t = springState.time
        while t < time {
            let damping = -springDamping(
                fraction: dampingFraction,
                stiffness: stiffness
            )
            var force = springState.force
            force.scale(by: 1 / 600)
            force += springState.velocity
            springState.offset += force.scaled(by: 1 / 300)

            let dampedForce = force.scaled(by: damping)
            var displacement = value
            displacement -= springState.offset
            displacement.scale(by: stiffness)
            springState.force = dampedForce
            springState.force += displacement

            springState.velocity = springState.force
            springState.velocity.scale(by: 1 / 600)
            springState.velocity += force
            t += 1 / 300
        }
        springState.time = t

        guard max(
            springState.velocity.magnitudeSquared,
            springState.force.magnitudeSquared
        ) <= 0.0036 else {
            return springState.offset
        }
        let tolerance = value.scaled(by: 0.01)
        let remainingDistance = value - springState.offset
        guard tolerance.magnitudeSquared > 0, tolerance.magnitudeSquared < remainingDistance.magnitudeSquared else {
            return nil
        }
        return springState.offset
    }

    package func velocity<V>(
        value: V,
        time: Double,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        context.springState.velocity
    }

    package func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        var springState = context.springState
        springState.velocity = previous.velocity(
            value: value,
            time: time,
            context: context
        ) ?? springState.velocity
        springState.offset = previous.animate(
            value: value,
            time: time,
            context: &context
        ) ?? springState.offset
        springState.time = time
        springState.startTime = time
        if let previous = previous.as(FluidSpringAnimation.self),
           response != previous.response {
            springState.blendInterval = previous.response - response
            springState.blendStart = time
        }
        context.springState = springState
        return true
    }

    package var function: Animation.Function {
        let stiffness = springStiffness(response: response)
        let damping = springDamping(fraction: dampingFraction, stiffness: stiffness)
        let animation = SpringAnimation(
            mass: 1.0,
            stiffness: stiffness,
            damping: damping
        )
        return animation.function
    }
}

private struct SpringState<V>: AnimationStateKey where V: VectorArithmetic {
    var offset: V = .zero
    var velocity: V = .zero
    var force: V = .zero
    var time: Double = .zero
    var startTime: Double = .zero
    var blendStart: Double = .zero
    var blendInterval: Double = .zero

    static var defaultValue: SpringState {
        .init()
    }

    init() {}
}

extension AnimationContext {
    fileprivate var springState: SpringState<Value> {
        get { state[SpringState<Value>.self] }
        set { state[SpringState<Value>.self] = newValue }
    }
}

@_alwaysEmitIntoClient
func springStiffness(response: Double) -> Double {
    if response <= 0 {
        return .infinity
    } else {
        let freq = (2.0 * Double.pi) / response
        return freq * freq
    }
}

@_alwaysEmitIntoClient
func springDamping(fraction: Double, stiffness: Double) -> Double {
    let criticalDamping = 2 * stiffness.squareRoot()
    return criticalDamping * fraction
}

@_alwaysEmitIntoClient
func springDampingFraction(bounce: Double) -> Double {
    (bounce < 0.0) ? 1.0 / (bounce + 1.0) : 1.0 - bounce
}

@available(OpenSwiftUI_v1_0, *)
extension Animation {
    /// A persistent spring animation. When mixed with other `spring()`
    /// or `interactiveSpring()` animations on the same property, each
    /// animation will be replaced by their successor, preserving
    /// velocity from one animation to the next. Optionally blends the
    /// duration values between springs over a time period.
    ///
    /// - Parameters:
    ///   - duration: The perceptual duration, which defines the pace of the
    ///     spring. This is approximately equal to the settling duration, but
    ///     for very bouncy springs, will be the duration of the period of
    ///     oscillation for the spring.
    ///   - bounce: How bouncy the spring should be. A value of 0 indicates
    ///     no bounces (a critically damped spring), positive values indicate
    ///     increasing amounts of bounciness up to a maximum of 1.0
    ///     (corresponding to undamped oscillation), and negative values
    ///     indicate overdamped springs with a minimum value of -1.0.
    ///   - blendDuration: The duration in seconds over which to
    ///     interpolate changes to the duration.
    /// - Returns: a spring animation.
    @_alwaysEmitIntoClient
    public static func spring(
        duration: TimeInterval = 0.5,
        bounce: Double = 0.0,
        blendDuration: Double = 0
    ) -> Animation {
        spring(
            response: duration,
            dampingFraction: springDampingFraction(bounce: bounce),
            blendDuration: blendDuration)
    }

    /// A persistent spring animation. When mixed with other `spring()`
    /// or `interactiveSpring()` animations on the same property, each
    /// animation will be replaced by their successor, preserving
    /// velocity from one animation to the next. Optionally blends the
    /// response values between springs over a time period.
    ///
    /// - Parameters:
    ///   - response: The stiffness of the spring, defined as an
    ///     approximate duration in seconds. A value of zero requests
    ///     an infinitely-stiff spring, suitable for driving
    ///     interactive animations.
    ///   - dampingFraction: The amount of drag applied to the value
    ///     being animated, as a fraction of an estimate of amount
    ///     needed to produce critical damping.
    ///   - blendDuration: The duration in seconds over which to
    ///     interpolate changes to the response value of the spring.
    /// - Returns: a spring animation.
    @_disfavoredOverload
    public static func spring(
        response: Double = 0.5,
        dampingFraction: Double = 0.825,
        blendDuration: TimeInterval = 0
    ) -> Animation {
        Animation(
            FluidSpringAnimation(
                response: response,
                dampingFraction: dampingFraction,
                blendDuration: blendDuration
            )
        )
    }

    /// A persistent spring animation. When mixed with other `spring()`
    /// or `interactiveSpring()` animations on the same property, each
    /// animation will be replaced by their successor, preserving
    /// velocity from one animation to the next. Optionally blends the
    /// response values between springs over a time period.
    ///
    /// This uses the default parameter values.
    @_alwaysEmitIntoClient
    public static var spring: Animation {
        spring()
    }

    /// A convenience for a `spring` animation with a lower
    /// `response` value, intended for driving interactive animations.
    @_disfavoredOverload
    public static func interactiveSpring(
        response: Double = 0.15,
        dampingFraction: Double = 0.86,
        blendDuration: TimeInterval = 0.25
    ) -> Animation {
        Animation(
            FluidSpringAnimation(
                response: response,
                dampingFraction: dampingFraction,
                blendDuration: blendDuration
            )
        )
    }

    /// A convenience for a `spring` animation with a lower
    /// `duration` value, intended for driving interactive animations.
    ///
    /// This uses the default parameter values.
    @_alwaysEmitIntoClient
    public static var interactiveSpring: Animation {
        interactiveSpring()
    }

    /// A convenience for a `spring` animation with a lower
    /// `response` value, intended for driving interactive animations.
    @_alwaysEmitIntoClient
    public static func interactiveSpring(
        duration: TimeInterval = 0.15,
        extraBounce: Double = 0.0,
        blendDuration: TimeInterval = 0.25
    ) -> Animation {
        spring(
            duration: duration, bounce: 0.15 + extraBounce,
            blendDuration: blendDuration)
    }

    @_spi(_)
    @available(*, deprecated)
    @_alwaysEmitIntoClient
    public static func interactiveSpring(
        duration: TimeInterval = 0.15,
        additionalBounce: Double,
        blendDuration: TimeInterval = 0.25
    ) -> Animation {
        spring(
            duration: duration, bounce: 0.15 + additionalBounce,
            blendDuration: blendDuration)
    }

    /// A smooth spring animation with a predefined duration and no bounce.
    @_alwaysEmitIntoClient
    public static var smooth: Animation {
        smooth()
    }

    /// A smooth spring animation with a predefined duration and no bounce
    /// that can be tuned.
    ///
    /// - Parameters:
    ///   - duration: The perceptual duration, which defines the pace of the
    ///     spring. This is approximately equal to the settling duration, but
    ///     for very bouncy springs, will be the duration of the period of
    ///     oscillation for the spring.
    ///   - extraBounce: How much additional bounce should be added to the base
    ///     bounce of 0.
    ///   - blendDuration: The duration in seconds over which to interpolate
    ///     changes to the duration.
    @_alwaysEmitIntoClient
    public static func smooth(duration: TimeInterval = 0.5, extraBounce: Double = 0.0) -> Animation {
        spring(duration: duration, bounce: extraBounce)
    }

    @_spi(_)
    @available(*, deprecated)
    @_alwaysEmitIntoClient
    public static func smooth(duration: TimeInterval = 0.5, additionalBounce: Double) -> Animation {
        spring(duration: duration, bounce: additionalBounce)
    }

    /// A spring animation with a predefined duration and small amount of
    /// bounce that feels more snappy.
    @_alwaysEmitIntoClient
    public static var snappy: Animation {
        snappy()
    }

    /// A spring animation with a predefined duration and small amount of
    /// bounce that feels more snappy and can be tuned.
    ///
    /// - Parameters:
    ///   - duration: The perceptual duration, which defines the pace of the
    ///     spring. This is approximately equal to the settling duration, but
    ///     for very bouncy springs, will be the duration of the period of
    ///     oscillation for the spring.
    ///   - extraBounce: How much additional bounce should be added to the base
    ///     bounce of 0.15.
    ///   - blendDuration: The duration in seconds over which to interpolate
    ///     changes to the duration.
    @_alwaysEmitIntoClient
    public static func snappy(duration: TimeInterval = 0.5, extraBounce: Double = 0.0) -> Animation {
        spring(duration: duration, bounce: 0.15 + extraBounce)
    }

    @_spi(_)
    @available(*, deprecated)
    @_alwaysEmitIntoClient
    public static func snappy(duration: TimeInterval = 0.5, additionalBounce: Double) -> Animation {
        spring(duration: duration, bounce: 0.15 + additionalBounce)
    }

    /// A spring animation with a predefined duration and higher amount of
    /// bounce.
    @_alwaysEmitIntoClient
    public static var bouncy: Animation {
        bouncy()
    }

    /// A spring animation with a predefined duration and higher amount of
    /// bounce that can be tuned.
    ///
    /// - Parameters:
    ///   - duration: The perceptual duration, which defines the pace of the
    ///     spring. This is approximately equal to the settling duration, but
    ///     for very bouncy springs, will be the duration of the period of
    ///     oscillation for the spring.
    ///   - extraBounce: How much additional bounce should be added to the base
    ///     bounce of 0.3.
    ///   - blendDuration: The duration in seconds over which to interpolate
    ///     changes to the duration.
    @_alwaysEmitIntoClient
    public static func bouncy(duration: TimeInterval = 0.5, extraBounce: Double = 0.0) -> Animation {
        spring(duration: duration, bounce: 0.3 + extraBounce)
    }

    @_spi(_)
    @available(*, deprecated)
    @_alwaysEmitIntoClient
    public static func bouncy(duration: TimeInterval = 0.5, additionalBounce: Double) -> Animation {
        spring(duration: duration, bounce: 0.3 + additionalBounce)
    }
}

extension FluidSpringAnimation: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.doubleField(1, response, defaultValue: 0.0)
        encoder.doubleField(2, dampingFraction, defaultValue: 0.0)
        encoder.doubleField(3, blendDuration, defaultValue: 0.0)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var response: Double = 0.0
        var dampingFraction: Double = 0.0
        var blendDuration: TimeInterval = 0.0
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: response = try decoder.doubleField(field)
            case 2: dampingFraction = try decoder.doubleField(field)
            case 3: blendDuration = try decoder.doubleField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(
            response: response,
            dampingFraction: dampingFraction,
            blendDuration: blendDuration
        )
    }
}
