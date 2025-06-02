//
//  Animatable.swift
//  OpenSwiftUICore
//
//  Status: Complete

public import Foundation
package import OpenGraphShims

// MARK: - Animatable [6.4.41]

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

// MARK: - Animateble + Extension [6.4.41]

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

    public static func _makeAnimatable(value _: inout _GraphValue<Self>, inputs _: _GraphInputs) {}
}

extension Animatable {
    package static func makeAnimatable(value: inout _GraphValue<Self>, inputs: _GraphInputs) {
        _makeAnimatable(value: &value, inputs: inputs)
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
        guard MemoryLayout<AnimatableData>.size != 0,
              !inputs.animationsDisabled else {
            return
        }
        let animatable = AnimatableAttribute(
            source: value.value,
            phase: inputs.phase,
            time: inputs.time,
            transaction: inputs.transaction,
            environment: inputs.environment
        )
        let newValue = _GraphValue(animatable)
        value = newValue
        value.value.setFlags(.active, mask: .mask)
    }
}

// MARK: - EmptyAnimatableData [6.4.41]

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

extension Double: Animatable {
    public typealias AnimatableData = Double
}

extension CGFloat: Animatable {
    public typealias AnimatableData = CGFloat
}
