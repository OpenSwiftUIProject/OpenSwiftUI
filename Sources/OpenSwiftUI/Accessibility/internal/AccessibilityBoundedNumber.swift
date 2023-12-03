//
//  AccessibilityBoundedNumber.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/2.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 333660CD735494DA92CEC2878E6C8CC5

import Foundation

// MARK: - AbstractAnyAccessibilityValue

private protocol AbstractAnyAccessibilityValue: Codable {
    var localizedDescription: String? { get }
    var displayDescription: String? { get }
    var value: Any { get }
    var minValue: Any? { get }
    var maxValue: Any? { get }
    var step: Any? { get }
    var type: AnyAccessibilityValueType { get }
    func `as`<Value: AccessibilityValue>(_ type: Value.Type) -> Value?
    func isEqual(to value: AbstractAnyAccessibilityValue) -> Bool
}

// MARK: - AnyAccessibilityValue

struct AnyAccessibilityValue/*: AbstractAnyAccessibilityValue*/ {
    private var base: AbstractAnyAccessibilityValue

    init<Value: Codable & AccessibilityValue>(_ base: Value) {
        self.base = ConcreteBase(base: base)
    }
}

extension AnyAccessibilityValue: Equatable {
    static func == (lhs: AnyAccessibilityValue, rhs: AnyAccessibilityValue) -> Bool {
        lhs.base.isEqual(to: rhs.base)
    }
}

extension AnyAccessibilityValue: Codable {
    private enum Keys: CodingKey {
        case type
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try container.decode(AnyAccessibilityValueType.self, forKey: .type)
        switch type {
        case .int: base = try container.decode(ConcreteBase<Int>.self, forKey: .value)
        case .double: base = try container.decode(ConcreteBase<Double>.self, forKey: .value)
        case .bool: base = try container.decode(ConcreteBase<Bool>.self, forKey: .value)
        case .string: base = try container.decode(ConcreteBase<String>.self, forKey: .value)
        case .boundedNumber: base = try container.decode(ConcreteBase<AccessibilityBoundedNumber>.self, forKey: .value)
        case .number: base = try container.decode(ConcreteBase<AccessibilityNumber>.self, forKey: .value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(base.type, forKey: .type)
        try base.encode(to: container.superEncoder(forKey: .value))
    }
}

// MARK: AnyAccessibilityValue.ConcreateBase

extension AnyAccessibilityValue {
    fileprivate struct ConcreteBase<Base> where Base: Codable, Base: AccessibilityValue {
        var base: Base
    }
}

extension AnyAccessibilityValue.ConcreteBase: Codable {}
extension AnyAccessibilityValue.ConcreteBase: Equatable {}
extension AnyAccessibilityValue.ConcreteBase: AbstractAnyAccessibilityValue {
    var localizedDescription: String? { base.localizedDescription }
    var displayDescription: String? { base.displayDescription }
    var value: Any { base.value }
    var minValue: Any? { base.minValue }
    var maxValue: Any? { base.maxValue }
    var step: Any? { base.step }
    var type: AnyAccessibilityValueType { Base.type }
    func `as`<Value>(_ type: Value.Type) -> Value? where Value : AccessibilityValue {
        base as? Value
    }
    func isEqual(to value: AbstractAnyAccessibilityValue) -> Bool {
        base == (value as? Self)?.base
    }
}

// MARK: - AccessibilityBoundedNumber

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
