//
//  Cache3.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

// MARK: - Cache3

package struct Cache3<K, V> where K: Equatable {
    var store: ((key: K, value: V)?, (key: K, value: V)?, (key: K, value: V)?)

    init() {
        self.store = (nil, nil, nil)
    }

    package func find(_ key: K) -> V? {
        for item in [store.0, store.1, store.2] {
            if let item = item, item.key == key {
                return item.value
            }
        }
        return nil
    }

    package mutating func put(_ key: K, value: V) {
        (store.0, store.1, store.2) = ((key, value), store.0, store.1)
    }

    package mutating func get(_ key: K, makeValue: () -> V) -> V {
        if let value = find(key) {
            return value
        }
        let value = makeValue()
        put(key, value: value)
        return value
    }
    
}
