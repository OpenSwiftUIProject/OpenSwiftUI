//
//  PreferencesOutputs.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: A948213B3F0A65E8491149A582CA5C71

internal import OpenGraphShims

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

    subscript(anyKey keyType: AnyPreferenceKey.Type) -> OGAttribute? {
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
    #else
    subscript<Key: PreferenceKey>(_: Key.Type) -> Attribute<Key.Value>? {
        get { fatalError("See #39") }
        set { fatalError("See #39") }
    }
    #endif
}

extension PreferencesOutputs {
    private struct KeyValue {
        var key: AnyPreferenceKey.Type
        #if canImport(Darwin) // FIXME: See #39
        var value: OGAttribute
        #endif
    }
}
