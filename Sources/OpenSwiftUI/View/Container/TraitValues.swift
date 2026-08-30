//
//  TraitValues.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 060FAB9317997EA3883A746361D6FAB7 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore

@_spi(DoNotImportVariadicView)
@available(*, deprecated, renamed: "ContainerValues")
public struct TraitValues {
    package var base: ViewTraitCollection

    package init(base: ViewTraitCollection) {
        self.base = base
    }

    public subscript<Trait>(key: Trait.Type) -> Trait.Value where Trait: _ViewTraitKey {
        get { base[key] }
        set { base[key] = newValue }
    }
}

@_spi(DoNotImportVariadicView)
@available(*, unavailable)
extension TraitValues: Sendable {}

@_spi(DoNotImportVariadicView)
@available(*, deprecated, renamed: "ContainerValueKey")
public typealias TraitKey = _ViewTraitKey

@_spi(DoNotImportVariadicView)
@available(*, deprecated, renamed: "containerValue")
extension View {
    @_alwaysEmitIntoClient
    nonisolated public func trait<V>(
        _ keyPath: WritableKeyPath<TraitValues, V>,
        _ value: V
    ) -> some View {
        modifier(_TraitKeyWritingModifier(keyPath: keyPath, value: value))
    }
}

@_spi(DoNotImportVariadicView)
@available(OpenSwiftUI_v6_0, *)
extension View {
    @available(*, deprecated, message: "Use overload which takes a keypath with no argument labels instead.")
    @_alwaysEmitIntoClient
    nonisolated public func trait<K>(
        key: K.Type,
        value: K.Value
    ) -> some View where K: _ViewTraitKey {
        modifier(_TraitWritingModifier<K>(value: value))
    }
}

@_spi(DoNotImportVariadicView)
@available(*, deprecated, renamed: "_ContainerValueWritingModifier")
@frozen
@MainActor
@preconcurrency
public struct _TraitKeyWritingModifier<Value>: PrimitiveViewModifier {
    public var keyPath: WritableKeyPath<TraitValues, Value>

    public var value: Value

    @_alwaysEmitIntoClient
    public init(
        keyPath: WritableKeyPath<TraitValues, Value>,
        value: Value
    ) {
        self.keyPath = keyPath
        self.value = value
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        body(_Graph(), inputs)
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var newInputs = inputs
        let addTrait = AddTrait(
            modifier: modifier.value,
            traits: OptionalAttribute(inputs.traits)
        )
        newInputs.traits = Attribute(addTrait)
        newInputs.traitKeys = nil
        return body(_Graph(), newInputs)
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }

    private struct AddTrait: Rule, AsyncAttribute {
        @Attribute var modifier: _TraitKeyWritingModifier
        @OptionalAttribute var traits: ViewTraitCollection?

        var value: ViewTraitCollection {
            var values = TraitValues(base: traits ?? ViewTraitCollection())
            values[keyPath: modifier.keyPath] = modifier.value
            return values.base
        }
    }
}

@_spi(DoNotImportVariadicView)
@available(*, unavailable)
extension _TraitKeyWritingModifier: Sendable {}
