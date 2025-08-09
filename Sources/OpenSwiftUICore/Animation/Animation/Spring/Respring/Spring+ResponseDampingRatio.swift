//
//  Created by ktiays on 2024/11/20.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

import Foundation

@available(OpenSwiftUI_v5_0, *)
extension Spring {

    /// Creates a spring with the specified response and damping ratio.
    ///
    /// - Parameters:
    ///   - response: Defines the stiffness of the spring as an approximate
    ///   duration in seconds.
    ///   - dampingRatio: Defines the amount of drag applied as a fraction the
    ///   amount needed to produce critical damping.
    public init(response: Double, dampingRatio: Double) {
        // Calculate angular frequency and decay based on whether system is overdamped.
        let isOverdamped = dampingRatio > 1
        let tauFactor = isOverdamped ? -.tau : .tau
        let ratioSquared = dampingRatio * dampingRatio
        let dampingOffset = abs(1 - ratioSquared)

        // Calculate final spring parameters.
        let frequencyComponent = sqrt(dampingOffset)
        angularFrequency = (tauFactor * frequencyComponent) / response
        decayConstant = (.tau * dampingRatio) / response
        _mass = 1
    }

    /// The stiffness of the spring, defined as an approximate duration in seconds.
    public var response: Double {
        let dampingSquared = decayConstant * decayConstant
        let responseTerm = angularFrequency * abs(angularFrequency)
        return .tau / sqrt(dampingSquared + responseTerm)
    }

    /// The amount of drag applied, as a fraction of the amount needed to
    /// produce critical damping.
    ///
    /// When `dampingRatio` is 1, the spring will smoothly decelerate to its
    /// final position without oscillating. Damping ratios less than 1 will
    /// oscillate more and more before coming to a complete stop.
    public var dampingRatio: Double {
        decayConstant * response / .tau
    }
}
