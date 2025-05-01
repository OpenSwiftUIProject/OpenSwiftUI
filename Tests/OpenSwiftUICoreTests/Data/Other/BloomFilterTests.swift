//
//  BloomFilterTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import Testing

struct BloomFilterTests {
    #if os(macOS)
    @Test("Bloom Filter's init", .enabled(if: ProcessInfo.processInfo.operatingSystemVersionString == "14.0"))
    func initType() throws {
        // hashValue: 0x1dd382138
        // 1 &<< (value &>> 0x10): 1 &<< 0x38 -> 0x0100_0000_0000_0000
        // 1 &<< (value &>> 0x0a): 1 &<< 0x08 -> 0x0000_0000_0000_0100
        // 1 &<< (value &>> 0x94): 1 &<< 0x13 -> 0x0000_0000_0008_0000
        try initTypeHelper(Int.self, expectedTypeValue: 0x1_DD38_2138, expectedValue: 0x0100_0000_0008_0100, message: "macOS 14.0")
    }
    #elseif os(iOS) && targetEnvironment(simulator)
    @Test("Bloom Filter's init", .enabled(if: ProcessInfo.processInfo.operatingSystemVersionString == "15.5"))
    func testInitType() throws {
        try initTypeHelper(Int.self, expectedTypeValue: 0x1_DF10_D1E0, expectedValue: 0x0010_0000_4001_0000, message: "iOS 15.5 Simulator")
    }
    #endif

    private func initTypeHelper(_ type: Any.Type, expectedTypeValue: Int, expectedValue: UInt, message: StaticString = "") throws {
        let typeValue = Int(bitPattern: unsafeBitCast(type, to: OpaquePointer.self))
        #expect(typeValue == expectedTypeValue, "The OS version is not covered. Please run it under \(message)")
        #expect(BloomFilter(type: type).value == expectedValue)
    }

    #if arch(x86_64) || arch(arm64)
    @Test
    func initHashValue() throws {
        // hashValue: 0
        // 1 &<< (value &>> 0x10): 1 &<< 0 -> 0x0000_0000_0000_0001
        // 1 &<< (value &>> 0x0a): 1 &<< 0 -> 0x0000_0000_0000_0001
        // 1 &<< (value &>> 0x04): 1 &<< 0 -> 0x0000_0000_0000_0001
        #expect(BloomFilter(hashValue: 0).value == 0x0000_0000_0000_0001)

        // hashValue: 0x00000001dfa19ae0
        // 1 &<< (value &>> 0x10): 1 &<< 0x21 -> 0x0000_0002_0000_0000
        // 1 &<< (value &>> 0x0a): 1 &<< 0x26 -> 0x0000_0040_0000_0000
        // 1 &<< (value &>> 0x04): 1 &<< 0x2e -> 0x0000_4000_0000_0000
        #expect(BloomFilter(hashValue: 0x0000_0001_DFA1_9AE0).value == 0x0000_4042_0000_0000)
    }
    
    @Test
    func union() throws {
        // Test union of two filters
        let filter1 = BloomFilter(hashValue: 0)  // 0x0000_0000_0000_0001
        let filter2 = BloomFilter(hashValue: 0x0000_0001_DFA1_9AE0)  // 0x0000_4042_0000_0000
        
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
        let filter1 = BloomFilter(hashValue: 0)  // 0x0000_0000_0000_0001
        let filter2 = BloomFilter(hashValue: 0x0000_0001_DFA1_9AE0)  // 0x0000_4042_0000_0000
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
