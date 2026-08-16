//
//  AnyCodable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D0B3661659BB7A22647D6518B1368634 (SwiftUICore)

import Foundation

// MARK: - CodableRequirement

protocol CodableRequirement {
    static func checkedCodableType(
        _ type: Any.Type
    ) -> (any (Decodable & Encodable).Type)?
}

private extension Decodable where Self: Encodable {
    static func decode<Key>(
        from key: Key,
        in container: KeyedDecodingContainer<Key>
    ) throws -> any Decodable & Encodable where Key: CodingKey {
        try container.decode(Self.self, forKey: key)
    }
}

// MARK: - AnyCodable

struct AnyCodable<Requirement>: Codable where Requirement: CodableRequirement {
    private enum Errors: Error {
        case noMangledName(type: Any.Type)
        case noType(mangledName: String)
        case noCodableType(type: Any.Type)
        case tooGenericConstraint
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    var value: any Decodable & Encodable

    init<Value>(_ value: Value) where Value: Decodable, Value: Encodable {
        self.value = value
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mangledName = try container.decode(String.self, forKey: .type)
        guard let type = _typeByName(mangledName) else {
            throw Errors.noType(mangledName: mangledName)
        }
        guard let codableType = Requirement.checkedCodableType(type) else {
            throw DecodingError.typeMismatch(
                type,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "\(type) is not permitted by \(Requirement.self)"
                )
            )
        }
        value = try codableType.decode(from: .value, in: container)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let type = Swift.type(of: value)
        guard let mangledName = _mangledTypeName(type) else {
            throw Errors.noMangledName(type: type)
        }
        try container.encode(mangledName, forKey: .type)
        try container.encode(value, forKey: .value)
    }
}
