//
//  GestureOutputs.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import OpenAttributeGraphShims

// MARK: - GestureOutputs [6.5.4]

/// Output (aka synthesized) attributes for gesture objects.
@available(OpenSwiftUI_v1_0, *)
public struct _GestureOutputs<Value> {
    package var phase: Attribute<GesturePhase<Value>>

    private var _debugData: OptionalAttribute<GestureDebug.Data>

    package var preferences: PreferencesOutputs

    package var debugData: Attribute<GestureDebug.Data>? {
        get { _debugData.attribute }
        set { _debugData.attribute = newValue }
    }

    package init(phase: Attribute<GesturePhase<Value>>) {
        self.phase = phase
        self._debugData = .init()
        self.preferences = .init()
    }

    package func withPhase<T>(_ phase: Attribute<GesturePhase<T>>) -> _GestureOutputs<T> {
        var outputs = _GestureOutputs<T>(phase: phase)
        outputs._debugData = _debugData
        outputs.preferences = preferences
        return outputs
    }

    package func overrideDefaultValues(_ childOutputs: _GestureOutputs<Value>) {
        phase.overrideDefaultValue(childOutputs.phase, type: GesturePhase<Value>.self)
        if let debugData, let childDebugData = childOutputs.debugData {
            debugData.overrideDefaultValue(childDebugData, type: GestureDebug.Data.self)
        }
        preferences.attachIndirectOutputs(to: childOutputs.preferences)
    }

    package func setIndirectDependency(_ dependency: AnyAttribute?) {
        phase.identifier.indirectDependency = dependency
        if let debugData {
            debugData.identifier.indirectDependency = dependency
        }
        preferences.setIndirectDependency(dependency)
    }

    package func attachIndirectOutputs(_ childOutputs: _GestureOutputs<Value>) {
        phase.identifier.source = childOutputs.phase.identifier
        if let debugData, let childDebugData = childOutputs.debugData {
            debugData.identifier.source = childDebugData.identifier
        }
        preferences.attachIndirectOutputs(to: childOutputs.preferences)
    }

    package func detachIndirectOutputs() {
        phase.identifier.source = .nil
        if let debugData {
            debugData.identifier.source = .nil
        }
        preferences.detachIndirectOutputs()
    }

    package subscript(anyKey key: any PreferenceKey.Type) -> AnyAttribute? {
        get { preferences[anyKey: key] }
        set { preferences[anyKey: key] = newValue }
    }

    package subscript<K>(key: K.Type) -> Attribute<K.Value>? where K: PreferenceKey {
        get { preferences[key] }
        set { preferences[key] = newValue }
    }

    package mutating func appendPreference<K>(
        key: K.Type,
        value: Attribute<K.Value>
    ) where K: PreferenceKey {
        preferences.appendPreference(key: key, value: value)
    }

    package func forEachPreference(_ body: (any PreferenceKey.Type, AnyAttribute) -> Void) {
        preferences.forEachPreference(body)
    }
}
