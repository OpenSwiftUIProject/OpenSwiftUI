//
//  PreferenceTransformModifier.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: D3405DB583003A73D556A7797845B7F4 (SwiftUICore)

package import OpenGraphShims

// MARK: - PreferenceTransformModifier [6.4.41] [WIP]

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

extension PreferencesOutputs {
    package mutating func makePreferenceTransformer<K>(
        inputs: PreferencesInputs,
        key _: K.Type,
        transform: @autoclosure () -> Attribute<(inout K.Value) -> Void>
    ) where K: PreferenceKey {
        openSwiftUIUnimplementedWarning()
    }
}

// TODO
private struct PreferenceTransform<K> where K: PreferenceKey {
    @Attribute var transform: (inout K.Value) -> Void
    @OptionalAttribute var childValue: K.Value?
}

// TODO
private struct HostPreferencesTransform<K> where K: PreferenceKey {
    @Attribute var transform: (inout K.Value) -> Void
    @Attribute var keys: Attribute<PreferenceKeys>
    @OptionalAttribute var childValues: PreferenceValues?
    var keyRequested: Bool
    var wasEmpty: Bool
    var delta: UInt32
    let nodeId: UInt32
}
