//
//  AccessibilityValue.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/2.
//  Lastest Version: iOS 15.5
//  Status: Complete

import Foundation

protocol AccessibilityValue: Equatable {
    associatedtype PlatformValue: AccessibilityPlatformSafe
    var localizedDescription: String? { get }
    var displayDescription: String? { get }
    var value: PlatformValue { get }
    var minValue: PlatformValue? { get }
    var maxValue: PlatformValue? { get }
    var step: PlatformValue? { get }
    static var type: AnyAccessibilityValueType { get }
}

extension AccessibilityValue {
    var step: NSNumber? { nil }
}
