//
//  Animatable.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Blocked by Graph [TODO: doc]

// MARK: - Animatable

/// A type that describes how to animate a property of a view.
public protocol Animatable {
    /// The type defining the data to animate.
    associatedtype AnimatableData: VectorArithmetic
    
    /// The data to animate.
    var animatableData: AnimatableData { get set }
    
    /// Replaces `value` with an animated version of the value, using
    /// `inputs`.
    static func _makeAnimatable(value: inout _GraphValue<Self>, inputs: _GraphInputs)
}

// MARK: - Animateble + Extension

extension Animatable {
    public static func _makeAnimatable(value _: inout _GraphValue<Self>, inputs _: _GraphInputs) {
        // TODO
    }
}

extension Animatable where Self: VectorArithmetic {
    public var animatableData: Self {
        get { self }
        set { self = newValue }
    }
}

extension Animatable where AnimatableData == EmptyAnimatableData {
    public var animatableData: EmptyAnimatableData {
        @inlinable
        get { EmptyAnimatableData() }
        @inlinable
        set {}
    }

    public static func _makeAnimatable(value _: inout _GraphValue<Self>, inputs _: _GraphInputs) {
        // TODO
    }
}

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
