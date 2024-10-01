//
//  ViewDebug.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

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
        
        @inlinable
        package init(_ property: Property) {
            self.init(rawValue: 1 << property.rawValue)
        }

        public static let type = Properties(.type)
        public static let value = Properties(.value)
        public static let transform = Properties(.transform)
        public static let position = Properties(.position)
        public static let size = Properties(.size)
        public static let environment = Properties(.environment)
        public static let phase = Properties(.phase)
        public static let layoutComputer = Properties(.layoutComputer)
        public static let displayList = Properties(.displayList)
        public static let all = Properties(rawValue: 0xFFFF_FFFF)
    }
    
    package static var properties = Properties()
    
    public struct Data {
        package var data: [Property: Any]
        package var childData: [_ViewDebug.Data]
        
        package init() {
            data = [:]
            childData = []
        }
    }
    
    package static var isInitialized = false
}

@available(*, unavailable)
extension _ViewDebug.Properties: Sendable {}

@available(*, unavailable)
extension _ViewDebug.Property: Sendable {}

@available(*, unavailable)
extension _ViewDebug.Data: Sendable {}

@available(*, unavailable)
extension _ViewDebug: Sendable {}
