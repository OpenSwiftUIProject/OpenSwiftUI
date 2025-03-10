//
//  Animatable.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation
package import OpenGraphShims

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

// MARK: - Animatable + VectorArithmetic

extension Animatable where Self: VectorArithmetic {
    public var animatableData: Self {
        get { self }
        set { self = newValue }
    }
}

// MARK: - Animatable + EmptyAnimatableData

extension Animatable where AnimatableData == EmptyAnimatableData {
    public var animatableData: EmptyAnimatableData {
        @inlinable
        get { EmptyAnimatableData() }
        @inlinable
        set {}
    }

    public static func _makeAnimatable(value: inout _GraphValue<Self>, inputs: _GraphInputs) {}
}

// MARK: - Animateble + Extension

extension Animatable {
    package static func makeAnimatable(value: _GraphValue<Self>, inputs: _GraphInputs) -> Attribute<Self> {
        var value = value
        _makeAnimatable(value: &value, inputs: inputs)
        return value.value
    }
}

extension Attribute where Value: Animatable {
    package func animated(inputs: _GraphInputs) -> Attribute<Value> {
        var value = _GraphValue(self)
        Value._makeAnimatable(value: &value, inputs: inputs)
        return value.value
    }
}

extension Animatable {
    public static func _makeAnimatable(value: inout _GraphValue<Self>, inputs: _GraphInputs) {
        guard MemoryLayout<AnimatableData>.size != 0, !inputs.animationsDisabled else {
            return
        }
        let animatableAttribute = AnimatableAttribute(
            source: value.value,
            phase: inputs.phase,
            time: inputs.time,
            transaction: inputs.transaction,
            environment: inputs.environment
        )
        let animatableValue = _GraphValue(animatableAttribute)
        value = animatableValue
        animatableValue.value.setFlags(.active, mask: .mask)
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
    public static func += (lhs: inout EmptyAnimatableData, rhs: EmptyAnimatableData) {}

    @inlinable
    public static func -= (lhs: inout EmptyAnimatableData, rhs: EmptyAnimatableData) {}

    @inlinable
    public static func + (lhs: EmptyAnimatableData, rhs: EmptyAnimatableData) -> EmptyAnimatableData { .zero }

    @inlinable
    public static func - (lhs: EmptyAnimatableData, rhs: EmptyAnimatableData) -> EmptyAnimatableData { .zero }

    @inlinable
    public mutating func scale(by rhs: Double) {}

    /// The dot-product of this animatable data instance with itself.
    @inlinable
    public var magnitudeSquared: Double { 0 }

    public static func == (a: EmptyAnimatableData, b: EmptyAnimatableData) -> Bool { true }
}

extension Double: Animatable {
    public typealias AnimatableData = Double
}

extension CGFloat: Animatable {
    public typealias AnimatableData = CGFloat
}
