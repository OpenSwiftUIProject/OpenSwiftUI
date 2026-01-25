//
//  PreferenceTransformModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D3405DB583003A73D556A7797845B7F4 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - PreferenceTransformModifier

/// A modifier to apply a transform function to the value of a named
/// preference key.
@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _PreferenceTransformModifier<Key>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Key: PreferenceKey {

    /// The transform function to apply to `Key`.
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

// MARK: - View + transformPreference

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Applies a transformation to a preference value.
    @inlinable
    nonisolated public func transformPreference<K>(
        _ key: K.Type = K.self,
        _ callback: @escaping (inout K.Value) -> Void
    ) -> some View where K: PreferenceKey {
        modifier(_PreferenceTransformModifier<K>(transform: callback))
    }
}

// MARK: - PreferencesOutputs + makePreferenceTransformer

extension PreferencesOutputs {
    package mutating func makePreferenceTransformer<K>(
        inputs: PreferencesInputs,
        key: K.Type,
        transform: @autoclosure () -> Attribute<(inout K.Value) -> Void>
    ) where K: PreferenceKey {
        let attribute: Attribute<(inout K.Value) -> Void>!
        if inputs.contains(K.self) {
            attribute = transform()
            self[key] = Attribute(
                PreferenceTransform<K>(
                    transform: attribute,
                    childValue: .init(self[key])
                )
            )
        } else {
            attribute = nil
        }
        if K._isReadableByHost,
           inputs.contains(HostPreferencesKey.self) {
            self[HostPreferencesKey.self] = Attribute(
                HostPreferencesTransform<K>(
                    transform: attribute ?? transform(),
                    keys: inputs.hostKeys,
                    childValues: .init(self[HostPreferencesKey.self]),
                    keyRequested: false,
                    wasEmpty: false,
                    delta: 0,
                    nodeId: HostPreferencesKey.makeNodeId()
                )
            )
        }

    }
}

// MARK: - PreferenceTransform

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

// MARK: - HostPreferencesTransform

private struct HostPreferencesTransform<K>: StatefulRule, AsyncAttribute, CustomStringConvertible where K: PreferenceKey {
    @Attribute var transform: (inout K.Value) -> Void
    @Attribute var keys: PreferenceKeys
    @OptionalAttribute var childValues: PreferenceValues?
    var keyRequested: Bool
    var wasEmpty: Bool
    var delta: UInt32
    let nodeId: UInt32

    typealias Value = PreferenceValues

    mutating func updateValue() {
        var result: PreferenceValues
        let valuesChanged: Bool
        if let childValues = $childValues {
            (result, valuesChanged) = childValues.changedValue()
            wasEmpty = false
        } else {
            (result, valuesChanged) = (.init(), !wasEmpty)
            wasEmpty = true
        }
        var requiresUpdate = valuesChanged
        let (keys, keysChanged) = $keys.changedValue()
        if keysChanged {
            let keyContains = keys.contains(K.self)
            if keyRequested != keyContains {
                keyRequested = keyContains
                requiresUpdate = true
            }
        }
        if keyRequested {
            let anyInputsChanged = Graph.anyInputsChanged(excluding: [_keys.identifier, _childValues.base.identifier])
            if anyInputsChanged {
                delta &+= 1
                requiresUpdate = true
            }
            if anyInputsChanged || requiresUpdate {
                $transform.syncMainIfReferences { transform in
                    let transformValue = PreferenceValues.Value(value: transform, seed: VersionSeed(nodeId: nodeId, viewSeed: delta))
                    result.modifyValue(for: K.self, transform: transformValue)
                }
            }
        }
        if requiresUpdate || !hasValue {
            value = result
        }
    }

    var description: String {
        "HostTransform: \(K.readableName)"
    }
}
