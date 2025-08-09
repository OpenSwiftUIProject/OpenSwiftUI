//
//  SpringAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 580A00FC96845561BA69B57FCB8F7ECD (SwiftUICore)

public import Foundation

package struct SpringAnimation: InternalCustomAnimation {
    package var mass: Double
    package var stiffness: Double
    package var damping: Double
    package var initialVelocity: _Velocity<Double>
    
    package init(
        mass: Double,
        stiffness: Double,
        damping: Double,
        initialVelocity: _Velocity<Double>
    ) {
        self.mass = mass
        self.stiffness = stiffness
        self.damping = damping
        self.initialVelocity = initialVelocity
    }
    
    package init(mass: Double, stiffness: Double, damping: Double) {
        self.mass = mass
        self.stiffness = stiffness
        self.damping = damping
        self.initialVelocity = .zero
    }

    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        let model = SpringModel(self)
        let duration = model.duration(epsilon: 0.001)
        guard duration > time else {
            return nil
        }
        let sample = model.sample(at: time)
        guard sample.isFinite else {
            return nil
        }
        let endTime = stiffness.isFinite ? .tau / sqrt(stiffness) : 0.0
        if time >= endTime {
            context.isLogicallyComplete = true
        }
        return value.scaled(by: sample)
    }
    
    package var function: Animation.Function {
        return .spring(
            duration: SpringModel(self).duration(epsilon: 0.001),
            mass: mass,
            stiffness: stiffness,
            damping: damping,
            initialVelocity: initialVelocity.valuePerSecond
        )
    }
}

private struct SpringModel {
    let angularFrequency: Double
    let dampingRatio: Double
    let decayFactor: Double
    let constant: Double
    let adjustedFrequency: Double

    init(_ spring: SpringAnimation) {
        angularFrequency = sqrt(spring.stiffness / spring.mass)
        dampingRatio = spring.damping / (sqrt(spring.mass * spring.stiffness) * 2.0)
        if dampingRatio >= 1.0 {
            decayFactor = 0.0
            adjustedFrequency = angularFrequency - spring.initialVelocity.valuePerSecond
        } else {
            decayFactor = angularFrequency * sqrt(1.0 - dampingRatio * dampingRatio)
            adjustedFrequency = (angularFrequency * dampingRatio - spring.initialVelocity.valuePerSecond) / decayFactor
        }
        constant = 1.0
    }

    func duration(epsilon: Double) -> Double {
        let epsilon = max(1e-6, epsilon)
        guard dampingRatio != .zero else {
            return .infinity
        }
        guard dampingRatio >= 1.0 else {
            let v = epsilon / (abs(constant) + abs(adjustedFrequency))
            return .maximum(-log(v) / (dampingRatio / angularFrequency), 1.0)
        }

        var time = 0.0
        var minValue = Double.infinity
        var iterations = 1024
        var minTime = -1.0
        while iterations != 0 {
            let value = abs(1.0 - sample(at: time))
            guard value.isFinite else {
                return .zero
            }
            if minValue >= epsilon {
                if value < minValue {
                    minValue = value
                    minTime = time
                }
            } else if value >= epsilon {
                minValue = .infinity
            } else {
                guard time - minTime <= 1.0 else {
                    break
                }
            }
            time += 0.1
            iterations &-= 1
        }
        return minTime
    }

    func sample(at time: Double) -> Double {
        let amplitudeFactor: Double
        let exponentialDecay: Double
        if dampingRatio >= 1.0 {
            amplitudeFactor = constant + adjustedFrequency * time
            exponentialDecay = exp(-time * angularFrequency)
        } else {
            amplitudeFactor = exp((-dampingRatio * angularFrequency) * time)
            let sinValue = sin(decayFactor * time)
            let cosValue = cos(decayFactor * time)
            exponentialDecay = constant * cosValue + adjustedFrequency * sinValue
        }
        return 1.0 - amplitudeFactor * exponentialDecay
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Animation {
    /// An interpolating spring animation that uses a damped spring
    /// model to produce values in the range [0, 1] that are then used
    /// to interpolate within the [from, to] range of the animated
    /// property. Preserves velocity across overlapping animations by
    /// adding the effects of each animation.
    ///
    /// - Parameters:
    ///   - mass: The mass of the object attached to the spring.
    ///   - stiffness: The stiffness of the spring.
    ///   - damping: The spring damping value.
    ///   - initialVelocity: the initial velocity of the spring, as
    ///     a value in the range [0, 1] representing the magnitude of
    ///     the value being animated.
    /// - Returns: a spring animation.
    public static func interpolatingSpring(
        mass: Double = 1.0,
        stiffness: Double,
        damping: Double,
        initialVelocity: Double = 0.0
    ) -> Animation {
        Animation(
            SpringAnimation(
                mass: mass,
                stiffness: stiffness,
                damping: damping,
                initialVelocity: .init(
                    valuePerSecond: initialVelocity
                )
            )
        )
    }

    /// An interpolating spring animation that uses a damped spring
    /// model to produce values in the range [0, 1] that are then used
    /// to interpolate within the [from, to] range of the animated
    /// property. Preserves velocity across overlapping animations by
    /// adding the effects of each animation.
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
    ///   - initialVelocity: the initial velocity of the spring, as
    ///     a value in the range [0, 1] representing the magnitude of
    ///     the value being animated.
    /// - Returns: a spring animation.
    @_alwaysEmitIntoClient
    public static func interpolatingSpring(
        duration: TimeInterval = 0.5,
        bounce: Double = 0.0,
        initialVelocity: Double = 0.0
    ) -> Animation {
        let stiffness = springStiffness(response: duration)
        let fraction = springDampingFraction(bounce: bounce)
        let damping = springDamping(fraction: fraction, stiffness: stiffness)
        return interpolatingSpring(
            stiffness: stiffness, damping: damping,
            initialVelocity: initialVelocity)
    }

    /// An interpolating spring animation that uses a damped spring
    /// model to produce values in the range [0, 1] that are then used
    /// to interpolate within the [from, to] range of the animated
    /// property. Preserves velocity across overlapping animations by
    /// adding the effects of each animation.
    ///
    /// This uses the default parameter values.
    @_alwaysEmitIntoClient
    public static var interpolatingSpring: Animation {
        .interpolatingSpring()
    }
}

extension SpringAnimation: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.doubleField(1, mass, defaultValue: 1.0)
        encoder.doubleField(2, stiffness, defaultValue: 100.0)
        encoder.doubleField(3, damping, defaultValue: 20.0)
        encoder.doubleField(4, initialVelocity.valuePerSecond, defaultValue: 0.0)
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var mass: Double = 1.0
        var stiffness: Double = 100.0
        var damping: Double = 20.0
        var initialVelocity = _Velocity<Double>(valuePerSecond: 0.0)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: mass = try decoder.doubleField(field)
            case 2: stiffness = try decoder.doubleField(field)
            case 3: damping = try decoder.doubleField(field)
            case 4: initialVelocity.valuePerSecond = try decoder.doubleField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(
            mass: mass,
            stiffness: stiffness,
            damping: damping,
            initialVelocity: initialVelocity
        )
    }
}
