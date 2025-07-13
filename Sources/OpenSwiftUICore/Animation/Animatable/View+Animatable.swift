//
//  View+Animatable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

extension View where Self: Animatable {
    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let animatableView = makeAnimatable(value: view, inputs: inputs.base)
        return makeView(view: _GraphValue(animatableView), inputs: inputs)
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let animatableView = makeAnimatable(value: view, inputs: inputs.base)
        return makeViewList(view: _GraphValue(animatableView), inputs: inputs)
    }
}
