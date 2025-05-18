//
//  Animatable.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Blocked by Graph

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
