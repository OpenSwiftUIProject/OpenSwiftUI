//
//  PreferenceValues.swift
//  OpenSwiftUICore

import Foundation

// NOTE: PreferenceValues is a replacement for PreferenceList on 6.4.41

// MARK: - PreferenceValues [6.4.41] [WIP]

package struct PreferenceValues {
    private var entries: [Entry]

    @inlinable
    package init() {
        entries = []
    }

    package struct Value<T> {
        package var value: T
        package var seed: VersionSeed

        package init(value: T, seed: VersionSeed) {
            self.value = value
            self.seed = seed
        }
    }

    package subscript<K>(key: K.Type) -> Value<K.Value> where K: PreferenceKey {
        get {
            guard let value = index(of: key).map({ (index: Int) -> Value<K.Value> in
                entries[index][]
            }) else {
                return Value(value: key.defaultValue, seed: .empty)
            }
            return value
        }
        set {
            let index = _index(of: key)
            setValue(newValue, of: key, at: index)
        }
    }

    package func valueIfPresent<K>(for key: K.Type = K.self) -> Value<K.Value>? where K: PreferenceKey {
        index(of: key).map { (index: Int) -> Value<K.Value> in
            entries[index][]
        }
    }

    private func index<K>(of key: K.Type) -> Int? where K: PreferenceKey {
        let index = _index(of: key)
        guard index != entries.count, entries[index].key == key else {
            return nil
        }
        return index
    }

    private func _index(of key: any PreferenceKey.Type) -> Int {
        guard !entries.isEmpty else {
            return 0
        }
        return entries.partitionPoint { entry in
            entry.key == key
        }
    }

    private func setValue<T>(_ value: Value<T>, of key: any PreferenceKey.Type, at index: Int) {
        // TODO
    }
}

extension PreferenceValues {
    private struct Entry {
        var key: any PreferenceKey.Type
        var seed: VersionSeed
        var value: Any

        subscript<V>() -> Value<V> {
            Value(value: value as! V, seed: seed)
        }
    }
}
