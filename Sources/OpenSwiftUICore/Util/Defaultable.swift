//
//  Defaultable.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - Defaultable [6.5.4]

package protocol Defaultable {
    associatedtype Value

    static var defaultValue: Value { get }
}
