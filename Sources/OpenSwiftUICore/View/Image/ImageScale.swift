//
//  ImageScale.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8E7DCD4CEB1ACDE07B249BFF4CBC75C0 (SwiftUICore)
#if canImport(Darwin)
package import Foundation
#endif

extension Image {
    /// A hashable representation of `Image.Scale` for use as a cache key.
    package enum HashableScale: Hashable {
        case small
        case medium
        case large
        case ccSmall
        case ccMedium
        case ccLarge

        package init(_ scale: Image.Scale) {
            switch scale {
            case .small: self = .small
            case .medium: self = .medium
            case .large: self = .large
            case ._controlCenter_small: self = .ccSmall
            case ._controlCenter_medium: self = .ccMedium
            case ._controlCenter_large: self = .ccLarge
            default: self = .medium
            }
        }

        // MARK: - Helpers for symbol sizing

        /// Returns the allowed range for symbol size scaling.
        ///
        /// - For standard scales (small, medium, large): returns 1.0...1.0 (no scaling)
        /// - For control center scales: reads from NSUserDefaults
        ///   "CCImageScale_MinimumScale" and "CCImageScale_MaximumScale"
        package var allowedScaleRange: ClosedRange<CGFloat> {
            switch self {
            case .small, .medium, .large:
                return 1.0 ... 1.0
            case .ccSmall, .ccMedium, .ccLarge:
                #if canImport(Darwin)
                let defaults = UserDefaults.standard
                let lower = (defaults.value(forKey: "CCImageScale_MinimumScale") as? CGFloat) ?? 0.0
                let upper = (defaults.value(forKey: "CCImageScale_MaximumScale") as? CGFloat) ?? .greatestFiniteMagnitude
                precondition(lower <= upper, "xx")
                return lower ... upper
                #else
                return 0.0 ... .greatestFiniteMagnitude
                #endif
            }
        }

        // Weight interpolation constants per scale category:
        //   (lightValue, nominalValue, heavyValue)
        // where lightValue is at weight -0.8 (ultraLight),
        //       nominalValue is at weight 0 (regular),
        //       heavyValue is at weight 0.62 (black).
        //
        // These represent the circle.fill diameter as a percentage of point size.
        private static let smallConstants:  (light: Double, nominal: Double, heavy: Double) = (74.46, 78.86, 83.98)
        private static let mediumConstants: (light: Double, nominal: Double, heavy: Double) = (94.63, 99.61, 106.64)
        private static let largeConstants:  (light: Double, nominal: Double, heavy: Double) = (121.66, 127.2, 135.89)

        /// Computes the diameter of a circle.fill symbol for the given point size and weight.
        ///
        /// The result is `interpolatedPercentage * 0.01 * pointSize`, where the
        /// percentage is interpolated based on font weight between three known
        /// values (ultraLight, regular, black).
        package func circleDotFillSize(pointSize: CGFloat, weight: Font.Weight) -> CGFloat {
            let w = weight.value
            let constants: (light: Double, nominal: Double, heavy: Double)

            // Discriminator bitmask: medium/ccMedium = 0x52, small/ccSmall = 0x9
            switch self {
            case .medium, .ccMedium:
                constants = Self.mediumConstants
            case .small, .ccSmall:
                constants = Self.smallConstants
            default: // large, ccLarge
                constants = Self.largeConstants
            }

            let percentage: CGFloat
            if w == 0.0 {
                percentage = constants.nominal
            } else if w < 0.0 {
                // Interpolate from light (at -0.8) to nominal (at 0)
                percentage = constants.light + (w + 0.8) / 0.8 * (constants.nominal - constants.light)
            } else {
                // Interpolate from nominal (at 0) to heavy (at 0.62)
                percentage = constants.nominal + w / 0.62 * (constants.heavy - constants.nominal)
            }

            return percentage * 0.01 * pointSize
        }

        /// Computes the maximum allowed radius from a given diameter.
        ///
        /// The base radius is `diameter / 2`. For control center scales,
        /// this is multiplied by a scale factor read from NSUserDefaults
        /// "CCImageScale_CircleScale" (default 1.2).
        package func maxRadius(diameter: CGFloat) -> CGFloat {
            var radius = diameter * 0.5

            switch self {
            case .small, .medium, .large:
                break
            case .ccSmall, .ccMedium, .ccLarge:
                #if canImport(Darwin)
                let scale = (UserDefaults.standard.value(forKey: "CCImageScale_CircleScale") as? CGFloat) ?? 1.2
                #else
                let scale: CGFloat = 1.2
                #endif
                radius *= scale
            }

            return radius
        }
    }
}
