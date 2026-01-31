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

    static func == (lhs: SceneID, rhs: SceneID) -> Bool {
        switch (lhs, rhs) {
        case let (.string(lhsString), .string(rhsString)):
            return lhsString == rhsString
        case let (.type(lhsType, lhsValue), .type(rhsType, rhsValue)):
            return lhsType == rhsType && lhsValue == rhsValue
        case let (.string(lhsString), .type(rhsType, rhsValue)):
            return lhsString == "\(_typeName(rhsType))-\(rhsValue)"
        case let (.type(lhsType, lhsValue), .string(rhsString)):
            return "\(_typeName(lhsType))-\(lhsValue)" == rhsString
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
