//
//  Velocity.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _Velocity<Value>: Equatable where Value: Equatable {
    public var valuePerSecond: Value
    
    @inlinable
    public init(valuePerSecond: Value) {
        self.valuePerSecond = valuePerSecond
    }
    
    package func map<T>(_ transform: (Value) -> T) -> _Velocity<T> where T: Equatable {
        _Velocity<T>(valuePerSecond: transform(valuePerSecond))
    }
}

@available(OpenSwiftUI_v1_0, *)
extension _Velocity: Sendable where Value: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension _Velocity: Comparable where Value: Comparable {
    public static func < (lhs: _Velocity<Value>, rhs: _Velocity<Value>) -> Bool {
        lhs.valuePerSecond < rhs.valuePerSecond
    }
}

@available(OpenSwiftUI_v5_0, *)
extension _Velocity: Hashable where Value: Hashable {}

@available(OpenSwiftUI_v1_0, *)
extension _Velocity: AdditiveArithmetic where Value: AdditiveArithmetic {
    @inlinable
    public init() {
        self.init(valuePerSecond: .zero)
    }
    
    @inlinable
    public static var zero: _Velocity<Value> {
        return .init(valuePerSecond: .zero)
    }
    
    @inlinable
    public static func += (lhs: inout _Velocity<Value>, rhs: _Velocity<Value>) {
        lhs.valuePerSecond += rhs.valuePerSecond
    }
    
    @inlinable
    public static func -= (lhs: inout _Velocity<Value>, rhs: _Velocity<Value>) {
        lhs.valuePerSecond -= rhs.valuePerSecond
    }
    
    @inlinable
    public static func + (lhs: _Velocity<Value>, rhs: _Velocity<Value>) -> _Velocity<Value> {
        var r = lhs; r += rhs; return r
    }
    
    @inlinable
    public static func - (lhs: _Velocity<Value>, rhs: _Velocity<Value>) -> _Velocity<Value> {
        var r = lhs; r -= rhs; return r
    }
}

@available(OpenSwiftUI_v1_0, *)
extension _Velocity: VectorArithmetic where Value: VectorArithmetic {
    @inlinable
    public mutating func scale(by rhs: Double) {
        valuePerSecond.scale(by: rhs)
    }
    
    @inlinable
    public var magnitudeSquared: Double {
        valuePerSecond.magnitudeSquared
    }
}
