//
//  GaugeTintOverride.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AA581222F60A6FD6A2BC985F084FB738 (SwiftUI)

import OpenSwiftUICore

// MARK: - View + _gaugeTintOverride

extension View {
    @_spi(Widget)
    @available(OpenSwiftUI_v4_0, *)
    @MainActor
    @preconcurrency
    public func _gaugeTintOverride(
        primaryColor: Color,
        secondaryColor: Color
    ) -> some View {
        environment(\.gaugeTintOverride, (primaryColor, secondaryColor))
    }
}

// MARK: - GaugeTintOverrideKey

private struct GaugeTintOverrideKey: EnvironmentKey {
    static var defaultValue: (Color, Color)? { nil }
}

extension EnvironmentValues {
    var gaugeTintOverride: (Color, Color)? {
        get { self[GaugeTintOverrideKey.self] }
        set { self[GaugeTintOverrideKey.self] = newValue }
    }
}
