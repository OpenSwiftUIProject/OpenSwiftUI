//
//  PreferencesOutputs.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete
//  ID: A948213B3F0A65E8491149A582CA5C71

import OpenGraphShims

struct PreferencesOutputs {
    private var preferences: [KeyValue] = []
    private var debugProperties: _ViewDebug.Properties = []

    func contains<Key: PreferenceKey>(_: Key.Type) -> Bool {
        contains(_AnyPreferenceKey<Key>.self)
    }

    func contains(_ key: AnyPreferenceKey.Type) -> Bool {
        preferences.contains { $0.key == key }
    }

    #if canImport(Darwin) // FIXME: See #39
    subscript<Key: PreferenceKey>(_: Key.Type) -> Attribute<Key.Value>? {
        get {
            let value = self[anyKey: _AnyPreferenceKey<Key>.self]
            return value.map { Attribute(identifier: $0) }
        }
        set {
            self[anyKey: _AnyPreferenceKey<Key>.self] = newValue?.identifier
        }
    }

    subscript(anyKey keyType: AnyPreferenceKey.Type) -> AnyAttribute? {
        get { preferences.first { $0.key == keyType }?.value }
        set {
            if keyType == _AnyPreferenceKey<DisplayList.Key>.self {
                if !debugProperties.contains(.displayList) {
                    debugProperties.formUnion(.displayList)
                }
            }
            if let index = preferences.firstIndex(where: { $0.key == keyType }) {
                if let newValue {
                    preferences[index].value = newValue
                } else {
                    preferences.remove(at: index)
                }
            } else {
                if let newValue {
                    preferences.append(KeyValue(key: keyType, value: newValue))
                }
            }
        }
    }

    @inline(__always)
    func forEach(body: (
        _ key: AnyPreferenceKey.Type,
        _ value: AnyAttribute
    ) throws -> Void
    ) rethrows {
        try preferences.forEach { try body($0.key, $0.value) }
    }
    
    @inline(__always)
    func first(where predicate: (
        _ key: AnyPreferenceKey.Type,
        _ value: AnyAttribute
    ) throws -> Bool
    ) rethrows -> (key: AnyPreferenceKey.Type, value: AnyAttribute)? {
        try preferences
            .first { try predicate($0.key, $0.value) }
            .map { ($0.key, $0.value) }
    }
    
    #else
    subscript<Key: PreferenceKey>(_: Key.Type) -> Attribute<Key.Value>? {
        get { fatalError("See #39") }
        set { fatalError("See #39") }
    }
    #endif
    
    mutating func appendPreference<Key: PreferenceKey>(key: Key.Type, value: Attribute<Key.Value>) {
        #if canImport(Darwin)
        preferences.append(KeyValue(key: _AnyPreferenceKey<Key>.self, value: value.identifier))
        #endif
    }
}

extension PreferencesOutputs {
    private struct KeyValue {
        var key: AnyPreferenceKey.Type
        #if canImport(Darwin) // FIXME: See #39
        var value: AnyAttribute
        #endif
    }
}

extension _ViewOutputs {
    @inline(__always)
    var hostPreferences: Attribute<PreferenceList>? {
        get { self[HostPreferencesKey.self] }
        set { self[HostPreferencesKey.self] = newValue }
    }
}

extension PreferencesOutputs {
    @inline(__always)
    var hostPreferences: Attribute<PreferenceList>? {
        get { self[HostPreferencesKey.self] }
        set { self[HostPreferencesKey.self] = newValue }
    }
}
