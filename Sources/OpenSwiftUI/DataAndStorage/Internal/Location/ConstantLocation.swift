//
//  ConstantLocation.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: Complete

struct ConstantLocation<Value>: Location {
    var value: Value
    var wasRead: Bool {
        get { true }
        set {}
    }
    func get() -> Value { value }
    func set(_: Value, transaction _: Transaction) {}
}
