//
//  AccessibilityChildBehaviorKind.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B6DAE808DEA8C0752D7A012F5E22D918 (SwiftUICore)

// MARK: - AccessibilityChildBehaviorKind

package enum AccessibilityChildBehaviorKind: Codable {
    case combine
    case contain
}

// MARK: - AccessibilityChildBehaviorKind + ProtobufEnum

extension AccessibilityChildBehaviorKind: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
        case .combine: 0
        case .contain: 1
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 0: self = .combine
        case 1: self = .contain
        default: return nil
        }
    }
}
