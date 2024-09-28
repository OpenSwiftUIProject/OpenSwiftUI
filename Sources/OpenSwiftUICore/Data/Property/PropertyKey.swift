//
//  PropertyKey.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

internal import OpenGraphShims

package protocol PropertyKey {
    associatedtype Value
    static var defaultValue: Value { get }
    static func valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool
}

extension PropertyKey where Value: Equatable {
    package static func valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        lhs == rhs
    }
}

extension PropertyKey {
    package static func valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        compareValues(lhs, rhs)
    }
}
