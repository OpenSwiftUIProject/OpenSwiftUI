//
//  Created by ktiays on 2024/11/20.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

public import Foundation

@available(OpenSwiftUI_v5_0, *)
extension Spring {

    /// Creates a spring with the specified duration and damping ratio.
    ///
    /// - Parameters:
    ///   - settlingDuration: The approximate time it will take for the spring to come to rest.
    ///   - dampingRatio: The amount of drag applied as a fraction of the amount needed to produce critical damping.
    ///   - epsilon: The threshhold for how small all subsequent values need to be before the spring is considered to have settled.
    public init(settlingDuration: TimeInterval, dampingRatio: Double, epsilon: Double = 0.001) {
        let dampingRatio = min(max(dampingRatio, .ulpOfOne), 1)
        let duration = min(max(settlingDuration, 0.01), 10)

        let dampingSquaredDuration = dampingRatio * dampingRatio * duration
        let naturalFrequency = sqrt(1 - dampingRatio * dampingRatio)
        let dampingFrequencyRatio = dampingRatio / naturalFrequency
        let dampedTime = duration * dampingRatio

        @discardableResult
        func findRoot(
            initialGuess: Double,
            maxIterations: Int,
            response: (Double) -> Double,
            derivative: (Double) -> Double,
            result: inout Double
        ) -> Bool {
            var currentValue: Double = initialGuess
            var timeScale: Double = 1 / duration
            var remainingIterations = maxIterations

            var scaledValue = timeScale * currentValue
            var approximation = scaledValue
            defer { result = approximation }

            currentValue = response(approximation)
            let nextValue = approximation - currentValue / derivative(approximation)
            approximation = nextValue

            if nextValue.isInfinite || nextValue.isNaN {
                return false
            }
            if remainingIterations == 1 {
                return true
            }
            scaledValue = nextValue - response(nextValue) / derivative(approximation)
            approximation = scaledValue
            if scaledValue.isInfinite || scaledValue.isNaN {
                return false
            }
            remainingIterations -= 2
            if remainingIterations == 0 {
                return true
            }

            var difference = nextValue - scaledValue
            repeat {
                currentValue = scaledValue - response(scaledValue) / derivative(approximation)
                approximation = currentValue
                if currentValue.isInfinite || currentValue.isNaN {
                    return false
                }

                timeScale = abs(currentValue - scaledValue)
                if timeScale <= epsilon {
                    return difference <= epsilon * 1e5
                }
                difference = scaledValue - currentValue
                scaledValue = currentValue
                remainingIterations -= 1
            } while remainingIterations > 0
            return true
        }

        func dampedOscillation(_ x: Double) -> Double {
            epsilon - abs(dampingFrequencyRatio * exp(-dampedTime * x))
        }

        func dampedResponse(_ x: Double) -> Double {
            let squaredX = x * x
            let dampingTerm = squaredX * dampingSquaredDuration
            return dampingTerm / (exp(dampedTime * x) * squaredX * naturalFrequency)
        }

        func criticalResponse(_ x: Double) -> Double {
            var threshold = epsilon
            if x < 0 {
                threshold = -threshold
            }
            var response = duration * x
            response = exp(-response) * (response + 1) - threshold
            return response
        }

        func criticalDerivative(_ x: Double) -> Double {
            -duration * duration * x / exp(duration * x)
        }

        let responseFunction: (Double) -> Double
        let derivativeFunction: (Double) -> Double
        if dampingRatio >= 1 {
            responseFunction = criticalResponse
            derivativeFunction = criticalDerivative
        } else {
            responseFunction = dampedOscillation
            derivativeFunction = dampedResponse
        }

        var rootValue: Double = 0
        if !findRoot(
            initialGuess: 5,
            maxIterations: 12,
            response: responseFunction,
            derivative: derivativeFunction,
            result: &rootValue
        ) {
            findRoot(
                initialGuess: 1,
                maxIterations: 20,
                response: responseFunction,
                derivative: derivativeFunction,
                result: &rootValue
            )
        }

        var omega = rootValue
        let omegaSquared = omega * omega
        omega = omega * 2 * dampingRatio
        let halfOmega = omega / 2
        omega = abs(omegaSquared - halfOmega * halfOmega).squareRoot()
        let decay: Double
        if rootValue >= halfOmega {
            decay = halfOmega
        } else {
            decay = rootValue
        }
        if rootValue < halfOmega {
            omega = 0
        }

        angularFrequency = omega
        decayConstant = decay
        _mass = 1
    }
}
