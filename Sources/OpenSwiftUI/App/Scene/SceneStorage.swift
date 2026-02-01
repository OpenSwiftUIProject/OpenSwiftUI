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
    private var encodedValues: [AnyHashable: Any]
    private var locations: [String: AnyEntry] = [:]
    var encodedValueCount: Int = 0
    weak var associatedHost: ViewRendererHost? = nil

    init(_ value: [AnyHashable: Any]) {
        encodedValues = value
    }

    func restoredValue() -> [AnyHashable: Any] {
        _openSwiftUIUnimplementedWarning()
        return [:]
    }

    private class AnyEntry {}

    private class Entry {}
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
