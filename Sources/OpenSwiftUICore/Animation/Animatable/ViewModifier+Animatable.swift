//
//  ViewModifier+Animatable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

extension ViewModifier where Self: Animatable {
    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let animatableViewModifier = makeAnimatable(
            value: modifier,
            inputs: inputs.base
        )
        return makeView(
            modifier: _GraphValue(animatableViewModifier),
            inputs: inputs,
            body: body
        )
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let animatableViewModifier = makeAnimatable(
            value: modifier,
            inputs: inputs.base
        )
        return makeViewList(
            modifier: _GraphValue(animatableViewModifier),
            inputs: inputs,
            body: body
        )
    }
}
