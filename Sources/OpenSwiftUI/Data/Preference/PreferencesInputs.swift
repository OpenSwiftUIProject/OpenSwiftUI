//
//  PreferencesInputs.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import OpenGraphShims

struct PreferencesInputs {
    var keys: PreferenceKeys
    var hostKeys: Attribute<PreferenceKeys>

    mutating func add<Key: PreferenceKey>(_ key: Key.Type) {
        keys.add(key)
    }
    
    mutating func remove<Key: PreferenceKey>(_ key: Key.Type) {
        keys.remove(key)
    }
    
    func contains<Key: PreferenceKey>(_ key: Key.Type) -> Bool {
        keys.contains(key)
    }
}
