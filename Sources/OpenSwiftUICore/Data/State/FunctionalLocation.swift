//
//  FunctionalLocation.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

import OpenGraphShims

struct FunctionalLocation<Value>: Location {
    var getValue: () -> Value
    var setValue: (Value, Transaction) -> Void
    var wasRead: Bool {
        get { true }
        nonmutating set {}
    }
    func get() -> Value { getValue() }
    func set(_ value: Value, transaction: Transaction) { setValue(value, transaction) }
    
    static func == (lhs: FunctionalLocation<Value>, rhs: FunctionalLocation<Value>) -> Bool {
        compareValues(lhs.getValue(), rhs.getValue())
    }
}
