//
//  Created by ktiays on 2024/11/20.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

// TODO: Audit Respring and update to 6.5.4

public import Foundation

/// A representation of a spring's motion.
@available(OpenSwiftUI_v5_0, *)
public struct Spring: Hashable, Sendable {
    package var angularFrequency: Double
    package var decayConstant: Double
    package var _mass: Double

    init(angularFrequency: Double, decayConstant: Double, mass: Double) {
        self.angularFrequency = angularFrequency
        self.decayConstant = decayConstant
        self._mass = mass
    }
}

@available(OpenSwiftUI_v5_0, *)
extension Spring {

    /// A smooth spring with a predefined duration and no bounce.
    public static var smooth: Spring { .init() }

    /// A smooth spring with a predefined duration and no bounce that can be
    /// tuned.
    ///
    /// - Parameters:
    ///   - duration: The perceptual duration, which defines the pace of the
    ///     spring. This is approximately equal to the settling duration, but
    ///     for very bouncy springs, will be the duration of the period of
    ///     oscillation for the spring.
    ///   - extraBounce: How much additional bounce should be added to the base
    ///     bounce of 0.
    @inlinable
    public static func smooth(duration: TimeInterval = 0.5, extraBounce: Double = 0.0) -> Spring {
        .init(duration: duration, bounce: extraBounce)
    }

    /// A spring with a predefined duration and small amount of bounce that
    /// feels more snappy.
    public static var snappy: Spring {
        .init(duration: 0.5, bounce: 0.15)
    }

    /// A spring with a predefined duration and small amount of bounce that
    /// feels more snappy and can be tuned.
    ///
    /// - Parameters:
    ///   - duration: The perceptual duration, which defines the pace of the
    ///     spring. This is approximately equal to the settling duration, but
    ///     for very bouncy springs, will be the duration of the period of
    ///     oscillation for the spring.
    ///   - extraBounce: How much additional bounciness should be added to the
    ///     base bounce of 0.15.
    @inlinable
    public static func snappy(duration: TimeInterval = 0.5, extraBounce: Double = 0.0) -> Spring {
        .init(duration: duration, bounce: 0.15 + extraBounce)
    }

    /// A spring with a predefined duration and higher amount of bounce.
    public static var bouncy: Spring {
        .init(duration: 0.5, bounce: 0.3)
    }

    /// A spring with a predefined duration and higher amount of bounce that
    /// can be tuned.
    ///
    /// - Parameters:
    ///   - duration: The perceptual duration, which defines the pace of the
    ///     spring. This is approximately equal to the settling duration, but
    ///     for very bouncy springs, will be the duration of the period of
    ///     oscillation for the spring.
    ///   - extraBounce: How much additional bounce should be added to the base
    ///     bounce of 0.3.
    @inlinable
    public static func bouncy(duration: TimeInterval = 0.5, extraBounce: Double = 0.0) -> Spring {
        .init(duration: duration, bounce: 0.3 + extraBounce)
    }

    @_spi(_)
    @available(*, deprecated)
    @_alwaysEmitIntoClient
    public static func bouncy(duration: TimeInterval = 0.5, additionalBounce: Double) -> Spring {
        Self(duration: duration, bounce: 0.3 + additionalBounce)
    }
}
