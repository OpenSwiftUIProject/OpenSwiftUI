//
//  Created by ktiays on 2024/11/20.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

public import Foundation

@available(OpenSwiftUI_v5_0, *)
extension Spring {

    /// Creates a spring with the specified duration and bounce.
    ///
    /// - Parameters:
    ///   - duration: Defines the pace of the spring. This is approximately
    ///   equal to the settling duration, but for springs with very large
    ///   bounce values, will be the duration of the period of oscillation
    ///   for the spring.
    ///   - bounce: How bouncy the spring should be. A value of 0 indicates
    ///   no bounces (a critically damped spring), positive values indicate
    ///   increasing amounts of bounciness up to a maximum of 1.0
    ///   (corresponding to undamped oscillation), and negative values
    ///   indicate overdamped springs with a minimum value of -1.0.
    public init(duration: TimeInterval = 0.5, bounce: Double = 0.0) {
        var angularVelocityFactor: Double = -.tau
        var dampingRatio: Double = .infinity

        // Calculate damping ratio based on bounce parameter
        if bounce > -1 {
            dampingRatio = 1

            if bounce < 0 {
                // Handle overdamped case (negative bounce)
                dampingRatio = 1 / (bounce + 1)
            } else if bounce != 0 {
                // Handle underdamped case (positive bounce)
                dampingRatio = 0
                if bounce <= 1 {
                    dampingRatio = 1 - bounce
                }
            }

            // Adjust angular velocity factor for underdamped case
            if dampingRatio <= 1 {
                angularVelocityFactor = .tau
            }
        }

        // Calculate final spring parameters
        angularFrequency = sqrt(abs(1 - dampingRatio * dampingRatio)) * angularVelocityFactor / duration
        decayConstant = dampingRatio * .tau / duration
        _mass = 1
    }

    /// The perceptual duration, which defines the pace of the spring.
    public var duration: TimeInterval {
        let omega = angularFrequency
        let decay = decayConstant
        let absoluteOmega = abs(omega)

        return .tau / sqrt(decay * decay + omega * absoluteOmega)
    }

    /// How bouncy the spring is.
    ///
    /// A value of 0 indicates no bounces (a critically damped spring), positive values indicate
    /// increasing amounts of bounciness up to a maximum of 1.0 (corresponding to undamped oscillation),
    /// and negative values indicate overdamped springs with a minimum value of -1.0.
    public var bounce: Double {
        let halfDecay = decayConstant / 2
        let decaySquared = decayConstant * decayConstant
        let frequencySquared = angularFrequency * angularFrequency

        if angularFrequency >= 0 {
            let oscillationPeriod = -.tau / sqrt(frequencySquared + decaySquared)
            let bounceValue = (oscillationPeriod * halfDecay) / .pi + 1
            return bounceValue
        } else {
            let decayPeriod = .tau / sqrt(decaySquared - frequencySquared)
            let bounceValue = 1 / ((decayPeriod * halfDecay) / .pi) - 1
            return bounceValue
        }
    }
}
