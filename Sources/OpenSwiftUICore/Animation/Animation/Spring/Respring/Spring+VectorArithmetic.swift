//
//  Created by ktiays on 2024/11/21.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

public import Foundation

@available(OpenSwiftUI_v5_0, *)
extension Spring {
    
    /// The estimated duration required for the spring system to be considered
    /// at rest.
    ///
    /// This uses a `target` of 1.0, an `initialVelocity` of 0, and an `epsilon`
    /// of 0.001.
    public var settlingDuration: TimeInterval {
        self.settlingDuration(target: 1.0, initialVelocity: 0, epsilon: 0.001)
    }
    
    /// The estimated duration required for the spring system to be considered at rest.
    ///
    /// The epsilon value specifies the threshhold for how small all subsequent
    /// values need to be before the spring is considered to have settled.
    public func settlingDuration<V>(target: V, initialVelocity: V = .zero, epsilon: Double) -> TimeInterval where V: VectorArithmetic {
        if decayConstant == 0 {
            return .infinity
        }
        
        if angularFrequency <= 0 {
            var bestTime = -1.0
            var time: TimeInterval = 0.0
            var bestDistance: Double = .infinity
            
            for _ in 0..<1024 {
                let currentValue = value(
                    target: target,
                    initialVelocity: initialVelocity,
                    time: time
                )
                let diff = currentValue - target
                let distance = sqrt(diff.magnitudeSquared)
                if distance.isNaN || distance.isInfinite {
                    break
                }
                
                if bestDistance >= epsilon {
                    if distance < bestDistance {
                        bestTime = time
                        bestDistance = distance
                    }
                } else {
                    if distance >= epsilon {
                        bestDistance = .infinity
                    } else if time - bestTime > 1 {
                        return bestTime
                    }
                }
                
                time += 0.1
            }
            
            return 0
        }
        
        let magnitude = (target.scaled(by: decayConstant) - initialVelocity).magnitudeSquared.squareRoot() + sqrt(target.magnitudeSquared)
        let settlingTime = -log(epsilon / magnitude) / decayConstant
        return max(0, settlingTime)
    }

    /// Calculates the value of the spring at a given time given a target amount of change.
    public func value<V>(target: V, initialVelocity: V = .zero, time: TimeInterval) -> V where V: VectorArithmetic {
        if angularFrequency > 0 {
            let sinval = sin(angularFrequency * time)
            let cosval = cos(angularFrequency * time)

            let displacement = (target.scaled(by: decayConstant) - initialVelocity).scaled(by: sinval / angularFrequency) + target.scaled(by: cosval)
            return target - displacement.scaled(by: exp(-decayConstant * time))
        } else if angularFrequency < 0 {
            let negativeFreqMinusDamping = -angularFrequency - decayConstant
            let expTerm1 = exp(negativeFreqMinusDamping * time)
            let expTerm2 = exp((angularFrequency - decayConstant) * time)

            let dampingFactor = (decayConstant - angularFrequency) * expTerm1 + negativeFreqMinusDamping * expTerm2
            let scaleFactor = dampingFactor / (angularFrequency * 2) + 1
            let velocityFactor = (expTerm1 - expTerm2) / (angularFrequency * 2)

            return target.scaled(by: scaleFactor) - initialVelocity.scaled(by: velocityFactor)
        } else {
            let displacement = target + (target.scaled(by: decayConstant) - initialVelocity).scaled(by: time)
            let dampingTerm = exp(-decayConstant * time)
            return target - displacement.scaled(by: dampingTerm)
        }
    }

    /// Calculates the velocity of the spring at a given time given a target amount of change.
    public func velocity<V>(target: V, initialVelocity: V = .zero, time: TimeInterval) -> V where V: VectorArithmetic {
        if angularFrequency > 0 {
            let dampingTerm = exp(-decayConstant * time)
            let sinval = sin(angularFrequency * time)
            let cosval = cos(angularFrequency * time)

            let targetTerm = target.scaled(by: (angularFrequency * sinval + decayConstant * cosval) * dampingTerm)
            let displacementFactor = (decayConstant * sinval - angularFrequency * cosval) * dampingTerm / angularFrequency
            let velocityTerm = (target.scaled(by: decayConstant) - initialVelocity).scaled(by: displacementFactor)
            return velocityTerm + targetTerm
        } else if angularFrequency < 0 {
            let negativeFreqMinusDamping = -angularFrequency - decayConstant
            let dampingMinusFreq = angularFrequency - decayConstant

            let expTerm1 = exp(negativeFreqMinusDamping * time)
            let expTerm2 = exp(dampingMinusFreq * time)

            let term1 = negativeFreqMinusDamping * expTerm1
            let term2 = dampingMinusFreq * expTerm2

            let scaleFactor = ((decayConstant - angularFrequency) * term1 + negativeFreqMinusDamping * term2) / (angularFrequency * 2) + 1
            let velocityFactor = (term1 - term2) / (angularFrequency * 2)

            return target.scaled(by: scaleFactor) - initialVelocity.scaled(by: velocityFactor)
        } else {
            let dampingTerm = exp(-decayConstant * time)
            let timeFactor = (decayConstant * time - 1) * dampingTerm
            let velocityDelta = target.scaled(by: decayConstant) - initialVelocity
            let dampedTarget = target.scaled(by: decayConstant * dampingTerm)
            return velocityDelta.scaled(by: timeFactor) + dampedTarget
        }
    }

    /// Updates the current  value and velocity of a spring.
    ///
    /// - Parameters:
    ///   - value: The current value of the spring.
    ///   - velocity: The current velocity of the spring.
    ///   - target: The target that `value` is moving towards.
    ///   - deltaTime: The amount of time that has passed since the spring was
    ///     at the position specified by `value`.
    public func update<V>(value: inout V, velocity: inout V, target: V, deltaTime: TimeInterval) where V: VectorArithmetic {
        let delta = target - value
        let deltaVelocity = self.velocity(target: delta, initialVelocity: velocity, time: deltaTime)
        let deltaValue = self.value(target: delta, initialVelocity: velocity, time: deltaTime)
        velocity = deltaVelocity
        value += deltaValue
    }

    /// Calculates the force upon the spring given a current position, target, and velocity amount of change.
    ///
    /// This value is in units of the vector type per second squared.
    public func force<V>(target: V, position: V, velocity: V) -> V where V: VectorArithmetic {
        let dampingForce = velocity.scaled(by: (-decayConstant * 2) * _mass)
        let delta = target - position
        let springForce = delta.scaled(by: (angularFrequency * angularFrequency + decayConstant * decayConstant) * _mass)
        return springForce + dampingForce
    }
}
