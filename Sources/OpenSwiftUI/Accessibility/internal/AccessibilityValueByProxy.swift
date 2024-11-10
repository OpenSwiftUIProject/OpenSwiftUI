//
//  AccessibilityValueByProxy.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

protocol AccessibilityValueByProxy: AccessibilityValue {
    associatedtype Base: AccessibilityValue
    var base: Base { get }
}

extension AccessibilityValueByProxy {
    var localizedDescription: String? { base.localizedDescription }
    var displayDescription: String? { base.displayDescription }
    var value: Base.PlatformValue { base.value }
    var minValue: Base.PlatformValue? { base.minValue }
    var maxValue: Base.PlatformValue? { base.maxValue }
    var step: Base.PlatformValue? { base.step }
}
