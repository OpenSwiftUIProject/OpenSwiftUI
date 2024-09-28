//
//  BloomFilter.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: WIP

package struct BloomFilter: Equatable {
    package var value: UInt
    
    @inlinable
    package init() {
        value = 0
    }
    
    @inlinable
    package init<T>(value: T) where T : Hashable {
        self.init(hashValue: value.hashValue)
    }
    
    @inlinable
    package init(type: any Any.Type) {
        let pointer = unsafeBitCast(type, to: OpaquePointer.self)
        self.init(hashValue: Int(bitPattern: pointer))
    }
    
    @inlinable
    package mutating func formUnion(_ other: BloomFilter) {
        value |= other.value
    }
    
    @inlinable
    package func union(_ other: BloomFilter) -> BloomFilter {
        var filter = BloomFilter()
        filter.value = value | other.value
        return filter
    }
    
    @inlinable
    package func mayContain(_ other: BloomFilter) -> Bool {
        (other.value & ~value) == 0
    }
    
    @inlinable
    package var isEmpty: Bool {
        value == 0
    }
    
    @inlinable
    init(hashValue: Int) {
        // Make sure we do LSR instead of ASR
        let value = UInt(bitPattern: hashValue)
        let a0 = 1 &<< (value &>> 0x10)
        let a1 = 1 &<< (value &>> 0xa)
        let a2 = 1 &<< (value &>> 0x4)
        self.value = a0 | a1 | a2
    }
    
    // FIXME:
    @inline(__always)
    package func match(_ filter: BloomFilter) -> Bool {
        (value & filter.value) == value
    }
}
