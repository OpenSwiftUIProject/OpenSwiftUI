//
//  LocationBoxTests.swift
//
//
//  Created by Kyle on 2023/11/8.
//

@testable import OpenSwiftUI
import Testing

struct LocationBoxTests {
    @Test
    func basicLocationBox() throws {
        class MockLocation: Location {
            private var value = 0
            var wasRead = false
            typealias Value = Int
            func get() -> Value { value }
            func set(_ value: Int, transaction _: Transaction) { self.value = value }
            func update() -> (Int, Bool) {
                defer { value += 1 }
                return (value, value == 0)
            }
        }

        let location = MockLocation()
        let box = LocationBox(location: location)

        #expect(location.wasRead == false)
        #expect(box.wasRead == false)
        location.wasRead = true
        #expect(location.wasRead == true)
        #expect(box.wasRead == true)
        box.wasRead = false
        #expect(location.wasRead == false)
        #expect(box.wasRead == false)

        #expect(location.get() == 0)
        #expect(box.get() == 0)
        location.set(3, transaction: .init())
        #expect(location.get() == 3)
        #expect(box.get() == 3)
        box.set(0, transaction: .init())
        #expect(location.get() == 0)
        #expect(box.get() == 0)

        let (value, result) = box.update()
        #expect((value, result) == (0, true))
        #expect(location.get() == 1)
    }

    @Test
    func projecting() {
        struct V {
            var count = 0
        }

        class MockLocation: Location {
            private var value = V()
            var wasRead = false
            typealias Value = V
            func get() -> Value { value }
            func set(_ value: Value, transaction _: Transaction) { self.value = value }
            func update() -> (Value, Bool) {
                defer { value.count += 1 }
                return (value, value.count == 0)
            }
        }

        let location = MockLocation()
        let box = LocationBox(location: location)

        let keyPath: WritableKeyPath = \V.count
        #expect(box.cache.checkReference(for: keyPath, on: location) == false)
        let newLocation = box.projecting(keyPath)
        #expect(box.cache.checkReference(for: keyPath, on: location) == true)
        #expect(location.get().count == 0)
        _ = box.update()
        #expect(location.get().count == 1)
        #expect(newLocation.get() == 1)
    }
}
