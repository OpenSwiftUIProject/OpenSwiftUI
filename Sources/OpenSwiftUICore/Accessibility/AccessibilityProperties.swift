//
//  AccessibilityProperties.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenAttributeGraphShims

// MARK: - AccessibilityProperties

package struct AccessibilityProperties: Equatable {
    private var storage: [ObjectIdentifier: any AnyAccessibilityPropertiesEntry]

    package var isEmpty: Bool {
        storage.isEmpty
    }

    package init<K>(_ key: K.Type, _ value: K.PropertyValue) where K: AccessibilityPropertiesKey {
        self.init(reserving: 1)
        storage[ObjectIdentifier(K.self)] = AccessibilityPropertiesEntry(value)
    }

    package init<K>(_ key: K.Type, _ value: K.PropertyValue?) where K: AccessibilityPropertiesKey {
        if let value {
            self.init(key, value)
        } else {
            self.init()
        }
    }

    package init(reserving count: Int = 0) {
        storage = Dictionary(minimumCapacity: count)
    }

    package mutating func update(_ work: (inout [ObjectIdentifier: any AnyAccessibilityPropertiesEntry]) -> Void) {
        work(&storage)
    }

    package static func == (lhs: AccessibilityProperties, rhs: AccessibilityProperties) -> Bool {
        guard lhs.storage.count == rhs.storage.count else {
            return false
        }
        for (key, value) in lhs.storage {
            guard let other = rhs.storage[key], value.isEqual(to: other) else {
                return false
            }
        }
        return true
    }
}

extension AccessibilityProperties {
    package subscript<K>(key: K.Type) -> K.PropertyValue where K: AccessibilityPropertiesKey {
        get {
            storage[ObjectIdentifier(K.self)]?.anyValue as? K.PropertyValue ?? K.defaultValue
        }
        set {
            if K.isDefault(newValue) {
                storage.removeValue(forKey: ObjectIdentifier(K.self))
            } else {
                storage[ObjectIdentifier(K.self)] = AccessibilityPropertiesEntry(newValue)
            }
        }
    }
}

// MARK: - AnyAccessibilityPropertiesEntry

package protocol AnyAccessibilityPropertiesEntry {
    var anyValue: Any { get }

    func isEqual(to other: any AnyAccessibilityPropertiesEntry) -> Bool
}

extension AnyAccessibilityPropertiesEntry {
    package func isEqual(to other: any AnyAccessibilityPropertiesEntry) -> Bool {
        false
    }
}

// MARK: - AccessibilityPropertiesEntry

package struct AccessibilityPropertiesEntry<V>: AnyAccessibilityPropertiesEntry, Equatable {
    package var typedValue: V

    package init(_ typedValue: V) {
        self.typedValue = typedValue
    }

    package static func == (lhs: AccessibilityPropertiesEntry<V>, rhs: AccessibilityPropertiesEntry<V>) -> Bool {
        compareValues(lhs.typedValue, rhs.typedValue)
    }

    package var anyValue: Any {
        typedValue
    }

    package func isEqual(to other: any AnyAccessibilityPropertiesEntry) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

extension AccessibilityPropertiesEntry: AccessibilityCombinable where V: AccessibilityCombinable {
    @discardableResult
    package mutating func merge(with child: AccessibilityPropertiesEntry<V>) -> Bool {
        typedValue.merge(with: child.typedValue)
    }

    @discardableResult
    package mutating func merge(with child: V) -> Bool {
        typedValue.merge(with: child)
    }
}

// MARK: - AccessibilityPropertiesKey

package protocol AccessibilityPropertiesKey {
    associatedtype PropertyValue

    static var defaultValue: PropertyValue { get }

    static func isDefault(_ value: PropertyValue) -> Bool
}

// MARK: - AccessibilityOptionalPropertiesKey

package protocol AccessibilityOptionalPropertiesKey: AccessibilityPropertiesKey {
    associatedtype NonOptionalPropertyValue where PropertyValue == NonOptionalPropertyValue?

    static var valueType: NonOptionalPropertyValue.Type { get }
}

extension AccessibilityPropertiesKey {
    package static func isDefault(_ value: PropertyValue) -> Bool {
        false
    }
}

extension AccessibilityPropertiesKey where PropertyValue: Equatable {
    package static func isDefault(_ value: PropertyValue) -> Bool {
        value == defaultValue
    }
}

extension AccessibilityOptionalPropertiesKey {
    package static func isDefault(_ value: PropertyValue) -> Bool {
        value == nil
    }

    package static var defaultValue: NonOptionalPropertyValue? {
        nil
    }
}

// MARK: - AccessibilityAttachment

package struct AccessibilityAttachment: Equatable {
    package var properties: AccessibilityProperties

    package var platformElement: PlatformAccessibilityElement?

    package init(properties: AccessibilityProperties, platformElement: PlatformAccessibilityElement?) {
        self.properties = properties
        self.platformElement = platformElement
    }

    package init(properties: AccessibilityProperties) {
        self.init(properties: properties, platformElement: nil)
    }

    package init() {
        self.init(properties: AccessibilityProperties())
    }

    package var isEmpty: Bool {
        properties.isEmpty && platformElement == nil
    }

    package static func == (lhs: AccessibilityAttachment, rhs: AccessibilityAttachment) -> Bool {
        if let element = lhs.platformElement, element !== rhs.platformElement {
            return false
        }
        return lhs.properties == rhs.properties
    }
}

extension AccessibilityAttachment {
    package static func properties(_ properties: AccessibilityProperties) -> AccessibilityAttachment {
        AccessibilityAttachment(properties: properties)
    }
}

// MARK: - AccessibilityAttachmentToken

package enum AccessibilityAttachmentToken: Hashable, Codable {
    case attribute(AnyWeakAttribute)
    case identifier(UInt32)

    package init(_ attribute: AnyAttribute) {
        self = .attribute(AnyWeakAttribute(attribute))
    }

    package init<T>(_ attribute: Attribute<T>) {
        self.init(attribute.identifier)
    }

    package init(_ identifier: UInt32) {
        self = .identifier(identifier)
    }

    package var attribute: AnyAttribute? {
        guard case let .attribute(attribute) = self else {
            return nil
        }
        return attribute.attribute
    }

    package func encode(to encoder: any Encoder) throws {
        let value: UInt32
        switch self {
        case let .attribute(attribute):
            value = attribute.attribute?.rawValue ?? 0
        case let .identifier(identifier):
            value = identifier
        }
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = .identifier(try container.decode(UInt32.self))
    }
}
