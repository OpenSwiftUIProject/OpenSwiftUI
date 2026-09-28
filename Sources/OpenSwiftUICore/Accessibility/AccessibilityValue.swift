//
//  AccessibilityValue.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9CDC06258A415BCDFCA123F203571FE0 (SwiftUICore)

package import Foundation

// MARK: - AnyAccessibilityValueType

package enum AnyAccessibilityValueType: UInt, Codable {
    case int
    case double
    case bool
    case string
    case disclosure
    case toggle
    case slider
    case stepper
    case progress
    case boundedNumber
    case number
    case empty
}

// MARK: - AccessibilityValue

package protocol AccessibilityValue: Equatable {
    associatedtype PlatformValue: AccessibilityPlatformSafe = Self

    var localizedDescription: String? { get }
    var displayDescription: String? { get }
    var value: PlatformValue { get }
    var minValue: PlatformValue? { get }
    var maxValue: PlatformValue? { get }
    var step: PlatformValue? { get }
    static var type: AnyAccessibilityValueType { get }
}

extension AccessibilityValue {
    package var localizedDescription: String? { nil }
    package var minValue: PlatformValue? { nil }
    package var maxValue: PlatformValue? { nil }
    package var step: PlatformValue? { nil }
    package var displayDescription: String? { nil }
}

extension AccessibilityValue where PlatformValue: CustomStringConvertible {
    package var displayDescription: String? { value.description }
    package var localizedDescription: String? { value.description }
}

extension AccessibilityValue where Self == PlatformValue {
    package var value: Self { self }
}

extension AccessibilityValue where Self: RawRepresentable {
    package var value: RawValue { rawValue }
}

extension AccessibilityValue where PlatformValue == NSNumber {
    package var localizedDescription: String? { localizedNumericDescription }
    package var displayDescription: String? { localizedDescription }

    package var localizedNumericDescription: String? {
        let width = minValue.map { minValue in
            maxValue.map { $0.doubleValue - minValue.doubleValue } ?? 0
        } ?? 0
        var number = value
        let style: NumberFormatter.Style
        if abs(width - 100) < Double.ulpOfOne {
            number = (number.doubleValue / 100) as NSNumber
            style = .percent
        } else if abs(width - 1) < Double.ulpOfOne {
            style = .percent
        } else {
            style = .decimal
        }
        return NumberFormatter.localizedString(from: number, number: style)
    }
}

// MARK: - AccessibilityValueByProxy

package protocol AccessibilityValueByProxy: AccessibilityValue {
    associatedtype Base: AccessibilityValue
    var base: Base { get }
}

extension AccessibilityValueByProxy {
    package var localizedDescription: String? { base.localizedDescription }
    package var displayDescription: String? { base.displayDescription }
    package var value: Base.PlatformValue { base.value }
    package var minValue: Base.PlatformValue? { base.minValue }
    package var maxValue: Base.PlatformValue? { base.maxValue }
    package var step: Base.PlatformValue? { base.step }
}

// MARK: - Standard Library + AccessibilityValue

extension Int: AccessibilityValue {
    package static var type: AnyAccessibilityValueType { .int }
}

extension Double: AccessibilityValue {
    package static var type: AnyAccessibilityValueType { .double }
}

extension Bool: AccessibilityValue {
    package static var type: AnyAccessibilityValueType { .bool }
}

extension String: AccessibilityValue {
    package static var type: AnyAccessibilityValueType { .string }
}

// MARK: - AccessibilityEmptyValue

