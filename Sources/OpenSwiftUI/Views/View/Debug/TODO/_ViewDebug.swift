//
//  _ViewDebug.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/2.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 5A14269649C60F846422EA0FA4C5E535

import Foundation
internal import OpenSwiftUIShims

// MARK: _ViewDebug

public enum _ViewDebug {
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
}

extension _ViewDebug {
    fileprivate static var properties = Properties()
    fileprivate static var isInitialized = false

    // TODO:
    fileprivate static func reallyWrap(_: inout _ViewOutputs, value _: _GraphValue<some Any>, inputs _: UnsafePointer<_ViewInputs>) {}

    fileprivate static func appendDebugData(from: Int/*AGTreeElement*/ , to: [_ViewDebug.Data]) {}
}

// MARK: _ViewDebug.Property

extension _ViewDebug {
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

        enum CodingKeys: CodingKey {
            case properties
            case children
        }

        var data: [Property: Any]

        var childData: [_ViewDebug.Data]

        private func serializedProperties() -> [SerializedProperty] {
            data.compactMap { key, value -> SerializedProperty? in
                if key == .value {
                    if let attribute = serializedAttribute(for: value, label: nil, reflectionDepth: 6) {
                        return SerializedProperty(id: key.rawValue, attribute: attribute)
                    } else {
                        return nil
                    }
                } else if key == .type {
                    let type = value as? Any.Type ?? type(of: value)
                    let attribute = SerializedAttribute(type: type)
                    return SerializedProperty(id: 0, attribute: attribute)
                } else {
                    if let attribute = serializedAttribute(for: value, label: nil, reflectionDepth: 4) {
                        return SerializedProperty(id: key.rawValue, attribute: attribute)
                    } else {
                        return nil
                    }
                }
            }
        }

        // TODO
        // Mirror API
        private func serializedAttribute(for value: Any, label: String?, reflectionDepth depth: Int) -> SerializedAttribute? {
//            let unwrapped = unwrapped(value)

            return nil

//            let mirror = Mirror(reflecting: value)
//            mirror.displayStyle = .tuple

        }

        private func unwrapped(_ value: Any) -> Any? {
            if let value = value as? ValueWrapper {
                return value.wrappedValue
            } else {
                return nil
            }
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
    // Size: 0x60
    private struct SerializedAttribute: Encodable {
        // TODO:
        static func serialize(value _: Any) -> Any? {
            // Mirror API
            nil
        }

        init(type anyType: Any.Type) {
            name = nil
            type = String(reflecting: anyType)
            readableType = "" // TODO: /*OGTypeID(anyType).description*/
            flags = [
                conformsToProtocol(anyType, _viewProtocolDescriptor()) ? .view : [],
                conformsToProtocol(anyType, _viewModifierProtocolDescriptor()) ? .viewModifier : [],
            ]
            value = nil
            subattributes = nil
        }

        init(value inputValue: Any, serializeValue: Bool, label: String?, subattributes inputSubattributes: [SerializedAttribute]) {
            name = label
            let anyType = Swift.type(of: inputValue)
            type = String(reflecting: anyType)
            readableType = "" // TODO: /*OGTypeID(anyType).description*/
            flags = [
                conformsToProtocol(anyType, _viewProtocolDescriptor()) ? .view : [],
                conformsToProtocol(anyType, _viewModifierProtocolDescriptor()) ? .viewModifier : [],
            ]
            if serializeValue {
                value = SerializedAttribute.serialize(value: inputValue)
            } else {
                value = nil
            }
            subattributes = inputSubattributes
        }

        struct Flags: OptionSet, Encodable {
            let rawValue: Int

            static let view = Flags(rawValue: 1 << 0)
            static let viewModifier = Flags(rawValue: 1 << 1)
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

private protocol ValueWrapper {
    var wrappedValue: Any? { get }
}

extension Optional {
    var wrappedValue: Any? {
        if case let .some(wrapped) = self {
            return wrapped
        } else {
            return nil
        }
    }
}
