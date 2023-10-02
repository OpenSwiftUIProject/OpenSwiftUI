//
//  _ViewDebug.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/2.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 5A14269649C60F846422EA0FA4C5E535

import Foundation

// MARK: _ViewDebug

extension _ViewDebug {
    fileprivate static var properties = Properties()
    fileprivate static var isInitialized = false

    // TODO:
    fileprivate static func reallyWrap(_: inout _ViewOutputs, value _: _GraphValue<some Any>, inputs _: UnsafePointer<_ViewInputs>) {}
}

// MARK: _ViewDebug.Property

public enum _ViewDebug {
    public enum Property: UInt32, Hashable {
        case type
        case value
        case transform
        case position
        case size
        case environment
        case phase
        case layoutComputer
        case displayList
    }

    public struct Properties: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let type = Property(rawValue: 1 << Property.type.rawValue)
        public static let value = Property(rawValue: 1 << Property.value.rawValue)
        public static let transform = Property(rawValue: 1 << Property.transform.rawValue)
        public static let position = Property(rawValue: 1 << Property.position.rawValue)
        public static let size = Property(rawValue: 1 << Property.size.rawValue)
        public static let environment = Property(rawValue: 1 << Property.environment.rawValue)
        public static let phase = Property(rawValue: 1 << Property.phase.rawValue)
        public static let layoutComputer = Property(rawValue: 1 << Property.layoutComputer.rawValue)
        public static let displayList = Property(rawValue: 1 << Property.displayList.rawValue)
        public static let all = Property(rawValue: 0xFFFF_FFFF)
    }
}

// MARK: _ViewDebug.Data

extension _ViewDebug {
    public struct Data: Encodable {
        public func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<_ViewDebug.Data.CodingKeys> = encoder.container(keyedBy: _ViewDebug.Data.CodingKeys.self)
            try container.encode(serializedProperties(), forKey: .properties)
            try container.encode(childData, forKey: .children)
        }

        public static func serializedData(_ viewDebugData: [_ViewDebug.Data]) -> Foundation.Data? {
            let encoder = JSONEncoder()
            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan")
            do {
                let data = try encoder.encode(viewDebugData)
                return data
            } catch {
                let dic = ["error": error.localizedDescription]
                return try? encoder.encode(dic)
            }
        }

        enum CodingKeys: CodingKey {
            case properties
            case children
        }

        var data: [Property: Any]

        var childData: [_ViewDebug.Data]

        // TODO
        private func serializedProperties() -> [SerializedProperty] {
            []
        }
    }
}

// MARK: _ViewDebug.Data.SerializedProperty

extension _ViewDebug.Data {
    private struct SerializedProperty: Encodable {
        let id: UInt32
        let attribute: SerializedAttribute

        enum CodingKeys: CodingKey {
            case id
            case attribute
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(attribute, forKey: .attribute)
        }
    }
}

// MARK: _ViewDebug.Data.SerializedAttribute

extension _ViewDebug.Data {
    private struct SerializedAttribute: Encodable {
        struct Flags: OptionSet, Encodable {
            let rawValue: Int
        }

        let name: String?
        let type: String
        let readableType: String
        let flags: Flags
        let value: Any?
        let subattributes: [SerializedAttribute]?
        
        enum CodingKeys: CodingKey {
            case name
            case type
            case readableType
            case flags
            case value
            case subattributes
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(name, forKey: .name)
            try container.encode(type, forKey: .type)
            try container.encode(readableType, forKey: .readableType)
            try container.encode(flags, forKey: .flags)
            if let value = value as? Encodable {
                try container.encodeIfPresent(value, forKey: .value)
            }
            try container.encodeIfPresent(subattributes, forKey: .subattributes)
        }
    }
}