package struct AccessibilityEmptyValue: AccessibilityValue, Codable {
    package static var type: AnyAccessibilityValueType { .empty }

    package var value: Never? { nil }

    package init() {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - AccessibilityBoundedNumber

package struct AccessibilityBoundedNumber: AccessibilityValue, Codable {
    package static var type: AnyAccessibilityValueType { .boundedNumber }

    package var number: AccessibilityNumber
    package var lowerBound: AccessibilityNumber?
    package var upperBound: AccessibilityNumber?
    package var stride: AccessibilityNumber?

    package init(
        value: AccessibilityNumber,
        minValue: AccessibilityNumber? = nil,
        maxValue: AccessibilityNumber? = nil,
        step: AccessibilityNumber? = nil
    ) {
        number = value
        lowerBound = minValue
        upperBound = maxValue
        stride = step
    }

    package var value: NSNumber { number.value }
    package var minValue: NSNumber? { lowerBound?.value }
    package var maxValue: NSNumber? { upperBound?.value }
    package var step: NSNumber? { stride?.value }
}

extension AccessibilityBoundedNumber {
    package init?<T>(for value: T, in range: ClosedRange<T>? = nil, by step: T.Stride? = nil) where T: Strideable {
        let value = range.map { value.clamped(to: $0) } ?? value
        guard let number = (value as? any AccessibilityNumeric)?.asNumber() else {
            return nil
        }
        self.init(
            value: number,
            minValue: range?.minimumValue?.asNumber(),
            maxValue: range?.maximumValue?.asNumber(),
            step: (step as? any AccessibilityNumeric)?.asNumber()
        )
    }
}

// MARK: - AccessibilityDisclosureValue

package enum AccessibilityDisclosureValue: UInt8, AccessibilityValue {
    case collapsed
    case expanded

    package init(_ isDisclosed: Bool) {
        self = isDisclosed ? .expanded : .collapsed
    }

    package static var type: AnyAccessibilityValueType { .disclosure }

    package var value: Bool? {
        isUIKitBased() ? uiKitValue : appKitValue
    }

    package var uiKitValue: Bool? { nil }
    package var appKitValue: Bool? { platformDisclosureValue }
    package var platformDisclosureValue: Bool { self == .expanded }
    package var displayDescription: String? { nil }
}

// MARK: - AccessibilityToggleValue

package struct AccessibilityToggleValue: AccessibilityValue, Codable {
    package static var type: AnyAccessibilityValueType { .toggle }

    package enum State: UInt8, Codable {
        case off
        case on
        case mixed
    }

    package var state: State

    package init(_ isOn: ToggleState) {
        switch isOn {
        case .on: state = .on
        case .off: state = .off
        case .mixed: state = .mixed
        }
    }

    package var value: Int {
        isUIKitBased() ? uiKitValue : appKitValue
    }

    package var uiKitValue: Int { Int(state.rawValue) }

    package var appKitValue: Int {
        switch state {
        case .off: 0
        case .on: 1
        case .mixed: -1
        }
    }

    package var displayDescription: String? {
        switch state {
        case .off: "false"
        case .on: "true"
        case .mixed: "mixed"
        }
    }
}

// MARK: - AccessibilityStepperValue

package struct AccessibilityStepperValue: AccessibilityValueByProxy, Codable {
    package static var type: AnyAccessibilityValueType { .stepper }

    package var base: AccessibilityBoundedNumber

    package init(_ base: AccessibilityBoundedNumber) {
        self.base = base
    }

    package init(value: AccessibilityNumber, minValue: AccessibilityNumber? = nil, maxValue: AccessibilityNumber? = nil) {
        base = AccessibilityBoundedNumber(value: value, minValue: minValue, maxValue: maxValue)
    }

    package var localizedDescription: String? {
        NumberFormatter.localizedString(from: value, number: .decimal)
    }

    package var displayDescription: String? { localizedDescription }
}

// MARK: - AccessibilitySliderValue

package struct AccessibilitySliderValue: AccessibilityValueByProxy, Codable {
    package static var type: AnyAccessibilityValueType { .slider }

    package var base: AccessibilityBoundedNumber

    package init(_ base: AccessibilityBoundedNumber) {
        self.base = base
    }

    package init(value: AccessibilityNumber, minValue: AccessibilityNumber? = nil, maxValue: AccessibilityNumber? = nil) {
        base = AccessibilityBoundedNumber(value: value, minValue: minValue, maxValue: maxValue)
    }

    package init<V>(value: V, minValue: V? = nil, maxValue: V? = nil) where V: BinaryFloatingPoint {
        self.init(
            value: AccessibilityNumber(floatingPoint: value),
            minValue: minValue != nil ? AccessibilityNumber(floatingPoint: minValue!) : nil,
            maxValue: maxValue != nil ? AccessibilityNumber(floatingPoint: maxValue!) : nil
        )
    }
}

// MARK: - AccessibilityProgressValue

package struct AccessibilityProgressValue: AccessibilityValue, Codable {
    package static var type: AnyAccessibilityValueType { .progress }

    package var percent: Double?

    package init(percent: Double?) {
        self.percent = percent
    }

    package var value: NSNumber { NSNumber(floatLiteral: percent ?? 0) }
    package var minValue: NSNumber? { percent == nil ? nil : 0 }
    package var maxValue: NSNumber? { percent == nil ? nil : 1 }
    package var localizedDescription: String? { percent == nil ? nil : localizedNumericDescription }
    package var displayDescription: String? { localizedDescription }
}

// MARK: - AccessibilityNumber

package struct AccessibilityNumber: AccessibilityValue, Codable {
    package enum AccessibilityNumberArchiveError: Error {
        case unarchiveFailed
    }

    package static var type: AnyAccessibilityValueType { .number }

    private var base: NSNumber

    package init(_ base: NSNumber) {
        self.base = base
    }

    package var value: NSNumber { base }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        guard let base = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSNumber.self, from: data) else {
            throw AccessibilityNumberArchiveError.unarchiveFailed
        }
        self.base = base
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(withRootObject: base, requiringSecureCoding: true)
        try container.encode(data)
    }
}

