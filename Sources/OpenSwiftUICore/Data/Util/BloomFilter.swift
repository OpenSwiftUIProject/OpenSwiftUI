//
//  BloomFilter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: EAD08B10536A579F94A338A4C016B0FF (SwiftUICore)

/// A probabilistic data structure used to test whether an element is a member of a set.
///
/// A Bloom filter is a space-efficient probabilistic data structure that is used to test
/// whether an element is a member of a set. False positives are possible, but false negatives
/// are not. Elements can be added to the set, but not removed.
///
/// This implementation uses a simple bit array represented as a UInt and a hash function
/// to set up to three bits for each added element.
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
    package init<T>(value: T) where T: Hashable {
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
    
    /// Returns whether this filter contains every bit set in `other`.
    ///
    /// Different inputs can set the same bits, so a match can be a false positive.
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
    
    private init(hashValue: Int) {
        let bits = UInt(bitPattern: hashValue)
        value = (1 &<< (bits >> 4)) | (1 &<< (bits >> 10)) | (1 &<< (bits >> 16))
    }
}
