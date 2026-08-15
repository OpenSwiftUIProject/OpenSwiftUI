//
//  AnyCodable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D0B3661659BB7A22647D6518B1368634 (SwiftUICore)

import Foundation

// MARK: - CodableRequirement

package protocol CodableRequirement {
    static func checkedCodableType(
        _ type: Any.Type
    ) -> (any Codable.Type)?
}

// MARK: - AnyCodable

package struct AnyCodable<Requirement>: Codable where Requirement: CodableRequirement {
    package var value: any Codable

    package init<Value>(_ value: Value) where Value: Codable {
        self.value = value
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    private enum Errors: Error {
        case noMangledName(type: Any.Type)
        case noType(mangledName: String)
        case noCodableType(type: Any.Type)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mangledName = try container.decode(String.self, forKey: .type)
        guard let type = _typeByName(mangledName) else {
            throw Errors.noType(mangledName: mangledName)
        }
        guard let codableType = Requirement.checkedCodableType(type) else {
            throw Errors.noCodableType(type: type)
        }
        value = try codableType.init(
            from: container.superDecoder(forKey: .value)
        )
    }

    package func encode(to encoder: any Encoder) throws {
        let type = Swift.type(of: value)
        guard let mangledName = _mangledTypeName(type) else {
            throw Errors.noMangledName(type: type)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mangledName, forKey: .type)
        try value.encode(to: container.superEncoder(forKey: .value))
    }
}
