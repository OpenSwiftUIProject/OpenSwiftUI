//
//  Time.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if canImport(QuartzCore)
import QuartzCore
#endif

struct Time: Comparable, Hashable {
    var seconds : Double

    static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.seconds < rhs.seconds
    }

    static let zero = Time(seconds: .zero)
    static let infinity = Time(seconds: .infinity)

    #if canImport(QuartzCore)
    @inline(__always)
    static var now: Time {
        Time(seconds: CACurrentMediaTime())
    }
    #endif
    
    @inline(__always)
    private init(seconds: Double) {
        self.seconds = seconds
    }
    
    @inline(__always)
    static func seconds(_ value: Double) -> Time {
        Time(seconds: value)
    }
    
    @inline(__always)
    static func seconds(_ value: Int) -> Time {
        Time(seconds: Double(value))
    }
    
    @inline(__always)
    static func microseconds(_ value: Double) -> Time {
        Time(seconds: value * 1e-3)
    }
    
    @inline(__always)
    static func milliseconds(_ value: Double) -> Time {
        Time(seconds: value * 1e-6)
    }
    
    @inline(__always)
    static func nanoseconds(_ value: Double) -> Time {
        Time(seconds: value * 1e-9)
    }
    
    @inline(__always)
    static func += (lhs: inout Time, rhs: Time) {
        lhs.seconds = lhs.seconds + rhs.seconds
    }

    @inline(__always)
    static func + (lhs: Time, rhs: Time) -> Time {
        Time(seconds: lhs.seconds + rhs.seconds)
    }
    
    @inline(__always)
    static func -= (lhs: inout Time, rhs: Time) {
        lhs.seconds = lhs.seconds - rhs.seconds
    }

    @inline(__always)
    static func - (lhs: Time, rhs: Time) -> Time {
        Time(seconds: lhs.seconds - rhs.seconds)
    }
    
    @inline(__always)
    mutating func advancing(by seconds: Double) {
        self.seconds += seconds
    }
    
    @inline(__always)
    func advanced(by seconds: Double) -> Time {
        Time(seconds: self.seconds + seconds)
    }
    
    @inline(__always)
    func distance(to other: Time) -> Double {
        seconds.distance(to: other.seconds)
    }
}
