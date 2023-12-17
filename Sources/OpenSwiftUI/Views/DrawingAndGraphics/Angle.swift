//
//  Angle.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/9.
//  Lastest Version: iOS 15.5
//  Status: Complete

/// A geometric angle whose value you access in either radians or degrees.
@frozen
public struct Angle {
    public var radians: Double
    
    @inlinable
    public var degrees: Double {
        get { radians * (180.0 / .pi) }
        set { radians = newValue * (.pi / 180.0) }
    }

    @inlinable
    public init() {
        self.init(radians: 0.0)
    }

    @inlinable
    public init(radians: Double) {
        self.radians = radians
    }

    @inlinable
    public init(degrees: Double) {
        self.init(radians: degrees * (.pi / 180.0))
    }

    @inlinable
    public static func radians(_ radians: Double) -> Angle {
        Angle(radians: radians)
    }

    @inlinable
    public static func degrees(_ degrees: Double) -> Angle {
        Angle(degrees: degrees)
    }
}

extension Angle: Hashable, Comparable {
    public static func < (lhs: Angle, rhs: Angle) -> Bool {
        lhs.radians < rhs.radians
    }
}

extension Angle: _VectorMath {
    public var animatableData: Double {
        get { radians * 128.0 }
        set { radians = newValue / 128.0 }
    }

    @inlinable
    public static var zero: Angle { .init() }
}
