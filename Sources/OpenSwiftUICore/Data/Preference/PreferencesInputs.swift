//
//  PreferencesInputs.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

import OpenGraphShims

struct PreferencesInputs {
    private(set) var keys: PreferenceKeys
    var hostKeys: Attribute<PreferenceKeys>
    
    @inline(__always)
    init(hostKeys: Attribute<PreferenceKeys>) {
        self.keys = PreferenceKeys()
        self.hostKeys = hostKeys
    }

    mutating func add<Key: PreferenceKey>(_ key: Key.Type) {
        keys.add(key)
    }
    
    mutating func remove<Key: PreferenceKey>(_ key: Key.Type) {
        keys.remove(key)
    }
    
    func contains<Key: PreferenceKey>(_ key: Key.Type) -> Bool {
        keys.contains(key)
    }
    
    @inline(__always)
    mutating func merge(_ preferenceKeys: PreferenceKeys) {
        // keys.merge(preferenceKeys)
    }
}
