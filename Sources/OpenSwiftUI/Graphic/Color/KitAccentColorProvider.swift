//
//  KitAccentColorProvider.swift
//  OpenSwiftUI
//
//  Audit for 6.5.4
//  Status: Complete

#if os(macOS)

@_silgen_name("NSUserAccentHasHardwareColor")
private func NSUserAccentHasHardwareColor() -> Bool

@_silgen_name("NSUserAccentColorGetHardwareAccentColorName")
private func NSUserAccentColorGetHardwareAccentColorName() -> NSString?

import AppKit
import Foundation
import OpenSwiftUICore

struct MacSystemAccentValueProvider: SystemAccentValueProvider {
    static var defaultValue: SystemAccentValue {
        NSUserAccentHasHardwareColor() ? .hardware : .multicolor
    }

    static func accentColorName(value: SystemAccentValue) -> CoreUISystemCatalogColorName {
        switch value {
        case .red:
            "controlAccentRedColor"
        case .orange:
            "controlAccentOrangeColor"
        case .yellow:
            "controlAccentYellowColor"
        case .green:
            "controlAccentGreenColor"
        case .blue:
            "controlAccentBlueColor"
        case .purple:
            "controlAccentPurpleColor"
        case .pink:
            "controlAccentPinkColor"
        case .graphite:
            "controlAccentNoColor"
        case .multicolor:
            "controlAccentBlueColor"
        case .hardware:
            if let name = NSUserAccentColorGetHardwareAccentColorName() {
                CoreUISystemCatalogColorName(rawValue: name as String)
            } else {
                "controlAccentBlueColor"
            }
        }
    }
}
#endif

struct OpenSwiftUIDefaultAccentColorProvider: DefaultAccentColorProvider {
    static func accentColor(in environment: EnvironmentValues) -> Color {
        environment.systemAccentColor
    }
}
