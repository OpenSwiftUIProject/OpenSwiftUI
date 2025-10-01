//
//  Round+Extension.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

public import Foundation
#if canImport(Darwin)
public import CoreGraphics
#endif

// MARK: - FloatingPoint + Round

extension FloatingPoint {
    @inlinable
    package mutating func round(_ rule: FloatingPointRoundingRule, toMultipleOf m: Self) {
        if m == 1 {
            round(rule)
        } else {
            self /= m
            round(rule)
            self *= m
        }
    }
    
    @inlinable
    package mutating func round(toMultipleOf m: Self) {
        round(.toNearestOrAwayFromZero, toMultipleOf: m)
    }
    
    @inlinable
    package func rounded(_ rule: FloatingPointRoundingRule, toMultipleOf m: Self) -> Self {
        var r = self
        r.round(rule, toMultipleOf: m)
        return r
    }
    
    @inlinable
    package func rounded(toMultipleOf m: Self) -> Self {
        rounded(.toNearestOrAwayFromZero, toMultipleOf: m)
    }
    
    @inlinable
    package mutating func roundToNearestOrUp(toMultipleOf m: Self) {
        self += m / 2
        round(.down, toMultipleOf: m)
    }
    
    @inlinable
    package func roundedToNearestOrUp(toMultipleOf m: Self) -> Self {
        var r = self
        r.roundToNearestOrUp(toMultipleOf: m)
        return r
    }
    
    @inlinable
    package func approximates(_ value: Self, epsilon: Self) -> Bool {
        abs(self - value) < epsilon
    }
}

// MARK: - CGPoint + Round

extension CGPoint {
    @inlinable
    package mutating func round(_ rule: FloatingPointRoundingRule, toMultipleOf m: CGFloat) {
        x.round(rule, toMultipleOf: m)
        y.round(rule, toMultipleOf: m)
    }
    
    @inlinable
    package mutating func round(toMultipleOf m: CGFloat) {
        round(.toNearestOrAwayFromZero, toMultipleOf: m)
    }
    
    @inlinable
    package func rounded(_ rule: FloatingPointRoundingRule, toMultipleOf m: CGFloat) -> CGPoint {
        var r = self
        r.round(rule, toMultipleOf: m)
        return r
    }
    
    @inlinable
    package func rounded(toMultipleOf m: CGFloat) -> CGPoint {
        rounded(.toNearestOrAwayFromZero, toMultipleOf: m)
    }
    
    @inlinable
    package mutating func roundToNearestOrUp(toMultipleOf m: CGFloat) {
        x.roundToNearestOrUp(toMultipleOf: m)
        y.roundToNearestOrUp(toMultipleOf: m)
    }
    
    @inlinable
    package func roundedToNearestOrUp(toMultipleOf m: CGFloat) -> CGPoint {
        var r = self
        r.roundToNearestOrUp(toMultipleOf: m)
        return r
    }
}

// MARK: - CGSize + Round

extension CGSize {
    @inlinable
    package mutating func round(_ rule: FloatingPointRoundingRule, toMultipleOf m: CGFloat) {
        width.round(rule, toMultipleOf: m)
        height.round(rule, toMultipleOf: m)
    }
    
    @inlinable
    package mutating func round(toMultipleOf m: CGFloat) {
        round(.toNearestOrAwayFromZero, toMultipleOf: m)
    }
    
    @inlinable
    package func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero, toMultipleOf m: CGFloat) -> CGSize {
        var r = self
        r.round(rule, toMultipleOf: m)
        return r
    }
    
    @inlinable
    package func rounded(toMultipleOf m: CGFloat) -> CGSize {
        rounded(.toNearestOrAwayFromZero, toMultipleOf: m)
    }
}

// MARK: - CGRect + Round

extension CGRect {
    @inlinable
    package mutating func roundCoordinatesToNearestOrUp(toMultipleOf m: CGFloat) {
        self = standardized
        var max = origin + size
        origin.roundToNearestOrUp(toMultipleOf: m)
        max.roundToNearestOrUp(toMultipleOf: m)
        size.width = max.x - x
        size.height = max.y - y
        
        size.round(toMultipleOf: m)
    }
    
    @inlinable
    package func roundedCoordinatesToNearestOrUp(toMultipleOf m: CGFloat) -> CGRect {
        var r = self
        r.roundCoordinatesToNearestOrUp(toMultipleOf: m)
        return r
    }
}

// MARK: - EdgeInsets + Round

extension EdgeInsets {
    @inlinable
    package mutating func round(_ rule: FloatingPointRoundingRule, toMultipleOf m: CGFloat) {
        top.round(rule, toMultipleOf: m)
        leading.round(rule, toMultipleOf: m)
        bottom.round(rule, toMultipleOf: m)
        trailing.round(rule, toMultipleOf: m)
    }
    
    @inlinable
    package mutating func round(toMultipleOf m: CGFloat) {
        round(.toNearestOrAwayFromZero, toMultipleOf: m)
    }
    
    @inlinable
    package func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero, toMultipleOf m: CGFloat) -> EdgeInsets {
        var r = self
        r.round(rule, toMultipleOf: m)
        return r
    }
    
    @inlinable
    package func rounded(toMultipleOf m: CGFloat) -> EdgeInsets {
        rounded(.toNearestOrAwayFromZero, toMultipleOf: m)
    }
    
    @inlinable
    package func approximates(_ other: EdgeInsets, epsilon: CGFloat) -> Bool {
        top.approximates(other.top, epsilon: epsilon)
            && leading.approximates(other.leading, epsilon: epsilon)
            && bottom.approximates(other.bottom, epsilon: epsilon)
            && trailing.approximates(other.trailing, epsilon: epsilon)
    }
}
