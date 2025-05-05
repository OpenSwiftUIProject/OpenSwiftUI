//
//  BloomFilter.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// A probabilistic data structure used to test whether an element is a member of a set.
///
/// A Bloom filter is a space-efficient probabilistic data structure that is used to test
/// whether an element is a member of a set. False positives are possible, but false negatives
/// are not. Elements can be added to the set, but not removed.
///
/// This implementation uses a simple bit array represented as a UInt and a hash function
/// to set 3 different bits for each added element.
package struct BloomFilter: Equatable {
    /// The internal bit representation of the Bloom filter.
    package var value: UInt
    
    /// Creates an empty Bloom filter.
    @inlinable
    package init() {
        value = 0
    }
    
    /// Creates a Bloom filter containing a single hashable value.
    ///
    /// - Parameter value: The hashable value to add to the filter.
    @inlinable
    package init<T>(value: T) where T : Hashable {
        self.init(hashValue: value.hashValue)
    }
    
    /// Creates a Bloom filter containing a specific type.
    ///
    /// - Parameter type: The type to add to the filter.
    @inlinable
    package init(type: any Any.Type) {
        let pointer = unsafeBitCast(type, to: OpaquePointer.self)
        self.init(hashValue: Int(bitPattern: pointer))
    }
    
    /// Adds the elements of another Bloom filter to this filter.
    ///
    /// - Parameter other: Another Bloom filter to combine with this one.
    @inlinable
    package mutating func formUnion(_ other: BloomFilter) {
        value |= other.value
    }
    
    /// Returns a new Bloom filter containing the elements of both this filter and another.
    ///
    /// - Parameter other: Another Bloom filter to combine with this one.
    /// - Returns: A new Bloom filter containing the elements of both filters.
    @inlinable
    package func union(_ other: BloomFilter) -> BloomFilter {
        var value = self
        value.formUnion(other)
        return value
    }
    
    /// Tests whether another Bloom filter might be contained in this one.
    ///
    /// Due to the probabilistic nature of Bloom filters, this method may return true
    /// even when the other filter is not actually a subset (false positive). However,
    /// if it returns false, then the other filter definitely contains elements not in this one.
    ///
    /// - Parameter other: Another Bloom filter to test against this one.
    /// - Returns: `true` if the other filter might be contained in this one, `false` if it definitely is not.
    @inlinable
    package func mayContain(_ other: BloomFilter) -> Bool {
        (other.value & ~value) == 0
    }
    
    /// Indicates whether the Bloom filter is empty (contains no elements).
    ///
    /// - Returns: `true` if the filter is empty, `false` otherwise.
    @inlinable
    package var isEmpty: Bool {
        value == 0
    }
    
    /// Creates a Bloom filter using a hash value.
    ///
    /// This initializer sets 3 different bits in the filter based on different parts of the hash value.
    ///
    /// - Parameter hashValue: The hash value to use for bit selection.
    @inlinable
    init(hashValue: Int) {
        // Make sure we do LSR instead of ASR
        let value = UInt(bitPattern: hashValue)
        let bit0 = 1 &<< (value &>> 0x10)
        let bit1 = 1 &<< (value &>> 0xa)
        let bit2 = 1 &<< (value &>> 0x4)
        self.value = bit0 | bit1 | bit2
    }
}
