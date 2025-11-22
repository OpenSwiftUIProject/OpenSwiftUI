//
//  ObjectCache.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FCB2944DC319042A861E82C8B244E212 (SwiftUICore)

/// A thread-safe cache that stores key-value pairs with automatic eviction.
///
/// `ObjectCache` implements a set-associative cache with LRU (Least Recently Used)
/// eviction policy. When a bucket is full and a new item needs to be inserted, the least
/// recently used item in that bucket is evicted.
///
/// For example:
///
///     let cache = ObjectCache<String, ExpensiveObject> { key in
///         ExpensiveObject(key: key)
///     }
///
///     let value = cache["myKey"]
///
final package class ObjectCache<Key, Value> where Key: Hashable {

    /// The constructor function used to create new values for cache misses.
    let constructor: (Key) -> Value

    /// The internal cache data structure, protected by atomic access.
    @AtomicBox
    private var data: Data

    /// Creates a new cache with the specified constructor function.
    ///
    /// - Parameter constructor: A closure that creates a value for a given key.
    ///   This closure is called when a key is accessed but not found in the cache.
    @inlinable
    package init(constructor: @escaping (Key) -> Value) {
        self.constructor = constructor
        self.data = Data()
    }

    /// Accesses the value associated with the given key.
    ///
    /// If the key exists in the cache, returns the cached value and updates its
    /// access time. If the key doesn't exist, calls the constructor to create a
    /// new value, stores it in the cache (potentially evicting the least recently
    /// used item in the same bucket), and returns the new value.
    ///
    /// - Parameter key: The key to look up.
    /// - Returns: The value associated with the key, either from cache or newly constructed.
    final package subscript(key: Key) -> Value {
        let hash = key.hashValue
        let bucket = (hash & (Data.bucketCount - 1)) * Data.waysPerBucket
        var targetOffset: Int = 0
        var diff: Int32 = Int32.min
        let value = $data.access { data -> Value? in
            for offset in 0 ..< Data.waysPerBucket {
                let index = bucket + offset
                if let itemData = data.table[index].data {
                    if itemData.hash == hash, itemData.key == key {
                        data.clock &+= 1
                        data.table[index].used = data.clock
                        return itemData.value
                    } else {
                        let dist = Int32(bitPattern: data.clock &- data.table[index].used)
                        if diff < dist {
                            targetOffset = offset
                            diff = dist
                        }
                    }
                } else {
                    if diff != Int32.max {
                        targetOffset = offset
                        diff = Int32.max
                    }
                }
            }
            return nil
        }
        if let value {
            return value
        } else {
            let value = constructor(key)
            $data.access { data in
                data.clock += 1
                data.table[bucket + targetOffset] = Item(data: (key, hash, value), used: data.clock)
            }
            return value
        }
    }

    /// A cache slot that can hold an item or be empty.
    ///
    /// Each slot tracks when it was last used via the `used` timestamp, which is
    /// compared against the global `clock` to determine the least recently used item.
    private struct Item {

        /// The cached data tuple containing the key, hash, and value, or nil if empty.
        var data: (key: Key, hash: Int, value: Value)?

        /// The clock value when this item was last accessed or inserted.
        ///
        /// This timestamp is used for LRU eviction. When a bucket is full, the item
        /// with the smallest `used` value (i.e., the one with the largest time distance
        /// from the current clock) is evicted.
        var used: UInt32

        init(data: (key: Key, hash: Int, value: Value)?, used: UInt32) {
            self.data = data
            self.used = used
        }
    }

    /// The internal data structure holding the cache table and global clock.
    private struct Data {

        /// The number of buckets in the cache.
        ///
        /// The cache uses 8 buckets to distribute keys based on their hash values.
        /// Each bucket can hold multiple items (ways) for collision resolution.
        static var bucketCount: Int { 8 }

        /// The number of ways (slots) per bucket.
        ///
        /// Each bucket contains 4 ways, implementing a 4-way set-associative cache.
        /// When all ways in a bucket are full, the least recently used item is evicted.
        static var waysPerBucket: Int { 4 }

        /// The total number of slots in the cache table.
        ///
        /// Computed as `bucketCount × waysPerBucket`, resulting in 32 total cache slots.
        static var tableSize: Int { bucketCount * waysPerBucket }

        /// The hash table with 32 slots (8 buckets × 4 ways per bucket).
        var table: [Item]

        /// A monotonically increasing counter used for LRU tracking.
        ///
        /// The `clock` is incremented on every cache access (hit or miss). Each item's
        /// `used` field stores the clock value at its last access. When eviction is needed,
        /// the item with the oldest `used` value (largest difference from current clock)
        /// is selected for replacement.
        ///
        /// This implements a pseudo-LRU policy that efficiently approximates true LRU
        /// without maintaining a global ordering of all items.
        var clock: UInt32

        init() {
            self.table = Array(repeating: Item(data: nil, used: 0), count: Self.tableSize)
            self.clock = 0
        }
    }
}

#if DEBUG
extension ObjectCache: CustomDebugStringConvertible {
    package var debugDescription: String {
        $data.access { data in
            var description = "ObjectCache(clock: \(data.clock), items: \(data.table.filter { $0.data != nil }.count)/\(Data.tableSize))\n"
            for (index, item) in data.table.enumerated() {
                if let itemData = item.data {
                    let bucket = index / Data.waysPerBucket
                    let offset = index % Data.waysPerBucket
                    let age = data.clock &- item.used
                    description += "  [\(bucket):\(offset)] hash=\(itemData.hash), used=\(item.used), age=\(age)\n"
                }
            }
            return description
        }
    }
}

extension ObjectCache {
    package var count: Int {
        $data.access { data in
            data.table.filter { $0.data != nil }.count
        }
    }

    package var currentClock: UInt32 {
        $data.access { data in
            data.clock
        }
    }

    package var keys: [Key] {
        $data.access { data in
            data.table.compactMap { $0.data?.key }
        }
    }

    package func reset() {
        $data.access { data in
            data.table = Array(repeating: Item(data: nil, used: 0), count: Data.tableSize)
            data.clock = 0
        }
    }
}
#endif
