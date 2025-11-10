//
//  ObjectCacheTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct ObjectCacheTests {
    @Test
    func example() {
        let table = [
            0: "0",
            1: "1",
            2: "2"
        ]
        
        var accessCounts = [
            0: 0,
            1: 0,
            2: 0
        ]
        
        let cache: ObjectCache<Int, String> = ObjectCache { key in
            accessCounts[key]! += 1
            return table[key]!
        }
        
        for (key, value) in table {
            #expect(accessCounts[key] == 0)
            
            #expect(cache[key] == value)
            #expect(accessCounts[key] == 1)
            
            #expect(cache[key] == value)
            #expect(accessCounts[key] == 1)
        }
    }
}
