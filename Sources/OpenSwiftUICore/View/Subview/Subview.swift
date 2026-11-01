//
//  Subview.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AC3F3B54DEA93347066C3491F9AA3DD4 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Subview

@available(OpenSwiftUI_v6_0, *)
public struct Subview: View, UnaryView, PrimitiveView, Identifiable {
    public struct ID: Hashable {
        let base: ViewList.ID
    }

    package var base: _VariadicView.Children.Element

    package init(_ base: _VariadicView.Children.Element) {
        self.base = base
    }

    public var id: ID {
        ID(base: base.view.subviewID)
    }

    public var containerValues: ContainerValues {
        ContainerValues(base: base.traits)
    }

    @_spi(DoNotImportVariadicView)
    @available(*, deprecated, message: "Use tag APIs on ContainerValues instead.")
    public func isSelected<V>(selection: V) -> Bool where V: Hashable {
        guard let tag = base.traits.tag(for: V.self) else {
            return false
        }
        return tag == selection
    }

    @_spi(DoNotImportVariadicView)
    @available(*, deprecated, message: "Use tag APIs on ContainerValues instead.")
    public func tagValue<V>(for type: V.Type) -> V? where V: Hashable {
        base.traits.tagValue(for: type)
    }

    package subscript<Trait>(key: Trait.Type) -> Trait.Value where Trait: _ViewTraitKey {
        base[key]
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let base = view[offset: { .of(&$0.base) }]
        return ViewList.View._makeView(
            view: base[offset: { .of(&$0.view) }],
            inputs: inputs
        )
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        inputs.traits = Attribute(MergeTraits(
            overrideTraits: view[offset: { .of(&$0.base.traits) }].value,
            baseTraits: OptionalAttribute(inputs.traits)
        ))
        return .unaryViewList(view: view, inputs: inputs)
    }
}

@available(*, unavailable)
extension Subview: Sendable {}

@available(*, unavailable)
extension Subview.ID: Sendable {}

// MARK: - Subview.ID + HasCustomIDRepresentation

extension Subview.ID: HasCustomIDRepresentation {
    func containsID<ID>(_ id: ID) -> Bool where ID: Hashable {
        base.containsID(id)
    }
}

// MARK: - MergeTraits

private struct MergeTraits: Rule, AsyncAttribute {
    @Attribute var overrideTraits: ViewTraitCollection
    @OptionalAttribute var baseTraits: ViewTraitCollection?

    var value: ViewTraitCollection {
        var traits = baseTraits ?? ViewTraitCollection()
        traits.mergeValues(overrideTraits)
        return traits
    }
}
