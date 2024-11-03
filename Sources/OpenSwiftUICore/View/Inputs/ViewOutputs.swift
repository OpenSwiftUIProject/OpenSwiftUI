//
//  ViewOutputs.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

package import OpenGraphShims

/// The output (aka synthesized) attributes returned by each view.
public struct _ViewOutputs {
    package var preferences: PreferencesOutputs
    
    private var _layoutComputer: OptionalAttribute<LayoutComputer>
    
    init() {
        preferences = PreferencesOutputs()
        _layoutComputer = OptionalAttribute()
    }
    
    package var layoutComputer: Attribute<LayoutComputer>? {
        get {
            _layoutComputer.attribute
        }
        set {
            _layoutComputer = OptionalAttribute(newValue)
            if preferences.debugProperties.contains(.layoutComputer) {
                preferences.debugProperties.formUnion(.layoutComputer)
            }
        }
    }
    
    #if canImport(Darwin)
    package subscript(anyKey key: any AnyPreferenceKey.Type) -> AnyAttribute? {
        get { fatalError("TODO") }
        set { fatalError("TODO") }
    }
    #endif
    
    package subscript<K>(key: K.Type) -> Attribute<K.Value>? where K: PreferenceKey {
        get { preferences[key] }
        set { preferences[key] = newValue }
    }
    
    package mutating func appendPreference<K>(key: K.Type, value: Attribute<K.Value>) where K: PreferenceKey {
        preferences.appendPreference(key: key, value: value)
    }
    
    #if canImport(Darwin)
    package func forEachPreference(_ body: (any AnyPreferenceKey.Type, AnyAttribute) -> Void) {
        preferences.forEach(body: body)
    }
    #endif
}

@available(*, unavailable)
extension _ViewOutputs: Sendable {}

extension _ViewOutputs {
    // package func viewResponders: Attribute<[ViewResponder]> {}
}
