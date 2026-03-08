//
//  SceneOutputs.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - _SceneOutputs

/// Outputs used for creating attributes of a scene hierarchy.
@available(OpenSwiftUI_v2_0, *)
public struct _SceneOutputs {
    package var preferences: PreferencesOutputs

    package init() {
        preferences = .init()
    }

    package init(preferences: PreferencesOutputs) {
        self.preferences = preferences
    }
}

@available(*, unavailable)
extension _SceneOutputs: Sendable {}
