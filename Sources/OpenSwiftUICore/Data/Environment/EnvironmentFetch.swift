//
//  EnvironmentFetch.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: BA60BF7120E939C5C25B2A488163D4AC (SwiftUICore)

import OpenGraphShims

struct EnvironmentFetch<Value>: Rule, AsyncAttribute, Hashable {
    var _environment: Attribute<EnvironmentValues>
    var keyPath: KeyPath<EnvironmentValues, Value>

    var environment: EnvironmentValues { _environment.value }

    var value: Value { environment[keyPath: keyPath] }

    func hash(into hasher: inout Hasher) {
        hasher.combine(keyPath)
    }

    static func == (lhs: EnvironmentFetch<Value>, rhs: EnvironmentFetch<Value>) -> Bool {
        lhs.keyPath == rhs.keyPath
    }
}
