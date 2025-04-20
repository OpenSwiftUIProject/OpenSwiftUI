//
//  Cache3.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// A simple fixed-size cache that stores up to three key-value pairs.
///
/// Cache3 provides a lightweight, efficient cache implementation with LRU (Least Recently Used)
/// eviction behavior. When a new item is added to a full cache, the oldest item is evicted.
///
/// Example usage:
///
///     var cache = Cache3<String, Int>()
///     cache.put("one", value: 1)
///     cache.put("two", value: 2)
///     let value = cache.get("three") { 3 }  // Creates and caches value 3
///
package struct Cache3<Key, Value> where Key: Equatable {
    /// Internal tuple-based storage for the cached items.
    /// The first element represents the most recently used item.
    var store: ((key: Key, value: Value)?, (key: Key, value: Value)?, (key: Key, value: Value)?)

    /// Creates a new empty cache.
    package init() {
        self.store = (nil, nil, nil)
    }

    /// Looks up a value in the cache by key without changing cache order.
    ///
    /// - Parameter key: The key to look up.
    /// - Returns: The value associated with the key, or `nil` if the key is not in the cache.
    @inline(__always)
    package func find(_ key: Key) -> Value? {
        if let item = store.0, item.key == key {
            return item.value
        }
        if let item = store.1, item.key == key {
            return item.value
        }
        if let item = store.2, item.key == key {
            return item.value
        }
        return nil
    }

    /// Inserts a new value into the cache with the specified key.
    ///
    /// This method adds a new key-value pair to the cache, making it the most recently used item.
    /// If the cache already has 3 items, the least recently used item is evicted.
    ///
    /// - Parameters:
    ///   - key: The key to associate with the value.
    ///   - value: The value to cache.
    @inline(__always)
    package mutating func put(_ key: Key, value: Value) {
        store =  ((key, value), store.0, store.1)
    }

    /// Retrieves a value from the cache by key, creating it if not present.
    ///
    /// This method first checks if the key exists in the cache. If found, it returns the
    /// associated value. If not found, it calls the provided closure to create a new value,
    /// caches it, and returns the newly created value.
    ///
    /// - Parameters:
    ///   - key: The key to look up.
    ///   - makeValue: A closure that creates a new value if the key is not found.
    /// - Returns: The value associated with the key, either retrieved from cache or newly created.
    @inline(__always)
    package mutating func get(_ key: Key, makeValue: () -> Value) -> Value {
        guard let value = find(key) else {
            let value = makeValue()
            put(key, value: value)
            return value
        }
        return value
    }
}
