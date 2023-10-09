//
//  ColorSchemeKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/9.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 387C753F3FFD2899BCB77252214CFCC6

import Foundation

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
