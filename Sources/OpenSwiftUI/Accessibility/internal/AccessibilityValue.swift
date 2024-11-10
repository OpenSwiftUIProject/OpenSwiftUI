//
//  AccessibilityValue.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
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
    var minValue: PlatformValue? { nil }
    var maxValue: PlatformValue? { nil }
    var step: PlatformValue? { nil }
}

extension AccessibilityValue where PlatformValue: CustomStringConvertible {
    var localizedDescription: String? { value.description }
    var displayDescription: String? { value.description }
}

extension AccessibilityValue where Self == Self.PlatformValue {
    var value: PlatformValue { self }
}

extension Int: AccessibilityValue {
    typealias PlatformValue = Int
    static var type: AnyAccessibilityValueType { .int }
}

extension Double: AccessibilityValue {
    typealias PlatformValue = Double
    static var type: AnyAccessibilityValueType { .number }
}

extension Bool: AccessibilityValue {
    typealias PlatformValue = Bool
    static var type: AnyAccessibilityValueType { .bool }
}

extension String: AccessibilityValue {
    typealias PlatformValue = String
    static var type: AnyAccessibilityValueType { .string }
}
