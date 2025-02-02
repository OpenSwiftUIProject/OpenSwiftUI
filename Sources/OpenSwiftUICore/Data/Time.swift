//
//  Time.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

#if canImport(QuartzCore)
public import QuartzCore
#endif

@_spi(ForOpenSwiftUIOnly)
public struct Time: Equatable, Hashable, Comparable {
    public var seconds: Double
    public init(seconds: Double) {
        self.seconds = seconds
    }
    public init() {
        self.seconds = .zero
    }
    public static let zero: Time = Time(seconds: .zero)
    public static let infinity: Time = Time(seconds: .infinity)

    #if canImport(QuartzCore)
    @inlinable
    public static var systemUptime: Time {
        Time(seconds: CACurrentMediaTime())
    }
    #endif

    @inlinable
    prefix public static func - (lhs: Time) -> Time {
        Time(seconds: -lhs.seconds)
    }

    @inlinable
    public static func + (lhs: Time, rhs: Double) -> Time {
        Time(seconds: lhs.seconds + rhs)
    }

    @inlinable
    public static func + (lhs: Double, rhs: Time) -> Time {
        rhs + lhs
    }

    @inlinable
    public static func - (lhs: Time, rhs: Double) -> Time {
        Time(seconds: lhs.seconds - rhs)
    }

    @inlinable
    public static func - (lhs: Time, rhs: Time) -> Double {
        lhs.seconds - rhs.seconds
    }
    
    @inlinable
    public static func * (lhs: Time, rhs: Double) -> Time {
        Time(seconds: lhs.seconds * rhs)
    }
    
    @inlinable
    public static func / (lhs: Time, rhs: Double) -> Time {
        return Time(seconds: lhs.seconds / rhs)
    }
    
    @inlinable
    public static func += (lhs: inout Time, rhs: Double) {
        lhs = lhs + rhs
    }

    @inlinable
    public static func -= (lhs: inout Time, rhs: Double) {
        lhs = lhs - rhs
    }

    @inlinable
    public static func *= (lhs: inout Time, rhs: Double) {
        lhs = lhs * rhs
    }
    
    @inlinable
    public static func /= (lhs: inout Time, rhs: Double) {
        lhs = lhs / rhs
    }

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
