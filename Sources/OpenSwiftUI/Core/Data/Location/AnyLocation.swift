//
//  AnyLocation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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
    func projecting<P>(_ p: P) -> AnyLocation<P.Projected> where P: Projection, P.Base == Value {
        fatalError()
    }
    func update() -> (Value, Bool) { fatalError() }
}
