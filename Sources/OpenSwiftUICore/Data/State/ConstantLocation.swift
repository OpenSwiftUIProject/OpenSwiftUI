//
//  ConstantLocation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import OpenGraphShims

struct ConstantLocation<Value>: Location {
    var value: Value
    
    init(value: Value) {
        self.value = value
    }
    
    var wasRead: Bool {
        get { true }
        nonmutating set {}
    }
    func get() -> Value { value }
    func set(_: Value, transaction _: Transaction) {}
    
    static func == (lhs: ConstantLocation<Value>, rhs: ConstantLocation<Value>) -> Bool {
        compareValues(lhs.value, rhs.value)
    }
}
