//
//  LocationBox.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: TODO

class LocationBox<L: Location>: AnyLocation<L.Value> {
    var location: L
    @UnsafeLockedPointer
    var cache = LocationProjectionCache()

    init(location: L) {
        self.location = location
    }

    override func get() -> L.Value {
        location.get()
    }

    override func set(_ value: L.Value, transaction: Transaction) {
        location.set(value, transaction: transaction)
    }
}
