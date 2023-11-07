//
//  LocationProjectionCache.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: 5A9440699EF65619D72

struct LocationProjectionCache {
    private var cache: [AnyHashable: Entry] = [:]
    
    mutating func reference<P: Projection, L: Location>(for projection: P, on location: L) -> AnyLocation<P.Projected> where P.Base == L.Value {
        let key = AnyHashable(projection)
        if let entry = cache[key],
           let box = entry.box,
           let result = box as? AnyLocation<P.Projected> {
            return result
        } else {
            let projectedLocation = ProjectedLocation(location: location, projection: projection)
            let box = LocationBox(location: projectedLocation)
            cache[key] = Entry(box: box)
            return box
        }
    }

    // MARK: OpenSwiftUI Addition
    // For OpenSwiftUITest
    func checkReference<P: Projection, L: Location>(for projection: P, on location: L) -> Bool where P.Base == L.Value {
        if let entry = cache[AnyHashable(projection)],
           let box = entry.box,
           box is AnyLocation<P.Projected> {
            true
        } else {
            false
        }
    }
}

private struct ProjectedLocation<L: Location, P: Projection>: Location where P.Base == L.Value {
    var location: L
    var projection: P

    init(location: L, projection: P) {
        self.location = location
        self.projection = projection
    }

    typealias Value = P.Projected

    var wasRead: Bool {
        get { location.wasRead }
        set { location.wasRead = newValue }
    }

    func get() -> Value { projection.get(base: location.get()) }

    func set(_ value: Value, transaction _: Transaction) {
        var base = location.get()
        projection.set(base: &base, newValue: value)
    }

    func update() -> (Value, Bool) {
        let (base, result) = location.update()
        let value = projection.get(base: base)
        return (value, result)
    }
}

extension LocationProjectionCache {
    private struct Entry {
        weak var box: AnyLocationBase?
    }
}
