//
//  ConstantLocation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

struct ConstantLocation<Value>: Location {
    var value: Value
    var wasRead: Bool {
        get { true }
        nonmutating set {}
    }
    func get() -> Value { value }
    func set(_: Value, transaction _: Transaction) {}
}
