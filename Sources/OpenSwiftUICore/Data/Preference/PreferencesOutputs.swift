//
//  PreferencesOutputs.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenGraphShims

package struct PreferencesOutputs {
    private var preferences: [KeyValue]
    package var debugProperties: _ViewDebug.Properties
    
    @inlinable
    package init() {
        preferences = []
        debugProperties = []
    }
    
    #if canImport(Darwin)
    subscript(anyKey key: AnyPreferenceKey.Type) -> AnyAttribute? {
        get { preferences.first { $0.key == key }?.value }
        set {
            if key == _AnyPreferenceKey<DisplayList.Key>.self {
                if !debugProperties.contains(.displayList) {
                    debugProperties.formUnion(.displayList)
                }
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
    #endif
    
    subscript<K>(key: K.Type) -> Attribute<K.Value>? where K: PreferenceKey {
        get {
            #if canImport(Darwin)
            let value = self[anyKey: _AnyPreferenceKey<K>.self]
            return value.map { Attribute(identifier: $0) }
            #else
            fatalError("See #39")
            #endif
        }
        set {
            #if canImport(Darwin)
            self[anyKey: _AnyPreferenceKey<K>.self] = newValue.map { $0.identifier }
            #else
            fatalError("See #39")
            #endif
        }
    }
    
    package mutating func appendPreference<K>(key: K.Type, value: Attribute<K.Value>) where K: PreferenceKey{
        #if canImport(Darwin)
        preferences.append(KeyValue(key: _AnyPreferenceKey<K>.self, value: value.identifier))
        #else
        fatalError("See #39")
        #endif
    }
    
    #if canImport(Darwin)
    package func forEachPreference(_ body: (any AnyPreferenceKey.Type, AnyAttribute) -> Void) {
        preferences.forEach { body($0.key, $0.value) }
    }
    #endif
    
    #if canImport(Darwin)
    package func setIndirectDependencies(_ dependency: AnyAttribute?) {
        preferences.forEach {
            $0.value.indirectDependency = dependency
        }
    }
    #endif
    
    package func attachIndirectOutputs(to childOutputs: PreferencesOutputs) {
        #if canImport(Darwin)
        for preference in preferences {
            for childPreference in childOutputs.preferences where childPreference.key == preference.key {
                preference.value.source = childPreference.value
            }
        }
        #endif
    }
    
    package func detachIndirectOutputs() {
        #if canImport(Darwin)
        struct ResetPreference: PreferenceKeyVisitor {
            var destination: AnyAttribute
            func visit<K>(key: K.Type) where K: PreferenceKey {
                destination.source = .nil
            }
        }
        for keyValue in preferences {
            var visitor = ResetPreference(destination: keyValue.value)
            keyValue.key.visitKey(&visitor)
        }
        #endif
    }
}

extension PreferencesOutputs {
    private struct KeyValue {
        var key: any AnyPreferenceKey.Type
        #if canImport(Darwin)
        var value: AnyAttribute
        #endif
    }
}
