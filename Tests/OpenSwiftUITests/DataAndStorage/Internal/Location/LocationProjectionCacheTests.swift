//
//  LocationProjectionCacheTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

@testable import OpenSwiftUI
import XCTest

final class LocationProjectionCacheTests: XCTestCase {
    func testLocationProjectionCache() throws {
        struct V {
            var count = 0
            var name = ""
        }
        class MockLocation: Location {
            private var value = V()
            var wasRead = false
            typealias Value = V
            func get() -> Value { value }
            func set(_: Value, transaction _: Transaction) {}
        }
        let location = MockLocation()
        let countKeyPath: WritableKeyPath = \V.count
        let nameKeyPath: WritableKeyPath = \V.name
        var cache = LocationProjectionCache()
        XCTAssertEqual(cache.checkReference(for: countKeyPath, on: location), false)
        XCTAssertEqual(cache.checkReference(for: nameKeyPath, on: location), false)

        _ = cache.reference(for: countKeyPath, on: location)
        XCTAssertEqual(cache.checkReference(for: countKeyPath, on: location), false)
        XCTAssertEqual(cache.checkReference(for: nameKeyPath, on: location), false)
        _ = cache.reference(for: nameKeyPath, on: location)
        XCTAssertEqual(cache.checkReference(for: countKeyPath, on: location), false)
        XCTAssertEqual(cache.checkReference(for: nameKeyPath, on: location), false)

        withExtendedLifetime(cache.reference(for: countKeyPath, on: location)) {
            XCTAssertEqual(cache.checkReference(for: countKeyPath, on: location), true)
            XCTAssertEqual(cache.checkReference(for: nameKeyPath, on: location), false)
            withExtendedLifetime(cache.reference(for: nameKeyPath, on: location)) {
                XCTAssertEqual(cache.checkReference(for: countKeyPath, on: location), true)
                XCTAssertEqual(cache.checkReference(for: nameKeyPath, on: location), true)
            }
        }
    }
}
