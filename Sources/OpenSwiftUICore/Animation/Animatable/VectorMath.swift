//
//  VectorMath.swift
//  OpenSwiftUICore
//
//  Audited for 6.4.41
//  Status: Complete

// MARK: - VectorMath

/// Adds the "vector space" numeric operations for any type that
/// conforms to Animatable.
public protocol _VectorMath: Animatable {}

extension _VectorMath {
    @inlinable
    public var magnitude: Double {
        animatableData.magnitudeSquared.squareRoot()
    }

    @inlinable
    public mutating func negate() {
        animatableData = .zero - animatableData
    }

    @inlinable
    public static prefix func - (operand: Self) -> Self {
        var result = operand
        result.negate()
        return result
    }

    @inlinable
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.animatableData += rhs.animatableData
    }

    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs
        result += rhs
        return result
    }

    @inlinable
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.animatableData -= rhs.animatableData
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        var result = lhs
        result -= rhs
        return result
    }

    @inlinable
    public static func *= (lhs: inout Self, rhs: Double) {
        lhs.animatableData.scale(by: rhs)
    }

    @inlinable
    public static func * (lhs: Self, rhs: Double) -> Self {
        var result = lhs
        result *= rhs
        return result
    }

    @inlinable
    public static func /= (lhs: inout Self, rhs: Double) {
        lhs *= 1 / rhs
    }

    @inlinable
    public static func / (lhs: Self, rhs: Double) -> Self {
        var result = lhs
        result /= rhs
        return result
    }
}

extension _VectorMath {
    package mutating func normalize() {
        let magnitudeSquared = animatableData.magnitudeSquared
        if magnitudeSquared != 0 {
            self *= (1.0 / magnitudeSquared)
        }
    }
    
    package func normalized() -> Self {
        var result = self
        result.normalize()
        return result
    }
}
