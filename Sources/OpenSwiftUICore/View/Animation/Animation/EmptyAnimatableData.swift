//
//  EmptyAnimatableData.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// An empty type for animatable data.
///
/// This type is suitable for use as the `animatableData` property of
/// types that do not have any animatable properties.
@frozen
public struct EmptyAnimatableData: VectorArithmetic {
    @inlinable
    public init() {}
    
    @inlinable
    public static var zero: EmptyAnimatableData { .init() }
    
    @inlinable
    public static func += (_: inout EmptyAnimatableData, _: EmptyAnimatableData) {}
    
    @inlinable
    public static func -= (_: inout EmptyAnimatableData, _: EmptyAnimatableData) {}
    
    @inlinable
    public static func + (_: EmptyAnimatableData, _: EmptyAnimatableData) -> EmptyAnimatableData { .zero }

    @inlinable
    public static func - (_: EmptyAnimatableData, _: EmptyAnimatableData) -> EmptyAnimatableData { .zero }

    @inlinable
    public mutating func scale(by _: Double) {}
    
    @inlinable
    public var magnitudeSquared: Double { 0 }

    public static func == (_: EmptyAnimatableData, _: EmptyAnimatableData) -> Bool { true }
}

public import Foundation

extension Double: Animatable {
    public typealias AnimatableData = Swift.Double
}

extension CGFloat: Animatable {
    public typealias AnimatableData = CGFloat
}
