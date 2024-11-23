//
//  EnvironmentKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

import OpenGraphShims

public protocol EnvironmentKey {
    associatedtype Value

    static var defaultValue: Value { get }
    
    static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Bool
}

extension EnvironmentKey {
    public static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Bool {
        compareValues(lhs, rhs)
    }
}

extension EnvironmentKey where Value: Equatable {
    public static func _valuesEqual(_ lhs: Self.Value, _ rhs: Self.Value) -> Bool {
        lhs == rhs
    }
}

package protocol DerivedEnvironmentKey {
    associatedtype Value: Equatable
    static func value(in: EnvironmentValues) -> Value
}
