//
//  BloomFilterTests.swift
//
//
//  Created by Kyle on 2023/10/17.
//

#if OPENSWIFTUI_USE_SWIFT_TESTING
@testable import OpenSwiftUI
import Testing

struct BloomFilterTests {
    @Test
    func testInitType() throws {
        #if os(macOS)
        // hashValue: 0x1dd382138
        // 1 &<< (value &>> 0x10): 1 &<< 0x38 -> 0x0100_0000_0000_0000
        // 1 &<< (value &>> 0x0a): 1 &<< 0x08 -> 0x0000_0000_0000_0100
        // 1 &<< (value &>> 0x94): 1 &<< 0x13 -> 0x0000_0000_0008_0000
        try initTypeHelper(Int.self, expectedTypeValue: 0x1_DD38_2138, expectedValue: 0x0100_0000_0008_0100, message: "macOS 14.0")
        #elseif os(iOS)
        try initTypeHelper(Int.self, expectedTypeValue: 0x1_DF10_D1E0, expectedValue: 0x0010_0000_4001_0000, message: "iOS 15.5 Simulator")
        #endif
    }

    private func initTypeHelper(_ type: Any.Type, expectedTypeValue: Int, expectedValue: UInt, message: StaticString = "") throws {
        let typeValue = Int(bitPattern: unsafeBitCast(type, to: OpaquePointer.self))
        guard typeValue == expectedTypeValue else {
            withKnownIssue {
                throw "The OS version is not covered. Please run it under \(message)"
            }
            return
        }
        #expect(BloomFilter(type: type).value == expectedValue)
    }

    @Test
    func testInitHashValue() throws {
        // hashValue: 0
        // 1 &<< (value &>> 0x10): 1 &<< 0 -> 0x0000_0000_0000_0001
        // 1 &<< (value &>> 0x0a): 1 &<< 0 -> 0x0000_0000_0000_0001
        // 1 &<< (value &>> 0x04): 1 &<< 0 -> 0x0000_0000_0000_0001
        #expect(BloomFilter(hashValue: 0).value == 0x0000_0000_0000_0001)

        #if arch(x86_64) || arch(arm64)
        // hashValue: 0x00000001dfa19ae0
        // 1 &<< (value &>> 0x10): 1 &<< 0x21 -> 0x0000_0002_0000_0000
        // 1 &<< (value &>> 0x0a): 1 &<< 0x26 -> 0x0000_0040_0000_0000
        // 1 &<< (value &>> 0x04): 1 &<< 0x2e -> 0x0000_4000_0000_0000
        #expect(BloomFilter(hashValue: 0x0000_0001_DFA1_9AE0).value == 0x0000_4042_0000_0000)
        #endif
    }
}

extension String: Error {}
#endif
