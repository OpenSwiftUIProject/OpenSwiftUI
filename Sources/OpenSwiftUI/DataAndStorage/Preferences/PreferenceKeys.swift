//
//  PreferenceKeys.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/2/2.
//  Lastest Version: iOS 15.5
//  Status: Complete

struct PreferenceKeys {
    private var keys: [AnyPreferenceKey.Type]
    
    init() {
        self.keys = []
    }
}

extension PreferenceKeys: RandomAccessCollection, MutableCollection {
    var startIndex: Int { keys.startIndex }
    var endIndex: Int { keys.endIndex }
    
    mutating func add<Key: PreferenceKey>(_: Key.Type) {
        keys.append(_AnyPreferenceKey<Key>.self)
    }
    
    mutating func add(_ key: AnyPreferenceKey.Type) {
        keys.append(key)
    }
    
    func contains<Key: PreferenceKey>(_: Key.Type) -> Bool {
        contains(_AnyPreferenceKey<Key>.self)
    }
    
    func contains(_ key: AnyPreferenceKey.Type) -> Bool {
        keys.contains { $0 == key }
    }
    
    mutating func remove<Key: PreferenceKey>(_: Key.Type) {
        remove(_AnyPreferenceKey<Key>.self)
    }
    
    mutating func remove(_ key: AnyPreferenceKey.Type) {
        for index in keys.indices {
            if keys[index] == key {
                keys.remove(at: index)
                return
            }
        }
    }
    
    var isEmpty: Bool { keys.isEmpty }

    subscript(position: Int) -> AnyPreferenceKey.Type {
        get { keys[position] }
        set { keys[position] = newValue }
    }
}

extension PreferenceKeys: Equatable {
    static func == (lhs: PreferenceKeys, rhs: PreferenceKeys) -> Bool {
        guard lhs.keys.count == rhs.keys.count else {
            return false
        }
        guard !lhs.keys.isEmpty else {
            return true
        }
        for index in lhs.indices {
            guard lhs[index] == rhs[index] else {
                return false
            }
        }
        return true
    }
}
