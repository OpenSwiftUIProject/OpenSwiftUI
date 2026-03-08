//
//  PreferencesOutputs.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 639FD567E11A491423DEEA5A95A52B4C (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - PreferencesOutputs [6.5.4]

package struct PreferencesOutputs {
    private var preferences: [KeyValue]
    package var debugProperties: _ViewDebug.Properties
    
    @inlinable
    package init() {
        preferences = []
        debugProperties = []
    }
    
    package subscript(anyKey key: any PreferenceKey.Type) -> AnyAttribute? {
        get {
            for preference in preferences {
                guard preference.key == key else {
                    continue
                }
                return preference.value
            }
            return nil
        }
        set {
            if key == DisplayList.Key.self {
                debugProperties.insert(.displayList)
            }
            if let index = preferences.firstIndex(where: { $0.key == key }) {
                if let newValue {
                    preferences[index].value = newValue
                } else {
                    preferences.remove(at: index)
                }
            } else {
                newValue.map {
                    preferences.append(KeyValue(key: key, value: $0))
                }
            }
        }
    }

    package subscript<K>(key: K.Type) -> Attribute<K.Value>? where K: PreferenceKey {
        get {
            let value = self[anyKey: key]
            return value.map { Attribute(identifier: $0) }
        }
        set {
            self[anyKey: key] = newValue.map { $0.identifier }
        }
    }
    
    package mutating func appendPreference<K>(key: K.Type, value: Attribute<K.Value>) where K: PreferenceKey{
        preferences.append(KeyValue(key: key, value: value.identifier))
    }

    package func forEachPreference(_ body: (any PreferenceKey.Type, AnyAttribute) -> Void) {
        preferences.forEach { body($0.key, $0.value) }
    }

    package func setIndirectDependency(_ dependency: AnyAttribute?) {
        preferences.forEach {
            $0.value.indirectDependency = dependency
        }
    }

    package func attachIndirectOutputs(to childOutputs: PreferencesOutputs) {
        for preference in preferences {
            for childPreference in childOutputs.preferences where childPreference.key == preference.key {
                preference.value.source = childPreference.value
            }
        }
    }
    
    package func detachIndirectOutputs() {
        for keyValue in preferences {
            keyValue.value.source = .nil
        }
    }
}

extension PreferencesOutputs {
    private struct KeyValue {
        var key: any PreferenceKey.Type
        var value: AnyAttribute
    }
}
