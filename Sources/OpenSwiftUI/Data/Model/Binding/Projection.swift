//
//  Projection.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol Projection: Hashable {
    associatedtype Base
    associatedtype Projected
    func get(base: Base) -> Projected
    func set(base: inout Base, newValue: Projected)
}

extension WritableKeyPath: Projection {
    typealias Base = Root
    typealias Projected = Value
    func get(base: Root) -> Value { base[keyPath: self] }
    func set(base: inout Root, newValue: Value) { base[keyPath: self] = newValue }
}
