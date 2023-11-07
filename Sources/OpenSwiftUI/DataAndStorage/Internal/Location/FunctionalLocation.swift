//
//  FunctionalLocation.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/4.
//  Lastest Version: iOS 15.5
//  Status: Complete

struct FunctionalLocation<Value>: Location {
    var getValue: () -> Value
    var setValue: (Value, Transaction) -> Void
    var wasRead: Bool {
        get { true }
        nonmutating set {}
    }
    func get() -> Value { getValue() }
    func set(_ value: Value, transaction: Transaction) { setValue(value, transaction) }
}
