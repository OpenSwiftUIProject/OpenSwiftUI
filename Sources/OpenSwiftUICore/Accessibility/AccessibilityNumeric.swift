//
//  AccessibilityNumeric.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - AccessibilityNumeric

package protocol AccessibilityNumeric {
    var isValidMinValue: Bool { get }
    var isValidMaxValue: Bool { get }
    func asNumber() -> AccessibilityNumber?
}

extension AccessibilityNumeric where Self: FixedWidthInteger {
    package var isValidMinValue: Bool {
        guard !isNaN, isFinite else {
            return false
        }
        return !Self.isSigned || Self.bitWidth == 8 || self > .min
    }

    package var isValidMaxValue: Bool {
        !isNaN && isFinite && self < .max
    }
}

extension AccessibilityNumeric where Self: BinaryFloatingPoint {
    package var isValidMinValue: Bool {
        !isNaN && !isSignalingNaN && isFinite && self > -Self.greatestFiniteMagnitude
    }

    package var isValidMaxValue: Bool {
        !isNaN && !isSignalingNaN && isFinite && self < Self.greatestFiniteMagnitude
    }
}

// MARK: - Standard Library + AccessibilityNumeric

extension Int: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension Int8: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension Int16: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension Int32: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension Int64: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension UInt: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension UInt8: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension UInt16: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension UInt32: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension UInt64: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension Double: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

extension Float: AccessibilityNumeric {
    package func asNumber() -> AccessibilityNumber? {
        AccessibilityNumber(NSNumber(value: self))
    }
}

// MARK: - ClosedRange + AccessibilityNumeric

extension ClosedRange where Bound: Strideable {
    package var minimumValue: (any AccessibilityNumeric)? {
        guard let value = lowerBound as? any AccessibilityNumeric, value.isValidMinValue else {
            return nil
        }
        return value
    }

    package var maximumValue: (any AccessibilityNumeric)? {
        guard let value = upperBound as? any AccessibilityNumeric, value.isValidMaxValue else {
            return nil
        }
        return value
    }
}

// MARK: - AccessibilityValueStorage + Numeric

extension AccessibilityValueStorage {
    @_disfavoredOverload
    package init<V>(
        _ value: V,
        from lowerBound: V? = nil,
        to upperBound: V? = nil,
        description: Text?
    ) where V: Numeric {
        guard let number = (value as? any AccessibilityNumeric)?.asNumber() else {
            self.init("\(value)", description: description)
            return
        }
        if lowerBound == nil, upperBound == nil {
            self.init(number, description: description)
        } else {
            self.init(
                AccessibilityBoundedNumber(
                    value: number,
                    minValue: (lowerBound as? any AccessibilityNumeric)?.asNumber(),
                    maxValue: (upperBound as? any AccessibilityNumeric)?.asNumber()
                ),
                description: description
            )
        }
    }
}
