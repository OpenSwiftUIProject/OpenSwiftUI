//
//  GaugeIndicatorDotTint.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

extension View {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    @available(tvOS, unavailable)
    nonisolated public func gaugeIndicatorDotTint<S>(_ tint: S?) -> some View where S: ShapeStyle {
        environment(\.gaugeIndicatorDotTint, tint.map(AnyShapeStyle.init))
    }
}

// MARK: - GaugeIndicatorDotTintEnvironmentKey

struct GaugeIndicatorDotTintEnvironmentKey: EnvironmentKey {
    static var defaultValue: AnyShapeStyle? { nil }
}

extension EnvironmentValues {
    var gaugeIndicatorDotTint: AnyShapeStyle? {
        get { self[GaugeIndicatorDotTintEnvironmentKey.self] }
        set { self[GaugeIndicatorDotTintEnvironmentKey.self] = newValue }
    }
}
