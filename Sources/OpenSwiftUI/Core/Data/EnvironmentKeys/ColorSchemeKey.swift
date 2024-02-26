//
//  ColorSchemeKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 387C753F3FFD2899BCB77252214CFCC6

//private struct SystemColorSchemeModifier {}

private struct ColorSchemeKey: EnvironmentKey {
    static var defaultValue: ColorScheme = .light
}

extension EnvironmentValues {
    @inline(__always)
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