extension AccessibilityNumber: ExpressibleByIntegerLiteral {
    package typealias IntegerLiteralType = NSNumber.IntegerLiteralType

    package init(integerLiteral value: IntegerLiteralType) {
        base = NSNumber(integerLiteral: value)
    }
}

extension AccessibilityNumber: ExpressibleByFloatLiteral {
    package typealias FloatLiteralType = NSNumber.FloatLiteralType

    package init(floatLiteral value: FloatLiteralType) {
        base = NSNumber(floatLiteral: value)
    }

    package init<V>(floatingPoint value: V) where V: BinaryFloatingPoint {
        base = NSNumber(floatLiteral: Double(value))
    }
}

// MARK: - ProxyCodable + AccessibilityValue

extension ProxyCodable: AccessibilityValue where Value: AccessibilityValue {
    package typealias PlatformValue = Value.PlatformValue

    package var localizedDescription: String? {
        wrappedValue.localizedDescription
    }

    package var displayDescription: String? {
        wrappedValue.displayDescription
    }

    package var value: PlatformValue {
        wrappedValue.value
    }

    package var minValue: PlatformValue? {
        wrappedValue.minValue
    }

    package var maxValue: PlatformValue? {
        wrappedValue.maxValue
    }

    package var step: PlatformValue? {
        wrappedValue.step
    }

    package static var type: AnyAccessibilityValueType {
        Value.type
    }
}

// MARK: - AbstractAnyAccessibilityValue

private protocol AbstractAnyAccessibilityValue: Codable {
    var localizedDescription: String? { get }
    var displayDescription: String? { get }
    var value: Any { get }
    var minValue: Any? { get }
    var maxValue: Any? { get }
    var step: Any? { get }
    var type: AnyAccessibilityValueType { get }
    func `as`<T>(_ type: T.Type) -> T? where T: AccessibilityValue
    func isEqual(to other: any AbstractAnyAccessibilityValue) -> Bool
}

// MARK: - AnyAccessibilityValue

