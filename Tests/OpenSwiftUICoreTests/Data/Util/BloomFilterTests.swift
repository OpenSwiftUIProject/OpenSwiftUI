//
//  BloomFilterTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct BloomFilterTests {
    private struct FixedHash: Hashable {
        let hashValue: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(hashValue)
        }
    }

    @Test
    func initType() {
        let address = Int(bitPattern: ObjectIdentifier(Int.self))
        #expect(BloomFilter(type: Int.self) == BloomFilter(value: FixedHash(hashValue: address)))
    }

    #if arch(x86_64) || arch(arm64)
    @Test(arguments: [
        (0, 0x0000_0000_0000_0001),
        (0x0000_0001_DFA1_9AE0, 0x0000_4042_0000_0000),
        (-1, 0x8000_0000_0000_0000),
    ] as [(Int, UInt)])
    func initValue(hashValue: Int, expected: UInt) {
        #expect(BloomFilter(value: FixedHash(hashValue: hashValue)).value == expected)
    }
    
    @Test
    func union() throws {
        // Test union of two filters
        let filter1 = BloomFilter(value: FixedHash(hashValue: 0))
        let filter2 = BloomFilter(value: FixedHash(hashValue: 0x0000_0001_DFA1_9AE0))
        
        // Test union operation
        let unionResult = filter1.union(filter2)
        #expect(unionResult.value == 0x0000_4042_0000_0001)
        
        // Test formUnion operation
        var mutableFilter = filter1
        mutableFilter.formUnion(filter2)
        #expect(mutableFilter.value == 0x0000_4042_0000_0001)
        
        // Test union with empty filter
        let emptyFilter = BloomFilter()
        #expect(filter1.union(emptyFilter).value == filter1.value)
        #expect(emptyFilter.union(filter1).value == filter1.value)
    }
    
    @Test
    func mayContain() throws {
        // Create filters with known bits
        let filter1 = BloomFilter(value: FixedHash(hashValue: 0))
        let filter2 = BloomFilter(value: FixedHash(hashValue: 0x0000_0001_DFA1_9AE0))
        let unionFilter = filter1.union(filter2)  // 0x0000_4042_0000_0001
        let emptyFilter = BloomFilter()  // 0x0000_0000_0000_0000
        
        // Test mayContain functionality
        #expect(unionFilter.mayContain(filter1), "Union may contain filter1")
        #expect(unionFilter.mayContain(filter2), "Union may contain filter2")
        #expect(!filter1.mayContain(filter2), "filter1 does not contain filter2")
        #expect(!filter2.mayContain(filter1), "filter2 does not contain filter1")
        
        // Empty filter cases
        #expect(filter1.mayContain(emptyFilter), "Any non-empty filter should contain empty filter")
        #expect(filter2.mayContain(emptyFilter), "Any non-empty filter should contain empty filter")
        #expect(!emptyFilter.mayContain(filter1), "Empty filter does not contain any non-empty filter")
        
        // Self-containment
        #expect(filter1.mayContain(filter1), "Filter should contain itself")
        #expect(filter2.mayContain(filter2), "Filter should contain itself")
        #expect(emptyFilter.mayContain(emptyFilter), "Empty filter should contain itself")
    }
    #endif
}
