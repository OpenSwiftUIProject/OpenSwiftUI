//
//  IdentifiedPreference.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BADADABA7CFDAF5EFDACD96BEDF6E8F3 (SwiftUI)

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - IdentifiedPreferenceTransformModifier

struct IdentifiedPreferenceTransformModifier<Key>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Key: PreferenceKey {
    var transform: (inout Key.Value, ViewIdentity) -> Void

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let value = modifier.value
        let phase = inputs.viewPhase
        var outputs = body(_Graph(), inputs)
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: Key.self,
            transform: Attribute(
                Transform(
                    modifier: value,
                    phase: phase,
                    helper: .init(id: .invalid, resetSeed: 0)
                )
            )
        )
        return outputs
    }

    // MARK: - IdentifiedPreferenceTransformModifier.Transform

    private struct Transform: StatefulRule, AsyncAttribute {
        @Attribute var modifier: IdentifiedPreferenceTransformModifier
        @Attribute var phase: ViewPhase
        var helper: ViewIdentity.Tracker

        typealias Value = (inout Key.Value) -> Void

        mutating func updateValue() {
            let (id, _) = helper.update(for: phase)
            let transform = modifier.transform
            value = { value in
                transform(&value, id)
            }
        }
    }
}
