//
//  Created by ktiays on 2024/11/20.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

import Foundation

@available(OpenSwiftUI_v5_0, *)
extension Spring {

    /// Creates a spring with the specified mass, stiffness, and damping.
    ///
    /// - Parameters:
    ///   - mass: Specifies that property of the object attached to the end of
    ///   the spring.
    ///   - stiffness: The corresponding spring coefficient.
    ///   - damping: Defines how the spring's motion should be damped due to the
    ///   forces of friction.
    ///   - allowOverdamping: A value of true specifies that over-damping
    ///   should be allowed when appropriate based on the other inputs, and a
    ///   value of false specifies that such cases should instead be treated as
    ///   critically damped.
    public init(mass: Double = 1.0, stiffness: Double, damping: Double, allowOverDamping: Bool = false) {
        let naturalFrequency = sqrt(stiffness / mass)
        let dampingRatio = damping / (2 * mass)

        if dampingRatio > naturalFrequency && !allowOverDamping {
            angularFrequency = 0
            decayConstant = naturalFrequency
        } else {
            let oscillation = sqrt(abs(stiffness / mass - dampingRatio * dampingRatio))
            angularFrequency = dampingRatio > naturalFrequency ? -oscillation : oscillation
            decayConstant = dampingRatio
        }

        _mass = mass
    }

    /// The mass of the object attached to the end of the spring.
    ///
    /// The default mass is 1. Increasing this value will increase the spring's
    /// effect: the attached object will be subject to more oscillations and
    /// greater overshoot, resulting in an increased settling duration.
    /// Decreasing the mass will reduce the spring effect: there will be fewer
    /// oscillations and a reduced overshoot, resulting in a decreased
    /// settling duration.
    public var mass: Double { _mass }

    /// The spring stiffness coefficient.
    ///
    /// Increasing the stiffness reduces the number of oscillations and will
    /// reduce the settling duration. Decreasing the stiffness increases the the
    /// number of oscillations and will increase the settling duration.
    public var stiffness: Double {
        mass * (angularFrequency * angularFrequency + decayConstant * decayConstant)
    }

    /// Defines how the spring’s motion should be damped due to the forces of
    /// friction.
    ///
    /// Reducing this value reduces the energy loss with each oscillation: the
    /// spring will overshoot its destination. Increasing the value increases
    /// the energy loss with each duration: there will be fewer and smaller
    /// oscillations.
    public var damping: Double {
        decayConstant * 2 * mass
    }
}
