//
//  VectorArithmetic.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation

/// A type that can serve as the animatable data of an animatable type.
///
/// `VectorArithmetic` extends the `AdditiveArithmetic` protocol with scalar
/// multiplication and a way to query the vector magnitude of the value. Use
/// this type as the `animatableData` associated type of a type that conforms to
/// the ``Animatable`` protocol.
public protocol VectorArithmetic: AdditiveArithmetic {
    /// Multiplies each component of this value by the given value.
    mutating func scale(by rhs: Double)
    
    /// Returns the dot-product of this vector arithmetic instance with itself.
    var magnitudeSquared: Double { get }
}

extension VectorArithmetic {
    /// Returns a value with each component of this value multiplied by the
    /// given value.
    @_alwaysEmitIntoClient
    public func scaled(by rhs: Double) -> Self {
        var result = self
        result.scale(by: rhs)
        return result
    }

    /// Interpolates this value with `other` by the specified `amount`.
    ///
    /// This is equivalent to `self = self + (other - self) * amount`.
    @_alwaysEmitIntoClient
    public mutating func interpolate(towards other: Self, amount: Double) {
        var result = other
        result -= self
        result.scale(by: amount)
        result += self
        self = result
    }

    /// Returns this value interpolated with `other` by the specified `amount`.
    ///
    /// This result is equivalent to `self + (other - self) * amount`.
    @_alwaysEmitIntoClient
    public func interpolated(towards other: Self, amount: Double) -> Self {
        var result = self
        result.interpolate(towards: other, amount: amount)
        return result
    }
}

extension Float: VectorArithmetic {
    @_transparent
    public mutating func scale(by rhs: Double) { self *= Float(rhs) }
    
    @_transparent
    public var magnitudeSquared: Double { Double(self * self) }
}

extension Double: VectorArithmetic {
    @_transparent
    public mutating func scale(by rhs: Double) { self *= rhs }
    
    @_transparent
    public var magnitudeSquared: Double { self * self }
}

extension CGFloat: VectorArithmetic {
    @_transparent
    public mutating func scale(by rhs: Double) { self *= CGFloat(rhs) }
    
    @_transparent
    public var magnitudeSquared: Double { Double(self * self) }
}

package func mix<T>(_ lhs: T, _ rhs: T, by t: Double) -> T where T: VectorArithmetic {
    var result = rhs
    result -= lhs
    result.scale(by: t)
    result += lhs
    return result
}

extension VectorArithmetic {
    package static var unitScale: Double { 128.0 }
    package static var inverseUnitScale: Swift.Double { 1 / unitScale }
    package mutating func applyUnitScale() { scale(by: Self.unitScale) }
    package mutating func unapplyUnitScale() { scale(by: Self.inverseUnitScale) }
}
