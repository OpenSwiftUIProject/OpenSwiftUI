//
//  Location.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
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
