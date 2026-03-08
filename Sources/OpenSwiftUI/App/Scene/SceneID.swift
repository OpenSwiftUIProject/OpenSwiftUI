//
//  SceneID.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A633280036C924E306B135D28DDEA2A8 (SwiftUI)

import OpenSwiftUICore

// MARK: - SceneID

enum SceneID: Hashable {
    case string(String)
    case type(Any.Type, UInt8)

    @inline(__always)
    var description: String {
        switch self {
        case let .string(string):
            return string
        case let .type(type, value):
            return "\(_typeName(type))-\(value)"
        }
    }

    static func == (lhs: SceneID, rhs: SceneID) -> Bool {
        switch (lhs, rhs) {
        case let (.string(lhsString), .string(rhsString)):
            return lhsString == rhsString
        case let (.type(lhsType, lhsValue), .type(rhsType, rhsValue)):
            return lhsType == rhsType && lhsValue == rhsValue
        default:
            return lhs.description == rhs.description
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .string(string):
            hasher.combine(string)
        case let .type(type, value):
            hasher.combine(ObjectIdentifier(type))
            hasher.combine(value)
        }
    }
}

private struct SceneIDKey: EnvironmentKey {
    static var defaultValue: SceneID? { nil }
}

extension EnvironmentValues {
    var sceneID: SceneID? {
        get { self[SceneIDKey.self] }
        set { self[SceneIDKey.self] = newValue }
    }
}
