//
//  Animatable.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/9.
//  Lastest Version: iOS 15.5
//  Status: WIP

public protocol Animatable {
    associatedtype AnimatableData: VectorArithmetic
    var animatableData: AnimatableData { get set }
    static func _makeAnimatable(value: inout _GraphValue<Self>, inputs: _GraphInputs)
}

extension ViewModifier where Self: Animatable {
    public static func _makeView(modifier _: _GraphValue<Self>, inputs _: _ViewInputs, body _: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs {
        .init()
    }

    public static func _makeViewList(modifier _: _GraphValue<Self>, inputs _: _ViewListInputs, body _: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs {
        .init()
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

    public static func _makeAnimatable(value _: inout _GraphValue<Self>, inputs _: _GraphInputs) {}
}

extension Animatable {
    public static func _makeAnimatable(value _: inout _GraphValue<Self>, inputs _: _GraphInputs) {}
}
