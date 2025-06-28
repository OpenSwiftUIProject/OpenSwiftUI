//
//  FloatingPoint+Extension.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - FloatingPoint + Zero [6.0.87]

extension FloatingPoint {
    /// Determines whether two floating-point values are approximately equal within a specified tolerance.
    ///
    /// This method provides a relative comparison that accounts for the magnitude of the values:
    /// - For finite values, it compares whether the difference between values is less than
    ///   the tolerance multiplied by the larger of the two values' magnitudes
    /// - For non-finite values (NaN or infinity), it delegates to ``rescaledAlmostEqual(to:tolerance:)``
    ///
    /// - Parameters:
    ///   - other: The floating-point value to compare against
    ///   - tolerance: The relative tolerance to use for the comparison
    ///
    /// - Returns: `true` if the values are approximately equal, `false` otherwise
    package func isAlmostEqual(to other: Self, tolerance: Self) -> Bool {
        guard self.isFinite && other.isFinite else {
            return self.rescaledAlmostEqual(to: other, tolerance: tolerance)
        }
        let magnitude = max(abs(self), abs(other), .leastNormalMagnitude)
        let difference = abs(self - other)
        return difference < magnitude * tolerance
    }

    /// Determines whether two floating-point values are approximately equal using a default tolerance.
    ///
    /// This method uses the square root of the ULP (Unit in the Last Place) as the default tolerance value,
    /// which provides a reasonable balance between precision and accounting for floating-point rounding errors.
    ///
    /// - Parameter other: The floating-point value to compare against
    ///
    /// - Returns: `true` if the values are approximately equal, `false` otherwise
    ///
    /// - SeeAlso: ``isAlmostEqual(to:tolerance:)``
    package func isAlmostEqual(to other: Self) -> Bool {
        isAlmostEqual(to: other, tolerance: .ulpOfOne.squareRoot())
    }

    /// Determines whether this floating-point value is approximately zero within a specified tolerance.
    ///
    /// This method uses an absolute tolerance rather than a relative one, which is appropriate
    /// when determining if a value is close to zero.
    ///
    /// - Parameter tolerance: The absolute tolerance to use for the comparison
    ///
    /// - Returns: `true` if the absolute value is less than the specified tolerance, `false` otherwise
    package func isAlmostZero(absoluteTolerance tolerance: Self) -> Bool {
        abs(self) < tolerance
    }

    /// Determines whether this floating-point value is approximately zero using a default tolerance.
    ///
    /// This method uses the square root of the ULP (Unit in the Last Place) as the default tolerance value.
    ///
    /// - Returns: `true` if the value is approximately zero, `false` otherwise
    ///
    /// - SeeAlso: ``isAlmostZero(absoluteTolerance:)``
    package func isAlmostZero() -> Bool {
        isAlmostZero(absoluteTolerance: .ulpOfOne.squareRoot())
    }

    /// Determines whether two floating-point values are approximately equal after considering exponential scaling.
    ///
    /// This method provides a robust comparison of floating-point values that handles special cases like
    /// NaN (Not a Number) and infinity while also considering the scale of the numbers being compared.
    ///
    /// - Important: This comparison handles the following special cases:
    ///   - If either value is NaN, returns false
    ///   - If both values are infinite, performs direct equality comparison
    ///   - If one value is infinite and the other is finite, scales the comparison appropriately
    ///
    /// - Parameters:
    ///   - other: The other floating-point value to compare against
    ///   - tolerance: The acceptable margin of error for the comparison
    ///
    /// - Returns: A boolean value indicating whether the two values are approximately equal
    ///           after considering appropriate scaling
    ///
    /// - Note: This method is particularly useful when comparing numbers that might have
    ///         significantly different scales or when dealing with very large or very small numbers.
    package func rescaledAlmostEqual(to other: Self, tolerance: Self) -> Bool {
        guard !isNaN && !other.isNaN else {
            return false
        }
        guard isInfinite else {
            return other.rescaledAlmostEqual(to: self, tolerance: tolerance)
        }
        guard !other.isInfinite else {
            return self == other
        }
        let rescaledValue = Self(
            sign: sign,
            exponent: Self.greatestFiniteMagnitude.exponent,
            significand: 1
        )
        let otherRescaledValue = Self(
            sign: .plus,
            exponent: -1,
            significand: other
        )
        return rescaledValue.isAlmostEqual(to: otherRescaledValue, tolerance: tolerance)
    }
}

// MARK: - FloatingPoint + Misc [6.5.4]

extension Float {
    package func mix(with other: Float, by t: Double) -> Float {
        (other - self) * Float(t) + self
    }
}

extension CGFloat {
    package func mix(with other: CGFloat, by t: Double) -> CGFloat {
        (other - self) * CGFloat(t) + self
    }
}

extension Double {
    package func mix(with other: Double, by t: Double) -> Double {
        (other - self) * t + self
    }
}

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif

extension Double {
    package var quantized: Double {
        CGFloat(self).quantized
    }
}

extension Float {
    package var quantized: Float {
        #if canImport(Darwin)
        Darwin.round(self * 256.0) / 256.0
        #elseif canImport(Glibc)
        Glibc.round(self * 256.0) / 256.0
        #else
        #error("Unsupported Platform")
        #endif
    }
}

extension CGFloat {
    package var quantized: CGFloat {
        #if canImport(Darwin)
        Darwin.round(self * 256.0) / 256.0
        #elseif canImport(Glibc)
        Glibc.round(self * 256.0) / 256.0
        #else
        #error("Unsupported Platform")
        #endif
    }
}

extension FloatingPoint {
    package func mappingNaN(to value: Self) -> Self {
        isNaN ? value : self
    }
}

extension BinaryFloatingPoint {
    package func ensuringNonzeroValue() -> Self {
        isZero ? Self.leastNonzeroMagnitude : self
    }
}

// MARK: - Duration Conversion [6.5.4]

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Double {
    package init(_ duration: Duration) {
        let (seconds, attoseconds) = duration.components
        self = Double(seconds) + Double(attoseconds) / 1e18
    }
}

package func abs(_ duration: Duration) -> Duration {
    (duration < .zero) ? (.zero - duration) : duration
}

