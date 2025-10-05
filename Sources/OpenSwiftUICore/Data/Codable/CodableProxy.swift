//
//  CodableProxy.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A66FCB65C49D586C0CA23AF611BF2C2B (SwiftUICore?)

package import Foundation

// MARK: - CodableByProxy

package protocol CodableByProxy {
    associatedtype CodingProxy: Codable

    var codingProxy: CodingProxy { get }

    static func unwrap(codingProxy: CodingProxy) -> Self
}

// MARK: - CodableProxy

package protocol CodableProxy: Codable {
    associatedtype Base

    var base: Base { get }
}

extension CodableByProxy where Self == CodingProxy.Base, CodingProxy: CodableProxy {
    package static func unwrap(codingProxy: CodingProxy) -> Self {
        codingProxy.base
    }
}

// MARK: - ProxyCodable

@propertyWrapper
package struct ProxyCodable<Value>: Codable where Value: CodableByProxy {
    package var wrappedValue: Value

    package var projectedValue: ProxyCodable<Value> { self }

    package init(_ value: Value) {
        self.wrappedValue = value
    }

    package init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue.codingProxy)
    }

    package init(from decoder: any Decoder) throws {
        var container = try decoder.singleValueContainer()
        let proxy = try container.decode(Value.CodingProxy.self)
        wrappedValue = Value.unwrap(codingProxy: proxy)
    }
}

extension ProxyCodable: Equatable where Value: Equatable {
    package static func == (lhs: ProxyCodable<Value>, rhs: ProxyCodable<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension ProxyCodable: Hashable where Value: Hashable {
    package func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

// MARK: - Optional + CodableByProxy

extension Optional: CodableByProxy where Wrapped: CodableByProxy {
    package var codingProxy: CodableOptional<Wrapped> {
        CodableOptional(self)
    }
}

// MARK: - RawRepresentable + CodableByProxy

extension RawRepresentable where RawValue: Codable {
    package var codingProxy: RawRepresentableProxy<Self> {
        RawRepresentableProxy(self)
    }
}

// MARK: - Error

private enum Error: Swift.Error {
    case unarchivingError
}

// MARK: - RawRepresentableProxy

package struct RawRepresentableProxy<Value>: CodableProxy where Value: RawRepresentable, Value.RawValue: Codable {
    package var base: Value

    package init(_ base: Value) {
        self.base = base
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Value.RawValue.self)
        guard let value = Value(rawValue: rawValue) else {
            throw Error.unarchivingError
        }
        base = value
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(base.rawValue)
    }
}

// MARK: - NSAttributedString.Key + CodableByProxy

extension NSAttributedString.Key: CodableByProxy {
    package typealias CodingProxy = RawRepresentableProxy<NSAttributedString.Key>
}

// MARK: - Array + CodableByProxy

extension Array: CodableByProxy where Element: CodableByProxy {
    package var codingProxy: [Element.CodingProxy] {
        map(\.codingProxy)
    }

    package static func unwrap(codingProxy: [Element.CodingProxy]) -> [Element] {
        codingProxy.map { Element.unwrap(codingProxy: $0) }
    }
}

// MARK: - JSONCodable

package struct JSONCodable<Value>: Codable {
    package var base: Value

    package init(_ base: Value) {
        self.base = base
    }

    package func encode(to encoder: any Encoder) throws {
        let data = try JSONSerialization.data(withJSONObject: base)
        let string = String(data: data, encoding: .utf8)!
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }

    private enum Error: Swift.Error {
        case invalidType(objectDescription: String, dataDescription: String)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let data = string.data(using: .utf8)!
        let object = try JSONSerialization.jsonObject(with: data)
        guard let base = object as? Value else {
            throw Error.invalidType(
                objectDescription: String(describing: type(of: object)),
                dataDescription: string
            )
        }
        self.base = base
    }
}

// MARK: - CodableRawRepresentable

@propertyWrapper
package struct CodableRawRepresentable<Value>: Codable where Value: RawRepresentable, Value.RawValue: Codable {
    package var wrappedValue: Value

    package init(_ value: Value) {
        self.wrappedValue = value
    }

    package init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Value.RawValue.self)
        guard let value = Value(rawValue: rawValue) else {
            throw Error.unarchivingError
        }
        wrappedValue = value
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue.rawValue)
    }
}

extension CodableRawRepresentable: Equatable where Value: Equatable {
    package static func == (lhs: CodableRawRepresentable<Value>, rhs: CodableRawRepresentable<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension CodableRawRepresentable: Hashable where Value: Hashable {
    package func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

// MARK: - CodableOptional

package struct CodableOptional<Wrapped>: CodableProxy where Wrapped: CodableByProxy {
    package var base: Wrapped?

    package init(_ base: Wrapped?) {
        self.base = base
    }

    private enum CodingKeys: CodingKey {
        case value
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let base {
            try container.encode(base.codingProxy, forKey: .value)
        }
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let proxy = try container.decodeIfPresent(Wrapped.CodingProxy.self, forKey: .value)
        base = proxy.map { Wrapped.unwrap(codingProxy: $0) }
    }
}

// MARK: - CodableNSAttributes

@propertyWrapper
package struct CodableNSAttributes: CodableByProtobuf, Hashable {

    package typealias Value = [NSAttributedString.Key: Any]

    package var wrappedValue: Value

    package var projectedValue: CodableNSAttributes { self }

    package init(_ value: Value) {
        self.wrappedValue = value
    }

    package init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    package func encode(to encoder: inout ProtobufEncoder) throws {
        let string = NSAttributedString(string: " ", attributes: wrappedValue)
        try CodableAttributedString(string).encode(to: &encoder)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        let string = try CodableAttributedString(from: &decoder).base
        guard string.length >= 0 else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "CodableNSAttribute found empty string"))
        }
        wrappedValue = string.attributes(at: 0, effectiveRange: nil)
    }

    package static func == (lhs: CodableNSAttributes, rhs: CodableNSAttributes) -> Bool {
        func areEqual<T>(_ a: T, _ b: Any) -> Bool where T: Equatable {
            guard let b = b as? T else {
                return false
            }
            return a == b
        }
        guard lhs.wrappedValue.count == rhs.wrappedValue.count else {
            return false
        }
        for (key, leftValue) in lhs.wrappedValue {
            guard let rightValue = rhs.wrappedValue[key] else {
                return false
            }
            guard let leftValue = leftValue as? any Equatable else {
                return false
            }
            guard areEqual(leftValue, rightValue) else {
                return false
            }
        }
        return true
    }

    package func hash(into hasher: inout Hasher) {
        for (key, value) in wrappedValue {
            hasher.combine(key)
            if let value = value as? any Hashable {
                hasher.combine(value)
            }
        }
    }
}