package struct AnyAccessibilityValue: Equatable {
    private var base: any AbstractAnyAccessibilityValue

    package init<V>(_ value: V) where V: AccessibilityValue, V: Codable {
        base = ConcreteBase(base: value)
    }

    package var localizedDescription: String? {
        base.localizedDescription
    }

    package var displayDescription: String? {
        base.displayDescription
    }

    package var value: Any {
        base.value
    }

    package var minValue: Any? {
        base.minValue
    }

    package var maxValue: Any? {
        base.maxValue
    }

    package var step: Any? {
        base.step
    }

    package var type: AnyAccessibilityValueType {
        base.type
    }

    package func `as`<T>(_ type: T.Type) -> T? where T: AccessibilityValue {
        base.as(type)
    }

    package static func == (lhs: AnyAccessibilityValue, rhs: AnyAccessibilityValue) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

extension AnyAccessibilityValue: AbstractAnyAccessibilityValue {
    fileprivate func isEqual(to other: any AbstractAnyAccessibilityValue) -> Bool {
        guard let other = other as? AnyAccessibilityValue else {
            return false
        }
        return base.isEqual(to: other.base)
    }
}

extension AnyAccessibilityValue {
    private struct ConcreteBase<Value>: AbstractAnyAccessibilityValue, Equatable where Value: AccessibilityValue, Value: Codable {
        var base: Value

        var localizedDescription: String? { base.localizedDescription }
        var displayDescription: String? { base.displayDescription }
        var value: Any { base.value }
        var minValue: Any? { base.minValue }
        var maxValue: Any? { base.maxValue }
        var step: Any? { base.step }
        var type: AnyAccessibilityValueType { Value.type }

        func `as`<T>(_ type: T.Type) -> T? where T: AccessibilityValue {
            base as? T
        }

        func isEqual(to other: any AbstractAnyAccessibilityValue) -> Bool {
            (other as? Self)?.base == base
        }
    }
}

// MARK: - AccessibilityValueStorage

package struct AccessibilityValueStorage: Equatable {
    package enum Description: Equatable {
        case text([Text])
        case empty

        package var text: [Text] {
            switch self {
            case let .text(texts): texts
            case .empty: []
            }
        }
    }

    package fileprivate(set) var value: AnyAccessibilityValue? = nil

    package private(set) var description: Description

    package init<V>(_ value: V? = nil, description: Text? = nil) where V: AccessibilityValue, V: CodableByProxy {
        self.value = value.map { AnyAccessibilityValue(ProxyCodable($0)) }
        self.description = .text(description.map { [$0] } ?? [])
    }

    package init<V>(_ value: V? = nil, description: Text? = nil) where V: AccessibilityValue, V: Codable {
        self.value = value.map { AnyAccessibilityValue($0) }
        self.description = .text(description.map { [$0] } ?? [])
    }

    package init<V>(_ value: V, description: Description) where V: AccessibilityValue, V: Codable {
        self.value = AnyAccessibilityValue(value)
        self.description = description
    }

    package init(description: Text? = nil) {
        self.description = .text(description.map { [$0] } ?? [])
    }

    package init(descriptions: [Text]) {
        description = .text(descriptions)
    }

    package var valueDescription: [Text] {
        get {
            if case let .text(texts) = description, !texts.isEmpty {
                return texts
            }
            guard let description = value?.localizedDescription else {
                return []
            }
            return [Text(verbatim: description)]
        }
        set {
            description = .text(newValue)
        }
    }
}

// MARK: - AccessibilityValueStorage + Platform Values

extension AccessibilityValueStorage {
    package var platformMinValue: Any? {
        value?.minValue
    }

    package var platformMaxValue: Any? {
        value?.maxValue
    }

    package var platformNumberValue: NSNumber? {
        value?.value as? NSNumber
    }

    package var isBounded: Bool {
        value?.minValue != nil || value?.maxValue != nil
    }

    package var hasAllowedValues: Bool {
        value?.step != nil && value?.minValue != nil && value?.maxValue != nil
    }

    package var platformAllowedValues: [NSNumber]? {
        guard let step = value?.step as? NSNumber,
              let minValue = value?.minValue as? NSNumber,
              let maxValue = value?.maxValue as? NSNumber else {
            return nil
        }
        return stride(
            from: minValue.decimalValue,
            through: maxValue.decimalValue,
            by: step.decimalValue
        ).map { $0 as NSNumber }
    }
}

// MARK: - AccessibilityValueStorage + AccessibilityCombinable

extension AccessibilityValueStorage: AccessibilityCombinable {
    @discardableResult
    package mutating func merge(with child: AccessibilityValueStorage) -> Bool {
        var changed = false
        if value == nil, let childValue = child.value {
            value = childValue
            changed = true
        }
        if case let .text(texts) = description, texts.isEmpty,
           case let .text(childTexts) = child.description, !childTexts.isEmpty {
            description = child.description
            changed = true
        }
        return changed
    }
}

extension AccessibilityDisclosureValue: Codable {}

// MARK: - AnyAccessibilityValue + Codable

extension AnyAccessibilityValue: Codable {
    private enum Keys: String, CodingKey {
        case type
        case value
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        switch try container.decode(AnyAccessibilityValueType.self, forKey: .type) {
        case .int:
            base = try container.decode(ConcreteBase<Int>.self, forKey: .value)
        case .double:
            base = try container.decode(ConcreteBase<Double>.self, forKey: .value)
        case .bool:
            base = try container.decode(ConcreteBase<Bool>.self, forKey: .value)
        case .string:
            base = try container.decode(ConcreteBase<String>.self, forKey: .value)
        case .disclosure:
            base = try container.decode(ConcreteBase<AccessibilityDisclosureValue>.self, forKey: .value)
        case .toggle:
            base = try container.decode(ConcreteBase<AccessibilityToggleValue>.self, forKey: .value)
        case .slider:
            base = try container.decode(ConcreteBase<AccessibilitySliderValue>.self, forKey: .value)
        case .stepper:
            base = try container.decode(ConcreteBase<AccessibilityStepperValue>.self, forKey: .value)
        case .progress:
            base = try container.decode(ConcreteBase<AccessibilityProgressValue>.self, forKey: .value)
        case .boundedNumber:
            base = try container.decode(ConcreteBase<AccessibilityBoundedNumber>.self, forKey: .value)
        case .number:
            base = try container.decode(ConcreteBase<AccessibilityNumber>.self, forKey: .value)
        case .empty:
            base = try container.decode(ConcreteBase<AccessibilityEmptyValue>.self, forKey: .value)
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(type, forKey: .type)
        try base.encode(to: container.superEncoder(forKey: .value))
    }
}

// MARK: - CodableAccessibilityValueStorage

package struct CodableAccessibilityValueStorage: Codable {
    var text: AccessibilityText?
    var value: AnyAccessibilityValue?

    package init(
        _ storage: AccessibilityValueStorage,
        in environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom? = nil
    ) {
        text = AccessibilityText(
            texts: storage.description.text,
            environment: environment,
            idiom: idiom
        )
        value = storage.value
    }

    package var accessibilityValue: AccessibilityValueStorage {
        var storage = AccessibilityValueStorage(description: text?.text)
        storage.value = value
        return storage
    }
}

// MARK: - AccessibilityPlatformSafe

package protocol AccessibilityPlatformSafe {}

extension String: AccessibilityPlatformSafe {}
extension Double: AccessibilityPlatformSafe {}
extension Int: AccessibilityPlatformSafe {}
extension UInt: AccessibilityPlatformSafe {}
extension UInt8: AccessibilityPlatformSafe {}
extension Bool: AccessibilityPlatformSafe {}
extension NSNumber: AccessibilityPlatformSafe {}
extension Never: AccessibilityPlatformSafe {}
extension Optional: AccessibilityPlatformSafe where Wrapped: AccessibilityPlatformSafe {}
