//
//  AppearanceActionSceneModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims
package import OpenSwiftUICore

@available(OpenSwiftUI_v4_0, *)
extension _AppearanceActionModifier: PrimitiveSceneModifier {
    @MainActor
    @preconcurrency
    public static func _makeScene(
        modifier: _GraphValue<_AppearanceActionModifier>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        let effect = AppearanceEffect(
            modifier: modifier.value,
            phase: inputs.base.phase
        )
        let attribute = Attribute(effect)
        attribute.flags = [.transactional, .removable]
        return body(_Graph(), inputs)
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension Scene {
    @_alwaysEmitIntoClient
    nonisolated public func onAppear(perform action: (() -> Void)? = nil) -> some Scene {
        modifier(_AppearanceActionModifier(appear: action, disappear: nil))
    }

    @_alwaysEmitIntoClient
    nonisolated public func onDisappear(perform action: (() -> Void)? = nil) -> some Scene {
        modifier(_AppearanceActionModifier(appear: nil, disappear: action))
    }
}
