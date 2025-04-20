//
//  Cache3Tests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct Cache3Tests {
    @Test
    func put() {
        var cache: Cache3<Int, String> = Cache3()
        cache.put(1, value: "1")
        #expect(cache.find(1) == "1")
        #expect(cache.find(2) == nil)
        #expect(cache.find(3) == nil)
        #expect(cache.find(4) == nil)
        
        cache.put(2, value: "2")
        #expect(cache.find(1) == "1")
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == nil)
        #expect(cache.find(4) == nil)
        
        cache.put(3, value: "3")
        #expect(cache.find(1) == "1")
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == nil)
        
        cache.put(4, value: "4")
        #expect(cache.find(1) == nil)
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == "4")
    }

    @Test
    func get() {
        var cache: Cache3<Int, String> = Cache3()

        let value4 = cache.get(4) { "4" }
        #expect(value4 == "4")
        #expect(cache.find(1) == nil)
        #expect(cache.find(2) == nil)
        #expect(cache.find(3) == nil)
        #expect(cache.find(4) == "4")

        let value3 = cache.get(3) { "3" }
        #expect(value3 == "3")
        #expect(cache.find(1) == nil)
        #expect(cache.find(2) == nil)
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == "4")

        let value2 = cache.get(2) { "2" }
        #expect(value2 == "2")
        #expect(cache.find(1) == nil)
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == "4")

        let value1 = cache.get(1) { "1" }
        #expect(value1 == "1")
        #expect(cache.find(1) == "1")
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == nil)
    }
}