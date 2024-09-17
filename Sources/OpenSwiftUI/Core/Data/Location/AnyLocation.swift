//
//  AnyLocation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

/// The base type of all type-erased locations.
@usableFromInline
class AnyLocationBase {}

/// The base type of all type-erased locations with value-type Value.
/// It is annotated as `@unchecked Sendable` so that user types such as
/// `State`, and `SceneStorage` can be cleanly `Sendable`. However, it is
/// also the user types' responsibility to ensure that `get`, and `set` does
/// not access the graph concurrently (`get` should not be called while graph
/// is updating, for example).
@usableFromInline
class AnyLocation<Value>: AnyLocationBase {
    var wasRead: Bool {
        get { fatalError() }
        set { fatalError() }
    }
    func get() -> Value { fatalError() }
    func set(_ value: Value, transaction: Transaction) { fatalError() }
    func projecting<P: Projection>(_ p: P) -> AnyLocation<P.Projected> where Value == P.Base {
        fatalError()
    }
    func update() -> (Value, Bool) { fatalError() }
}
