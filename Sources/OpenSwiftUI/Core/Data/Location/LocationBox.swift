//
//  LocationBox.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

class LocationBox<L: Location>: AnyLocation<L.Value> {
    var location: L
    @UnsafeLockedPointer
    var cache = LocationProjectionCache()

    init(location: L) {
        self.location = location
    }

    override var wasRead: Bool {
        get { location.wasRead }
        set { location.wasRead = newValue }
    }

    override func get() -> L.Value {
        location.get()
    }

    override func set(_ value: L.Value, transaction: Transaction) {
        location.set(value, transaction: transaction)
    }

    override func projecting<P: Projection>(_ projection: P) -> AnyLocation<P.Projected> where L.Value == P.Base {
        cache.reference(for: projection, on: location)
    }

    override func update() -> (L.Value, Bool) {
        location.update()
    }
}
