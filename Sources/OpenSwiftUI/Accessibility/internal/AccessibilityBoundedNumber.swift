//
//  AccessibilityBoundedNumber.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/2.
//  Lastest Version: iOS 15.5
//  Status: Complete

import Foundation

struct AccessibilityBoundedNumber {
    var number: AccessibilityNumber
    var lowerBound: AccessibilityNumber?
    var upperBound: AccessibilityNumber?
    var stride: AccessibilityNumber?

    init?<S: Strideable>(for value: S, in range: ClosedRange<S>?, by strideValue: S.Stride?) {
        let clampedValue = range.map { value.clamped(to: $0) }
        let newValue = clampedValue ?? value
        guard let numericValue = newValue as? AccessibilityNumeric,
              let numberValue = numericValue.asNumber() else {
            return nil
        }
        number = numberValue
        if let range {
            lowerBound = range.minimumValue?.asNumber()
            upperBound = range.maximumValue?.asNumber()
        }
        if let strideValue,
           let numericStride = strideValue as? AccessibilityNumeric {
            stride = numericStride.asNumber()
        }
    }
}

extension AccessibilityBoundedNumber: AccessibilityValue {
    // This kind of description logic is very strange
    // But that's how Apple's implementation even on iOS 17 :)
    // eg.
    // For 1.5 and [1.0, 2.0], the accessiblity output would be 150%
    // For 1.5 and [1.3, 2.3], the accessiblity output would be 1.5
    var localizedDescription: String? {
        let range: Double = if let lowerBound, let upperBound {
            upperBound.base.doubleValue - lowerBound.base.doubleValue
        } else {
            .zero
        }
        if abs(range - 100) >= .ulpOfOne {
            let style: NumberFormatter.Style = (abs(range - 1.0) < .ulpOfOne) ? .percent : .decimal
            return NumberFormatter.localizedString(from: number.base, number: style)
        } else {
            return NumberFormatter.localizedString(from: NSNumber(value: number.base.doubleValue / 100), number: .percent)
        }
    }

    var displayDescription: String? {
        localizedDescription
    }

    var value: NSNumber { number.value }
    var minValue: NSNumber? { lowerBound?.value }
    var maxValue: NSNumber? { upperBound?.value }
    static var type: AnyAccessibilityValueType { .boundedNumber }
}
