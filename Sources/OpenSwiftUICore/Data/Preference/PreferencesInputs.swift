//
//  PreferencesInputs.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenGraphShims

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
        let result = keys.contains(key)
        guard !result, includeHostPreferences else {
            return result
        }
        guard K._isReadableByHost else {
            return false
        }
        return keys.contains(_AnyPreferenceKey<HostPreferencesKey>.self)
    }
}
