//
//  EmptyScene.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - _EmptyScene

/// An empty scene.
@available(OpenSwiftUI_v2_0, *)
@frozen
public struct _EmptyScene: PrimitiveScene, Scene {
    @inlinable
    nonisolated public init() {}

    nonisolated public static func _makeScene(scene: _GraphValue<_EmptyScene>, inputs: _SceneInputs) -> _SceneOutputs {
        .init()
    }
}
