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

    override func projecting<P>(_ p: P) -> AnyLocation<P.Projected> where L.Value == P.Base, P : Projection {
        cache.reference(for: p, on: location)
    }

    override func update() -> (L.Value, Bool) {
        location.update()
    }
}
