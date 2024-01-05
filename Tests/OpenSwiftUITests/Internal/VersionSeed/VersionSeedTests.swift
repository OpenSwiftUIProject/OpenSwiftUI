//
//  VersionSeedTests.swift
//
//
//  Created by Kyle on 2024/1/5.
//

@testable import OpenSwiftUI
import Testing

struct VersionSeedTests {
    @Test(arguments: [
        (0, "empty"),
        (UInt32.max, "invalid"),
        (2, "2"),
    ])
    func description(value: UInt32, expectedDescription: String) {
        let seed = VersionSeed(value: value)
        #expect(seed.description == expectedDescription)
    }
    
    @Test(arguments: [
        (0x0000_0000, 0x0000_0000, 0x9C35_2659),
        (0xFFFF_FFFF, 0x0000_0000, 0x17F8_3A02),
        (0xFFFF_FFFF, 0xFFFF_FFFF, 0x3258_2C16),
        (0xAABB_CCDD, 0x0000_0000, 0x8B94_7A49),
        (0x0000_0000, 0xAABB_CCDD, 0x7B38_F912),
        (0xAABB_CCDD, 0xAABB_CCDD, 0x1AAD_F11C),
        (0xFFFF_FFFF, 0xAABB_CCDD, 0x4C96_0643),
        (0xAABB_CCDD, 0xFFFF_FFFF, 0x13DA_25CE),
        (0x0000_0001, 0x0001_0000, 0x8621_ACD2),
        (0x0001_0000, 0x0000_0001, 0xD5E2_C632),
        (0x1000_0000, 0x0000_0001, 0xE6E8_7354),
        (0x0000_0001, 0x1000_0000, 0xAE49_4475),
    ])
    func merge(_ a: UInt32, _ b: UInt32, _ c: UInt32) {
        let seedA = VersionSeed(value: a)
        let seedB = VersionSeed(value: b)
        #expect(seedA.merge(seedB).value == c)
    }
}

extension UInt32: CustomTestStringConvertible {
    public var testDescription: String { hex }
    private var hex: String {
        let high = UInt16(truncatingIfNeeded: self &>> 16)
        let low = UInt16(truncatingIfNeeded: self)
        return String(format: "0x%04X_%04X", high, low)
    }
}
