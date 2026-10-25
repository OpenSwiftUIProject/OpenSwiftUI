//
//  AllowsGaugeResizing.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1AD4C2EFC8EBEAB722BF937E1CE1684B (SwiftUI)

import OpenSwiftUICore

extension View {
    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    @available(tvOS, unavailable)
    nonisolated public func allowsGaugeResizing(_ enabled: Bool = true) -> some View {
        environment(\.allowsGaugeResizing, enabled)
    }
}

// MARK: - AllowsGaugeResizingKey

private struct AllowsGaugeResizingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var allowsGaugeResizing: Bool {
        get { self[AllowsGaugeResizingKey.self] }
        set { self[AllowsGaugeResizingKey.self] = newValue }
    }
}
