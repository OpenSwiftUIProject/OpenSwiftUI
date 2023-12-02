//
//  AccessibilityBoundedNumber.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/2.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 333660CD735494DA92CEC2878E6C8CC5

import Foundation

struct AccessibilityBoundedNumber {
    var number: AccessibilityNumber
    var lowerBound: AccessibilityNumber?
    var upperBound: AccessibilityNumber?
    var stride: AccessibilityNumber?

    // TODO
    init?<S: Strideable>(for value: S, in range: ClosedRange<S>?, by stride: S.Stride?) {
        return nil
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

extension AccessibilityBoundedNumber: Codable {
    private enum CodingKeys: CodingKey {
        case number
        case lowerBound
        case upperBound
        case stride
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try container.decode(AccessibilityNumber.self, forKey: .number)
        lowerBound = try container.decodeIfPresent(AccessibilityNumber.self, forKey: .lowerBound)
        upperBound = try container.decodeIfPresent(AccessibilityNumber.self, forKey: .upperBound)
        stride = try container.decodeIfPresent(AccessibilityNumber.self, forKey: .lowerBound)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encodeIfPresent(lowerBound, forKey: .lowerBound)
        try container.encodeIfPresent(upperBound, forKey: .upperBound)
        try container.encodeIfPresent(stride, forKey: .stride)
    }
}
