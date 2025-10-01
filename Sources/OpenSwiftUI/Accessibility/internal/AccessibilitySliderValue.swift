//
//  AccessibilitySliderValue.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

struct AccessibilitySliderValue: AccessibilityValueByProxy {
    var base: AccessibilityBoundedNumber
    static var type: AnyAccessibilityValueType { .slider }
}
