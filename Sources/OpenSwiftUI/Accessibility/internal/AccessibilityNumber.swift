//
//  AccessibilityNumber.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation

struct AccessibilityNumber {
    var base: NSNumber
}

extension AccessibilityNumber: AccessibilityValue {
    var localizedDescription: String? {
        NumberFormatter.localizedString(from: value, number: .decimal)
    }
    var displayDescription: String? { localizedDescription }
    var value: NSNumber { base }
    var minValue: NSNumber? { nil }
    var maxValue: NSNumber? { nil }
    static var type: AnyAccessibilityValueType { .number }
}

extension AccessibilityNumber: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        base = NSNumber(floatLiteral: value)
    }
}

extension AccessibilityNumber: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        base = NSNumber(integerLiteral: value)
    }
}

extension AccessibilityNumber: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        self.base = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSNumber.self, from: data)!
    }

    func encode(to encoder: Encoder) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: base, requiringSecureCoding: true)
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}
