//
//  BloomFilter.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/17.
//  Lastest Version: iOS 15.5
//  Status: Complete

struct BloomFilter: Equatable {
    var value: UInt

    init(hashValue: Int) {
        // Make sure we do LSR instead of ASR
        let value = UInt(hashValue)
        let a0 = 1 &<< (value &>> 0x10)
        let a1 = 1 &<< (value &>> 0xa)
        let a2 = 1 &<< (value &>> 0x4)
        self.value = a0 | a1 | a2
    }

    init(type: Any.Type) {
        let pointer = unsafeBitCast(type, to: OpaquePointer.self)
        self.init(hashValue: Int(bitPattern: pointer))
    }
}
