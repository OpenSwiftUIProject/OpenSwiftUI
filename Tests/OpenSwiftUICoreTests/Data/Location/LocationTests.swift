//
//  LocationTests.swift
//  OpenSwiftUICoreTests

@_spi(ForOpenSwiftUIOnly)
@testable
#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
@_private(sourceFile: "Location.swift")
#endif
import OpenSwiftUICore
import Testing

struct LocationTests {
    @Test
    func location() {
        struct L: Location {
            typealias Value = Int
            var wasRead = false
            func get() -> Int { 0 }
            func set(_: Int, transaction _: Transaction) {}
        }
        let location = L()
        let (value, result) = location.update()
        #expect((value, result) == (0, true))
    }
    
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
            static func == (lhs: MockLocation, rhs: MockLocation) -> Bool {
                lhs.value == rhs.value
            }
        }

        let location = MockLocation()
        let box = LocationBox(location)

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

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    @Test
    func boxProjectingAndCache() {
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
            static func == (lhs: MockLocation, rhs: MockLocation) -> Bool {
                lhs.value.count == rhs.value.count
            }
        }

        let location = MockLocation()
        let box = LocationBox(location)

        let keyPath: WritableKeyPath = \V.count
        #expect(box.cache.cache.isEmpty == true)
        let newLocation = box.projecting(keyPath)
        #expect(box.cache.cache.isEmpty == false)
        #expect(location.get().count == 0)
        _ = box.update()
        #expect(box.get().count == 1)
        #expect(location.get().count == 1)
        #expect(newLocation.get() == 1)
        
        #expect(box.cache.cache.isEmpty == false)
        box.cache.reset()
        #expect(box.cache.cache.isEmpty == true)
    }
    #endif

    @Test
    func constantLocation() throws {
        let location = ConstantLocation(value: 0)
        #expect(location.wasRead == true)
        #expect(location.get() == 0)
        location.wasRead = false
        location.set(1, transaction: .init())
        #expect(location.wasRead == true)
        #expect(location.get() == 0)
    }

    @Test
    func functionalLocation() {
        class V {
            var count = 0
        }
        let value = V()
        let location = FunctionalLocation {
            value.count
        } setValue: { newCount, _ in
            value.count = newCount * newCount
        }
        #expect(location.wasRead == true)
        #expect(location.get() == 0)
        location.wasRead = false
        location.set(2, transaction: .init())
        #expect(location.wasRead == true)
        #expect(location.get() == 4)
    }
}
