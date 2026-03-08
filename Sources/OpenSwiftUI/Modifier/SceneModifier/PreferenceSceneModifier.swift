//
//  PreferenceSceneModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - PreferenceWritingModifier + SceneModifier

@available(OpenSwiftUI_v2_0, *)
extension _PreferenceWritingModifier: _SceneModifier {
    @MainActor
    @preconcurrency
    public static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        var inputs = inputs
        inputs.preferences.remove(Key.self)
        var outputs = body(_Graph(), inputs)
        outputs.preferences
            .makePreferenceWriter(
                inputs: inputs.preferences,
                key: Key.self,
                value: modifier.value[offset: { .of(&$0.value) }]
            )
        return outputs
    }
}

@available(OpenSwiftUI_v4_0, *)
extension Scene {
    @inlinable
    @MainActor
    @preconcurrency
    internal func preference<K>(
        key: K.Type = K.self,
        value: K.Value
    ) -> some Scene where K: PreferenceKey {
        modifier(_PreferenceWritingModifier<K>(value: value))
    }
}

// MARK: - _PreferenceTransformModifier + SceneModifier

@available(OpenSwiftUI_v2_0, *)
extension _PreferenceTransformModifier: _SceneModifier {
    @MainActor
    @preconcurrency
    public static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        var outputs = body(_Graph(), inputs)
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: Key.self,
            transform: modifier.value.transform
        )
        return outputs
    }
}

@available(OpenSwiftUI_v4_0, *)
extension Scene {
    @inlinable
    @MainActor
    @preconcurrency
    internal func transformPreference<K>(
        _ key: K.Type = K.self,
        _ callback: @escaping (inout K.Value) -> Void
    ) -> some Scene where K: PreferenceKey {
        modifier(_PreferenceTransformModifier<K>(transform: callback))
    }
}
