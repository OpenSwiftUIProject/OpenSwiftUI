//
//  AnyAccessibilityValue.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 333660CD735494DA92CEC2878E6C8CC5

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

struct AnyAccessibilityValue {
    private var base: AbstractAnyAccessibilityValue

    init(_ base: some Codable & AccessibilityValue) {
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
        case .slider: base = try container.decode(ConcreteBase<AccessibilitySliderValue>.self, forKey: .value)
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

extension AnyAccessibilityValue: AbstractAnyAccessibilityValue {
    var localizedDescription: String? { base.localizedDescription }
    var displayDescription: String? { base.displayDescription }
    var value: Any { base.value }
    var minValue: Any? { base.minValue }
    var maxValue: Any? { base.maxValue }
    var step: Any? { base.step }
    var type: AnyAccessibilityValueType { base.type }
    func `as`<Value>(_ type: Value.Type) -> Value? where Value: AccessibilityValue {
        base.as(type)
    }

    fileprivate func isEqual(to value: AbstractAnyAccessibilityValue) -> Bool {
        base.isEqual(to: value)
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
    func `as`<Value>(_: Value.Type) -> Value? where Value: AccessibilityValue {
        base as? Value
    }

    func isEqual(to value: AbstractAnyAccessibilityValue) -> Bool {
        base == (value as? Self)?.base
    }
}

// MARK: AccessibilityBoundedNumber + Codable

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

// MARK: AccessibilitySliderValue + Codable

extension AccessibilitySliderValue: Codable {
    private enum CodingKeys: CodingKey {
        case base
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        base = try container.decode(AccessibilityBoundedNumber.self, forKey: .base)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(base, forKey: .base)
    }
}
