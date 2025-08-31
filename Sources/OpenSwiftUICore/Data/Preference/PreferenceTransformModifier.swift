//
//  PreferenceTransformModifier.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: D3405DB583003A73D556A7797845B7F4 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - PreferenceTransformModifier [6.4.41]

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _PreferenceTransformModifier<Key>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Key: PreferenceKey {
    public var transform: (inout Key.Value) -> Void

    public typealias Body = Never

    @inlinable
    public init(
        key _: Key.Type = Key.self,
        transform: @escaping (inout Key.Value) -> Void
    ) {
        self.transform = transform
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: Key.self,
            transform: modifier.value.transform
        )
        return outputs
    }
}

@available(*, unavailable)
extension _PreferenceTransformModifier: Sendable {}

extension View {
    @inlinable
    nonisolated public func transformPreference<K>(
        _ key: K.Type = K.self,
        _ callback: @escaping (inout K.Value) -> Void
    ) -> some View where K: PreferenceKey {
        modifier(_PreferenceTransformModifier<K>(transform: callback))
    }
}

// MARK: - PreferencesOutputs + makePreferenceTransformer [6.0.87]

extension PreferencesOutputs {
    package mutating func makePreferenceTransformer<K>(
        inputs: PreferencesInputs,
        key: K.Type,
        transform: @autoclosure () -> Attribute<(inout K.Value) -> Void>
    ) where K: PreferenceKey {
        let contains = inputs.contains(K.self)
        let transformValue: Attribute<(inout K.Value) -> Void>!
        if contains {
            transformValue = transform()
            let transform = PreferenceTransform<K>(
                transform: transformValue,
                childValue: OptionalAttribute(self[key])
            )
            self[key] = Attribute(transform)
        } else {
            transformValue = nil
        }
        guard K._isReadableByHost, inputs.contains(HostPreferencesKey.self) else {
            return
        }
        let hostTransform = HostPreferencesTransform<K>(
            transform: transformValue ?? transform(),
            keys: inputs.hostKeys,
            childValues: OptionalAttribute(self[HostPreferencesKey.self]),
            keyRequested: false,
            wasEmpty: false,
            delta: 0,
            nodeId: HostPreferencesKey.makeNodeId()
        )
        self[HostPreferencesKey.self] = Attribute(hostTransform)
    }
}

// MARK: - PreferenceTransform [6.5.4]

private struct PreferenceTransform<K>: Rule, AsyncAttribute, CustomStringConvertible where K: PreferenceKey {
    @Attribute var transform: (inout K.Value) -> Void
    @OptionalAttribute var childValue: K.Value?

    var value: K.Value {
        var value = childValue ?? K.defaultValue
        $transform.syncMainIfReferences { transform in
            withObservation {
                transform(&value)
            }
        }
        return value
    }

    var description: String {
        "Transform: \(K.readableName)"
    }
}

// MARK: - HostPreferencesTransform [6.0.87]

private struct HostPreferencesTransform<K>: StatefulRule, AsyncAttribute, CustomStringConvertible where K: PreferenceKey {
    @Attribute var transform: (inout K.Value) -> Void
    @Attribute var keys: PreferenceKeys
    // FIXME:  [6.4.41]
    // @OptionalAttribute var childValues: PreferenceValues?
    @OptionalAttribute var childValues: PreferenceList?
    var keyRequested: Bool
    var wasEmpty: Bool
    var delta: UInt32
    let nodeId: UInt32

    typealias Value = PreferenceList

    mutating func updateValue() {
        var values: PreferenceList
        let valuesChanged: Bool
        if let childValues = $childValues {
            (values, valuesChanged) = childValues.changedValue()
            wasEmpty = false
        } else {
            (values, valuesChanged) = (PreferenceList(), !wasEmpty)
            wasEmpty = true
        }
        var requiresUpdate = valuesChanged
        let (keys, keysChanged) = $keys.changedValue()

        let keyContains = keysChanged ? keys.contains(K.self) : false
        if keyRequested != keyContains {
            keyRequested = keyContains
            requiresUpdate = true
        }
        if keyRequested {
            let anyInputsChanged = Graph.anyInputsChanged(excluding: [_keys.identifier, _childValues.base.identifier])
            if anyInputsChanged {
                delta &+= 1
                requiresUpdate = true
            }
            if anyInputsChanged || requiresUpdate {
                $transform.syncMainIfReferences { transform in
                    let transformValue = PreferenceList.Value(value: transform, seed: VersionSeed(nodeId: nodeId, viewSeed: delta))
                    values.modifyValue(for: K.self, transform: transformValue)
                }
            }
        }
        if requiresUpdate || !hasValue {
            value = values
        }
    }

    var description: String {
        "HostTransform: \(K.readableName)"
    }
}
