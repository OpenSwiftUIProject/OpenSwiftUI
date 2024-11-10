//
//  ColorScheme.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 387C753F3FFD2899BCB77252214CFCC6

public enum ColorScheme: Hashable, CaseIterable {
    case light
    case dark
}

//private struct SystemColorSchemeModifier {}

private struct ColorSchemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme = .light
}

extension EnvironmentValues {
    public var colorScheme: ColorScheme {
        get { self[ColorSchemeKey.self] }
        set { self[ColorSchemeKey.self] = newValue }
    }
}

//private struct SystemColorSchemeKey: EnvironmentKey {
//    static var defaultValue: Bool { true }
//}
//
//private struct ExplicitPreferredColorSchemeKey: EnvironmentKey {
//    static var defaultValue: Bool { true }
//}
//
//private struct ColorSchemeContrastKey: EnvironmentKey {
//    static var defaultValue: Bool { true }
//}
