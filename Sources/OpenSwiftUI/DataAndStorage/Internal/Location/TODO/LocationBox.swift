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
}
