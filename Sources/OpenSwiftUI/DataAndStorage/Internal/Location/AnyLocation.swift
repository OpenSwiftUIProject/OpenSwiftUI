//
//  AnyLocation.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: Complete

@usableFromInline
class AnyLocationBase {}

@usableFromInline
class AnyLocation<Value>: AnyLocationBase {
    var wasRead: Bool {
        get { fatalError() }
        set { fatalError() }
    }
    func get() -> Value { fatalError() }
    func set(_ value: Value, transaction: Transaction) { fatalError() }
    func update() -> (Value, Bool) { fatalError() }

    func projecting<P>(_ p: P) -> AnyLocation<P.Projected> where P: Projection, P.Base == Value {
        fatalError()
    }
}
