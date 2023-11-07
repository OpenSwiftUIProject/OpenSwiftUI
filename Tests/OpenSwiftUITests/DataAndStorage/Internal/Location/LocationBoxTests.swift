//
//  LocationBoxTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

import XCTest
@testable import OpenSwiftUI

final class LocationBoxTests: XCTestCase {
    func testBasicLocationBox() throws {
        class MockLocation: Location {
            private var value: Int = 0
            var wasRead: Bool = false
            typealias Value = Int
            func get() -> Value { value }
            func set(_ value: Int, transaction: Transaction) { self.value = value }
            func update() -> (Int, Bool) {
                defer { value += 1 }
                return (value, value == 0)
            }
        }

        let location = MockLocation()
        let box = LocationBox(location: location)

        XCTAssertEqual(location.wasRead, false)
        XCTAssertEqual(box.wasRead, false)
        location.wasRead = true
        XCTAssertEqual(location.wasRead, true)
        XCTAssertEqual(box.wasRead, true)
        box.wasRead = false
        XCTAssertEqual(location.wasRead, false)
        XCTAssertEqual(box.wasRead, false)

        XCTAssertEqual(location.get(), 0)
        XCTAssertEqual(box.get(), 0)
        location.set(3, transaction: .init())
        XCTAssertEqual(location.get(), 3)
        XCTAssertEqual(box.get(), 3)
        box.set(0, transaction: .init())
        XCTAssertEqual(location.get(), 0)
        XCTAssertEqual(box.get(), 0)

        let (value, result) = box.update()
        XCTAssertEqual(location.get(), 1)
        XCTAssertEqual(value, 0)
        XCTAssertEqual(result, true)
    }

    func testProjecting() {
        struct V {
            var count = 0
        }

        class MockLocation: Location {
            private var value = V()
            var wasRead: Bool = false
            typealias Value = V
            func get() -> Value { value }
            func set(_ value: Value, transaction: Transaction) { self.value = value }
            func update() -> (Value, Bool) {
                defer { value.count += 1 }
                return (value, value.count == 0)
            }
        }

        let location = MockLocation()
        let box = LocationBox(location: location)

        let keyPath: WritableKeyPath = \V.count
        XCTAssertEqual(box.cache.checkReference(for: keyPath, on: location), false)
        let newLocation = box.projecting(keyPath)
        XCTAssertEqual(box.cache.checkReference(for: keyPath, on: location), true)
        XCTAssertEqual(location.get().count, 0)
        _ = box.update()
        XCTAssertEqual(location.get().count, 1)
        XCTAssertEqual(newLocation.get(), 1)
    }
}
