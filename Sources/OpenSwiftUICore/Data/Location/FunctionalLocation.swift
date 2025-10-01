//
//  FunctionalLocation.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

import OpenAttributeGraphShims

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
