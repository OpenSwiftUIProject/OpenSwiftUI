//
//  Location.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol Location<Value> {
    associatedtype Value
    var wasRead: Bool { get set }
    func get() -> Value
    func set(_ value: Value, transaction: Transaction)
    func update() -> (Value, Bool)
}

extension Location {
    func update() -> (Value, Bool) {
        (get(), true)
    }
}
