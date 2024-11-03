//
//  VectorArithmetic.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2023
//  Status: Complete

public import Foundation

public protocol VectorArithmetic: AdditiveArithmetic {
    mutating func scale(by rhs: Double)
    var magnitudeSquared: Double { get }
}

extension VectorArithmetic {
    @_alwaysEmitIntoClient
    public func scaled(by rhs: Double) -> Self {
        var result = self
        result.scale(by: rhs)
        return result
    }

    @_alwaysEmitIntoClient
    public mutating func interpolate(towards other: Self, amount: Double) {
        // lhs + (rhs - lhs) * t
        var result = other
        result -= self
        result.scale(by: amount)
        result += self
        self = result
    }

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
    public var magnitudeSquared: Double {
        @_transparent
        get { Double(self * self) }
    }
}

extension Double: VectorArithmetic {
    @_transparent
    public mutating func scale(by rhs: Double) { self *= rhs }
    @_transparent
    public var magnitudeSquared: Double {
        @_transparent
        get { self * self }
    }
}

extension CGFloat: VectorArithmetic {
    @_transparent
    public mutating func scale(by rhs: Double) { self *= CGFloat(rhs) }
    
    @_transparent
    public var magnitudeSquared: Double {
        @_transparent
        get { Double(self * self) }
    }
}
