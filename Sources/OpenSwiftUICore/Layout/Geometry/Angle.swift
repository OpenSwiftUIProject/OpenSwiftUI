//
//  Angle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
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
    @inlinable
    public static func < (lhs: Angle, rhs: Angle) -> Bool {
        lhs.radians < rhs.radians
    }
}

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#endif

package func cos(_ angle: Angle) -> Double {
    cos(angle.radians)
}

package func sin(_ angle: Angle) -> Double {
    sin(angle.radians)
}

package func tan(_ angle: Angle) -> Double {
    tan(angle.radians)
}

extension Angle: Animatable, _VectorMath {
    public typealias AnimatableData = Double
    
    public var animatableData: AnimatableData {
        get { radians * 128.0 }
        set { radians = newValue / 128.0 }
    }

    @inlinable
    public static var zero: Angle { .init() }
}
