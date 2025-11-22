//
//  ObjectCacheTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct ObjectCacheTests {
    @Test
    func accessCount() {
        var accessCounts: [Int: Int] = [:]
        let cache: ObjectCache<Int, String> = ObjectCache { key in
            accessCounts[key, default: 0] += 1
            return "\(key)"
        }

        #expect(accessCounts[0] == nil)

        #expect(cache[0] == "0")
        #expect(accessCounts[0] == 1)

        #expect(cache[0] == "0")
        #expect(accessCounts[0] == 1)
    }

    private struct Key: Hashable {
        var value: Int

        // Intended behavior for the test case
        var hashValue: Int { value }

        func hash(into hasher: inout Hasher) {
            // suppress warning
        }
    }

    @Test
    func bucketFullEviction() {
        enum Count {
            static var deinitValue: Int?
        }

        class Object {
            var value: Int

            init(value: Int) {
                self.value = value
            }

            deinit { Count.deinitValue = value }
        }

        var accessCounts: [Int: Int] = [:]
        let cache: ObjectCache<Key, Object> = ObjectCache { key in
            accessCounts[key.value, default: 0] += 1
            return Object(value: key.value)
        }
        for key in (0 ..< 32).map(Key.init(value:)) {
            #expect(accessCounts[key.value] == nil)
            #expect(cache[key].value == key.value)
            #expect(accessCounts[key.value] == 1)
        }
        #expect(Count.deinitValue == nil)
        #if DEBUG
        #expect(cache.count == 32)
        #endif
        _ = cache[Key(value: 32)] // This will evict one value since the bucket is full
        #expect(Count.deinitValue != nil)
    }

    @Test
    func bucketCollisionEviction() {
        enum Count {
            static var deinitOrder: [Int] = []
        }

        class Object {
            var value: Int

            init(value: Int) {
                self.value = value
            }

            deinit {
                Count.deinitOrder.append(value)
            }
        }

        var accessCounts: [Int: Int] = [:]
        let cache: ObjectCache<Key, Object> = ObjectCache { key in
            accessCounts[key.value, default: 0] += 1
            return Object(value: key.value)
        }
        for key in [0, 8, 16, 24].map(Key.init(value:)) {
            #expect(accessCounts[key.value] == nil)
            #expect(cache[key].value == key.value)
            #expect(accessCounts[key.value] == 1)
        }
        _ = cache[Key(value: 32)] // This will evict object for Key(value: 0)
        #expect(Count.deinitOrder == [0])

        _ = cache[Key(value: 8)]
        _ = cache[Key(value: 40)] // This will evict object for Key(value: 16) since we have visited Key(value: 8) recently
        #expect(Count.deinitOrder == [0, 16])
    }
}
