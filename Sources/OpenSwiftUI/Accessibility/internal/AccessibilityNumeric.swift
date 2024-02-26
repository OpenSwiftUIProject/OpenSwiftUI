//
//  AccessibilityNumber.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation

protocol AccessibilityNumeric {
    var isValidMinValue: Bool { get }
    var isValidMaxValue: Bool { get }
    func asNumber() -> AccessibilityNumber?
}

extension AccessibilityNumeric where Self: FixedWidthInteger {
    var isValidMinValue: Bool {
        // TODO: Add Unit Test and check usage
        if Self.bitWidth == 8 || !Self.isSigned {
            true
        } else {
            self != .min
        }
    }

    var isValidMaxValue: Bool { self != .max }
}

extension Int: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension Int8: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension Int16: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension Int32: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension Int64: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension UInt: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension UInt8: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension UInt16: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension UInt32: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension UInt64: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension AccessibilityNumeric where Self: BinaryFloatingPoint {
    var isValidMinValue: Bool {
        isFinite && self > -Self.greatestFiniteMagnitude
    }

    var isValidMaxValue: Bool {
        isFinite && self < Self.greatestFiniteMagnitude
    }
}

extension Float: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}

extension Double: AccessibilityNumeric {
    func asNumber() -> AccessibilityNumber? { AccessibilityNumber(base: .init(value: self)) }
}
