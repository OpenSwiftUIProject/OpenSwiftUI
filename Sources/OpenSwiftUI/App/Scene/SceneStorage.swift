//
//  SceneStorage.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: TODO
//  ID: 1700ED20D4EA891B02973E899ABDB425 (SwiftUI)

import OpenSwiftUICore

// MARK: - SceneStorageValues [WIP]

class SceneStorageValues {
    func restoredValue() -> [AnyHashable: Any] {
        _openSwiftUIUnimplementedWarning()
        return [:]
    }
}

// MARK: - EnvironmentValues + sceneStorageValues

private struct SceneStorageValuesKey: EnvironmentKey {
    static let defaultValue: WeakBox<SceneStorageValues>? = nil
}

extension EnvironmentValues {
    var sceneStorageValues: SceneStorageValues? {
        get { self[SceneStorageValuesKey.self]?.base }
        set { self[SceneStorageValuesKey.self] = newValue.map(WeakBox.init) }
    }
}
