//
//  Time.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

#if canImport(QuartzCore)
public import QuartzCore
#else
public import Foundation
#endif

/// A type that represents a time value in seconds.
///
/// Use `Time` to represent durations or time intervals within the OpenSwiftUI framework.
/// The structure provides various operators and methods for time-related calculations.
///
/// Example:
/// 
///     let duration = Time(seconds: 2.5)
///     let delay = Time.systemUptime + 1.0
/// 
@_spi(ForOpenSwiftUIOnly)
public struct Time: Equatable, Hashable, Comparable {
    /// The time value in seconds.
    public var seconds: Double

    /// Creates a time value from the specified number of seconds.
    /// - Parameter seconds: The number of seconds.
    public init(seconds: Double) {
        self.seconds = seconds
    }

    /// Creates a time value initialized to zero seconds.
    public init() {
        self.seconds = .zero
    }

    /// A time value of zero seconds.
    public static let zero: Time = Time(seconds: .zero)

    /// A time value representing infinity.
    public static let infinity: Time = Time(seconds: .infinity)
    
    /// The current system uptime as a `Time` value.
    ///
    /// This property provides the time since system boot using platform-specific
    /// implementation.
    @inlinable
    public static var systemUptime: Time {
        // NOTE: ProcessInfo.systemUptime is a general API available on all platforms via Foundation.
        // The implementation result of ProcessInfo().systemUptime and CACurrentMediaTime() is the same on Darwin platforms.
        // Both of them is using `mach_absolute_time` under the hood for Darwin platforms.
        // On non-Darwin platforms, `CACurrentMediaTime` is not available. But `ProcessInfo.systemUptime` is available.
        #if canImport(QuartzCore)
        Time(seconds: CACurrentMediaTime())
        #else
        Time(seconds: ProcessInfo.processInfo.systemUptime)
        #endif
    }

    /// Returns the negation of the specified time value.
    /// - Parameter lhs: A time value.
    /// - Returns: A time value that is the negation of the input.
    @inlinable
    public static prefix func - (lhs: Time) -> Time {
        Time(seconds: -lhs.seconds)
    }
    
    /// Adds a time value and a number of seconds.
    /// - Parameters:
    ///   - lhs: A time value.
    ///   - rhs: The number of seconds to add.
    /// - Returns: A new time value representing the sum.
    @inlinable
    public static func + (lhs: Time, rhs: Double) -> Time {
        Time(seconds: lhs.seconds + rhs)
    }

    /// Adds a number of seconds to a time value.
    /// - Parameters:
    ///   - lhs: The number of seconds to add.
    ///   - rhs: A time value.
    /// - Returns: A new time value representing the sum.
    @inlinable
    public static func + (lhs: Double, rhs: Time) -> Time {
        rhs + lhs
    }

    /// Subtracts a number of seconds from a time value.
    /// - Parameters:
    ///   - lhs: A time value.
    ///   - rhs: The number of seconds to subtract.
    /// - Returns: A new time value representing the difference.
    @inlinable
    public static func - (lhs: Time, rhs: Double) -> Time {
        Time(seconds: lhs.seconds - rhs)
    }

    /// Calculates the time difference between two time values.
    /// - Parameters:
    ///   - lhs: The first time value.
    ///   - rhs: The second time value.
    /// - Returns: The difference in seconds between the two time values.
    @inlinable
    public static func - (lhs: Time, rhs: Time) -> Double {
        lhs.seconds - rhs.seconds
    }

    /// Multiplies a time value by a scalar.
    /// - Parameters:
    ///   - lhs: A time value.
    ///   - rhs: The scalar to multiply by.
    /// - Returns: A new time value representing the product.
    @inlinable
    public static func * (lhs: Time, rhs: Double) -> Time {
        Time(seconds: lhs.seconds * rhs)
    }

    /// Divides a time value by a scalar.
    /// - Parameters:
    ///   - lhs: A time value.
    ///   - rhs: The scalar to divide by.
    /// - Returns: A new time value representing the quotient.
    @inlinable
    public static func / (lhs: Time, rhs: Double) -> Time {
        return Time(seconds: lhs.seconds / rhs)
    }

    /// Adds a number of seconds to a time value, storing the result in the left-hand operand.
    /// - Parameters:
    ///   - lhs: The time value to modify.
    ///   - rhs: The number of seconds to add.
    @inlinable
    public static func += (lhs: inout Time, rhs: Double) {
        lhs = lhs + rhs
    }

    /// Subtracts a number of seconds from a time value, storing the result in the left-hand operand.
    /// - Parameters:
    ///   - lhs: The time value to modify.
    ///   - rhs: The number of seconds to subtract.
    @inlinable
    public static func -= (lhs: inout Time, rhs: Double) {
        lhs = lhs - rhs
    }

    /// Multiplies a time value by a scalar, storing the result in the left-hand operand.
    /// - Parameters:
    ///   - lhs: The time value to modify.
    ///   - rhs: The scalar to multiply by.
    @inlinable
    public static func *= (lhs: inout Time, rhs: Double) {
        lhs = lhs * rhs
    }

    /// Divides a time value by a scalar, storing the result in the left-hand operand.
    /// - Parameters:
    ///   - lhs: The time value to modify.
    ///   - rhs: The scalar to divide by.
    @inlinable
    public static func /= (lhs: inout Time, rhs: Double) {
        lhs = lhs / rhs
    }

    /// Returns a Boolean value indicating whether the first time value is less than the second.
    /// - Parameters:
    ///   - lhs: A time value to compare.
    ///   - rhs: Another time value to compare.
    /// - Returns: `true` if the first value is less than the second value; otherwise, `false`.
    @inlinable
    public static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.seconds < rhs.seconds
    }

    @inlinable
    public static func == (a: Time, b: Time) -> Bool {
        a.seconds == b.seconds
    }

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(seconds)
    }
}

@_spi(ForOpenSwiftUIOnly)
extension Time: Sendable {}
