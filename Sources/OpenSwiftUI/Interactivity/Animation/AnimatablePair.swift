//
//  AnimatablePair.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/9.
//  Lastest Version: iOS 15.5
//  Status: Complete

/// A pair of animatable values, which is itself animatable.
@frozen
public struct AnimatablePair<First, Second>: VectorArithmetic where First: VectorArithmetic, Second: VectorArithmetic {
    public var first: First
    public var second: Second
    
    @inlinable
    public init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }

    @inlinable
    subscript() -> (First, Second) {
        get { (first, second) }
        set { (first, second) = newValue }
    }

    @_transparent
    public static var zero: AnimatablePair<First, Second> {
        @_transparent
        get { .init(First.zero, Second.zero) }
    }

    @_transparent
    public static func += (lhs: inout AnimatablePair<First, Second>, rhs: AnimatablePair<First, Second>) {
        lhs.first += rhs.first
        lhs.second += rhs.second
    }

    @_transparent
    public static func -= (lhs: inout AnimatablePair<First, Second>, rhs: AnimatablePair<First, Second>) {
        lhs.first -= rhs.first
        lhs.second -= rhs.second
    }

    @_transparent
    public static func + (lhs: AnimatablePair<First, Second>, rhs: AnimatablePair<First, Second>) -> AnimatablePair<First, Second> {
        .init(lhs.first + rhs.first, lhs.second + rhs.second)
    }

    @_transparent
    public static func - (lhs: AnimatablePair<First, Second>, rhs: AnimatablePair<First, Second>) -> AnimatablePair<First, Second> {
        .init(lhs.first - rhs.first, lhs.second - rhs.second)
    }

    @_transparent
    public mutating func scale(by rhs: Double) {
        first.scale(by: rhs)
        second.scale(by: rhs)
    }

    @_transparent
    public var magnitudeSquared: Double {
        @_transparent
        get { first.magnitudeSquared + second.magnitudeSquared }
    }

    public static func == (a: AnimatablePair<First, Second>, b: AnimatablePair<First, Second>) -> Bool {
        a.first == b.first && a.second == b.second
    }
}
