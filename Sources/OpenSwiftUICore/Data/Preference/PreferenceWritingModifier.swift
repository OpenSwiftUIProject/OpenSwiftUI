//
//  PreferenceWritingModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 62AFEFEED1A7034F09E120B80AB01BF9 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - _PreferenceWritingModifier

@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _PreferenceWritingModifier<Key>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Key: PreferenceKey {

    public var value: Key.Value

    @inlinable
    public init(key: Key.Type = Key.self, value: Key.Value) {
        self.value = value
    }

    nonisolated public  static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        inputs.preferences.remove(Key.self)
        var outputs = body(_Graph(), inputs)
        outputs.preferences
            .makePreferenceWriter(
                inputs: inputs.preferences,
                key: Key.self,
                value: modifier.value[offset: { .of(&$0.value) }]
            )
        return outputs
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        if Semantics.PreviewPreferredColorScheme.isEnabled,
           inputs.options.contains(.previewContext),
           let metadata = Self.self as? _PreferenceWritingModifier<PreferredColorSchemeKey>.Type,
           let modifier = modifier as? _GraphValue<_PreferenceWritingModifier<PreferredColorSchemeKey>> {
            return metadata.makePreviewColorSchemeList(modifier: modifier, inputs: inputs, body: body)
        } else {
            return makeMultiViewList(modifier: modifier, inputs: inputs, body: body)
        }
    }
}

@available(*, unavailable)
extension _PreferenceWritingModifier: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension _PreferenceWritingModifier: Equatable where Key.Value: Equatable {
    nonisolated public static func == (a: _PreferenceWritingModifier<Key>, b: _PreferenceWritingModifier<Key>) -> Bool {
        a.value == b.value
    }
}

// MARK: - View + preference

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Sets a value for the given preference.
    @inlinable
    public func preference<K>(key: K.Type = K.self, value: K.Value) -> some View where K : PreferenceKey {
        modifier(_PreferenceWritingModifier<K>(value: value))
    }
}

// MARK: - PreferencesOutputs + Writer

extension PreferencesOutputs {
    package mutating func makePreferenceWriter<K>(
        inputs: PreferencesInputs,
        key _: K.Type,
        value: @autoclosure () -> Attribute<K.Value>
    ) where K: PreferenceKey {
        let attribute: Attribute<K.Value>!
        if inputs.contains(K.self) {
            attribute = value()
            self[K.self] = attribute
        } else {
            attribute = nil
        }
        if K._isReadableByHost,
           inputs.contains(HostPreferencesKey.self) {
            self[HostPreferencesKey.self] = Attribute(
                HostPreferencesWriter<K>(
                    keyValue: attribute ?? value(),
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

// TODO: - View + truePreference

// TODO: - Gesture + truePreference

// MARK: - HostPreferencesWriter [WIP]

private struct HostPreferencesWriter<Key>: StatefulRule, AsyncAttribute, CustomStringConvertible where Key: PreferenceKey {

    @Attribute var keyValue: Key.Value
    @Attribute var keys: PreferenceKeys
    @OptionalAttribute var childValues: PreferenceList?
    var keyRequested: Bool
    var wasEmpty: Bool
    var delta: UInt32
    let nodeId: UInt32

    // FIXME
    typealias Value = PreferenceList

    func updateValue() {

    }

    var description: String {
        "TODO"
    }
}
