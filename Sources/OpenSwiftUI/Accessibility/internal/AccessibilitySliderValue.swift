//
//  AccessibilitySliderValue.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

struct AccessibilitySliderValue: AccessibilityValueByProxy {
    var base: AccessibilityBoundedNumber
    static var type: AnyAccessibilityValueType { .slider }
}
