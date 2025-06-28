//
//  ObjectCacheTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct ObjectCacheTests {
    @Test
    func example() {
        let cache: ObjectCache<Int, String> = ObjectCache { key in "\(key)" }
        #expect(cache[0] == "0")
        #expect(cache[1] == "1")
        #expect(cache[0] == "0")
    }
}
