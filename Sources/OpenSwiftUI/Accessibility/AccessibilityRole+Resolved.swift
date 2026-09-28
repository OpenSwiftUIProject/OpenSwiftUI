//
//  AccessibilityRole+Resolved.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUI_SPI
#if os(macOS)
import AppKit
#else
import libAccessibilityPrivate
#endif

// MARK: - AccessibilityRole.Resolved

extension AccessibilityRole {
    struct Resolved {
        #if os(macOS)
        var role: NSAccessibility.Role?
        var subrole: NSAccessibility.Subrole?
        var traits: AXOpenSwiftUITraits?
        #else
        var traits: AXOpenSwiftUITraits
        var automationType: AXAutomationType?
        #endif
    }
}
