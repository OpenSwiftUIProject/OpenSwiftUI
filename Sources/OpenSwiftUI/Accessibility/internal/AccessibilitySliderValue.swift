//
//  AccessibilitySliderValue.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

struct AccessibilitySliderValue: AccessibilityValueByProxy {
    var base: AccessibilityBoundedNumber
    static var type: AnyAccessibilityValueType { .slider }
}
