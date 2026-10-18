//
//  AccessibilityRole.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import libAccessibilityPrivate
import OpenSwiftUI_SPI

// MARK: - AccessibilityRole

struct AccessibilityRole {
    var resolved: Resolved

    #if !canImport(Darwin)
    struct Resolved {
        var traits: AXOpenSwiftUITraits
        var automationType: AXAutomationType?
    }
    #endif
}
