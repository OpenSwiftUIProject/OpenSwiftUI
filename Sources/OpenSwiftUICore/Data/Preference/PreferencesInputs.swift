//
//  PreferencesInputs.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenAttributeGraphShims

package struct PreferencesInputs {
    package var keys: PreferenceKeys
    package var hostKeys: Attribute<PreferenceKeys>
    
    @inlinable
    package init(hostKeys: Attribute<PreferenceKeys>) {
        self.keys = PreferenceKeys()
        self.hostKeys = hostKeys
    }
    
    @inlinable
    package mutating func remove<K>(_ key: K.Type) where K: PreferenceKey {
        keys.remove(key)
    }

    @inlinable
    package mutating func add<K>(_ key: K.Type) where K: PreferenceKey {
        keys.add(key)
    }
    
    @inlinable
    package func contains<K>(_ key: K.Type) -> Bool where K: PreferenceKey {
        keys.contains(key)
    }
    
    @inlinable
    package func contains<K>(_ key: K.Type, includeHostPreferences: Bool) -> Bool where K: PreferenceKey {
        let result = contains(key)
        guard !result, includeHostPreferences else {
            return result
        }
        return K._isReadableByHost && contains(HostPreferencesKey.self)
    }
    
    package func makeIndirectOutputs() -> PreferencesOutputs {
        var outputs = PreferencesOutputs()
        for key in keys {
            func project<K>(_ key: K.Type) where K: PreferenceKey {
                let source = ViewGraph.current.intern(key.defaultValue, id: .preferenceKeyDefault)
                outputs.appendPreference(key: key, value: IndirectAttribute(source: source).projectedValue)
            }
            project(key)
        }
        return outputs
    }
}
