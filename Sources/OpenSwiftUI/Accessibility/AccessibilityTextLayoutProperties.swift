//
//  AccessibilityTextLayoutProperties.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(Private)
import OpenSwiftUICore

// MARK: - AccessibilityTextLayoutProperties

enum AccessibilityTextLayoutProperties {
    case custom(TextLayoutProperties)
    case automatic
}
