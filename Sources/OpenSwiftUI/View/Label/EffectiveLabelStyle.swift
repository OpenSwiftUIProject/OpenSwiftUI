//
//  EffectiveLabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: DA6C79D47249EAD9161892FAEFF06389 (SwiftUI)

public import OpenSwiftUICore

// MARK: - EffectiveLabelStyle

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
public struct EffectiveLabelStyle: Equatable {
    var baseType: ObjectIdentifier

    public static var titleAndIcon: EffectiveLabelStyle {
        EffectiveLabelStyle(baseType: ObjectIdentifier(TitleAndIconLabelStyle.self))
    }

    public static var titleOnly: EffectiveLabelStyle {
        EffectiveLabelStyle(baseType: ObjectIdentifier(TitleOnlyLabelStyle.self))
    }

    public static var iconOnly: EffectiveLabelStyle {
        EffectiveLabelStyle(baseType: ObjectIdentifier(IconOnlyLabelStyle.self))
    }
}

@_spi(Private)
@available(*, unavailable)
extension EffectiveLabelStyle: Sendable {}

// MARK: - EnvironmentValues + EffectiveLabelStyle

extension EnvironmentValues {
    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public var effectiveLabelStyle: EffectiveLabelStyle? {
        get { self[EffectiveLabelStyleKey.self] }
        set { self[EffectiveLabelStyleKey.self] = newValue }
    }
}

// MARK: - EffectiveLabelStyleKey

private struct EffectiveLabelStyleKey: EnvironmentKey {
    static var defaultValue: EffectiveLabelStyle? { nil }
}
