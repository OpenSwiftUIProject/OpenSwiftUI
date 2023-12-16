//
//  AccessibilitySliderValue.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/16.
//  Lastest Version: iOS 15.5
//  Status: Complete

struct AccessibilitySliderValue: AccessibilityValueByProxy {
    var base: AccessibilityBoundedNumber
    static var type: AnyAccessibilityValueType { .slider }
}
