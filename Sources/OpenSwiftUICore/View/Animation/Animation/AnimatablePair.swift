//
//  AnimatablePair.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

/// A pair of animatable values, which is itself animatable.
@frozen
public struct AnimatablePair<First, Second>: VectorArithmetic where First: VectorArithmetic, Second: VectorArithmetic {
    /// The first value.
    public var first: First

    /// The second value.
    public var second: Second

    /// Creates an animated pair with the provided values.
    @inlinable
    public init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }

    @inlinable
    package subscript() -> (First, Second) {
        get { (first, second) }
        set { (first, second) = newValue }
    }

    @_transparent
    public static var zero: AnimatablePair<First, Second> {
        .init(First.zero, Second.zero)
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

    /// The dot-product of this animated pair with itself.
    @_transparent
    public var magnitudeSquared: Double {
        first.magnitudeSquared + second.magnitudeSquared
    }
}

extension AnimatablePair: Sendable where First: Sendable, Second: Sendable {}
