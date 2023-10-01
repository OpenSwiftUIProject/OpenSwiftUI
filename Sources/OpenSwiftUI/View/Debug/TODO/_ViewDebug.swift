//
//  _ViewDebug.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/2.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 5A14269649C60F846422EA0FA4C5E535

import Foundation

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

    public struct Data {
        enum CodingKeys {
            case properties
            case children
        }

        var data: [Property: Any]

        var childData: [_ViewDebug.Data]
    }
}

extension _ViewDebug {
    fileprivate static var properties = Properties()
    fileprivate static var isInitialized = false
}

// extension _ViewDebug {
//  public static func serializedData(_ viewDebugData: [_ViewDebug.Data]) -> Foundation.Data?
// }

// extension _ViewDebug.Data: Encodable {
//    public func encode(to encoder: Encoder) throws {
//
//    }
// }
