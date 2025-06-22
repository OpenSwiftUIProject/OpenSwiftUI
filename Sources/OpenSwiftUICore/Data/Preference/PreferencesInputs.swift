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
        let result = contains(key)
        guard !result, includeHostPreferences else {
            return result
        }
        return K._isReadableByHost && contains(HostPreferencesKey.self)
    }
    
    package func makeIndirectOutputs() -> PreferencesOutputs {
        struct AddPreference: PreferenceKeyVisitor {
            var outputs: PreferencesOutputs
            
            mutating func visit<K>(key: K.Type) where K: PreferenceKey {
                let source = ViewGraph.current.intern(K.defaultValue, for: K.self, id: .preferenceKeyDefault)
                
                @IndirectAttribute(source: source)
                var indirect: K.Value
                
                outputs.appendPreference(key: K.self, value: $indirect)
            }
        }
        
        var visitor = AddPreference(outputs: PreferencesOutputs())
        for key in keys {
            key.visitKey(&visitor)
        }
        return visitor.outputs
    }
}
