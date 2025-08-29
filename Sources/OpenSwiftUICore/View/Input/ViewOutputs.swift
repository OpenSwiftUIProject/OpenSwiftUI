//
//  ViewOutputs.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenAttributeGraphShims

/// The output (aka synthesized) attributes returned by each view.
public struct _ViewOutputs {
    package var preferences: PreferencesOutputs

    private var _layoutComputer: OptionalAttribute<LayoutComputer>

    package var layoutComputer: Attribute<LayoutComputer>? {
        get {
            _layoutComputer.attribute
        }
        set {
            _layoutComputer.attribute = newValue
            preferences.debugProperties.insert(.layoutComputer)
        }
    }

    package init() {
        preferences = PreferencesOutputs()
        _layoutComputer = OptionalAttribute()
    }

    package subscript(anyKey key: any PreferenceKey.Type) -> AnyAttribute? {
        get { preferences[anyKey: key] }
        set { preferences[anyKey: key] = newValue }
    }

    package subscript<K>(key: K.Type) -> Attribute<K.Value>? where K: PreferenceKey {
        get { preferences[key] }
        set { preferences[key] = newValue }
    }

    package mutating func appendPreference<K>(key: K.Type, value: Attribute<K.Value>) where K: PreferenceKey {
        preferences.appendPreference(key: key, value: value)
    }

    package func forEachPreference(_ body: (any PreferenceKey.Type, AnyAttribute) -> Void) {
        preferences.forEachPreference(body)
    }
}

@available(*, unavailable)
extension _ViewOutputs: Sendable {}

extension _ViewOutputs {
    package func viewResponders() -> Attribute<[ViewResponder]> {
        self[ViewRespondersKey.self] ?? ViewGraph.current.intern([], for: [ViewResponder].self, id: .defaultValue)
    }
}
