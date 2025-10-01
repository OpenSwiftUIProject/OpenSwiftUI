//
//  Binding+ObjectLocation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7719FABF28E05207C06C2817640AD611 (SwiftUICore)

import Foundation

extension Binding {
    init<ObjectType: AnyObject>(
        _ root: ObjectType,
        keyPath: ReferenceWritableKeyPath<ObjectType, Value>,
        isolation: (any Actor)?
    ) {
        let location = ObjectLocation(base: root, keyPath: keyPath, isolation: isolation)
        let box = LocationBox(location)
        self.init(value: location.get(), location: box)
    }
}

private struct ObjectLocation<Root, Value>: Location where Root: AnyObject {
    var base: Root

    var keyPath: ReferenceWritableKeyPath<Root, Value>

    var isolation: (any Actor)?

    var wasRead: Bool {
        get { true }
        nonmutating set {}
    }

    func get() -> Value {
        checkIsolation()
        return base[keyPath: keyPath]
    }

    func set(_ value: Value, transaction: Transaction) {
        withTransaction(transaction) {
            checkIsolation()
            base[keyPath: keyPath] = value
        }
    }

    static func == (_ lhs: ObjectLocation, _ rhs: ObjectLocation) -> Bool {
        lhs.base === rhs.base && lhs.keyPath == rhs.keyPath
    }

    func checkIsolation() {
        guard let isolation, isolation === MainActor.shared, !Thread.isMainThread else {
            return
        }
        let description = String(describing: keyPath)
        Log.runtimeIssues(
            "%s is isolated to the main actor. Accessing it via Binding from a different actor will cause undefined behaviors, and potential data races; This warning will become a runtime crash in a future version of OpenSwiftUI.",
            [description]
        )
    }
}
