//
//  PlatformItemsReader.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2D2DE8D65225CC97305A8AAD72170302 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - PlatformItemsReader

struct PlatformItemsReader<Strategy, Content, Source>: PrimitiveView, UnaryView
    where Strategy: PlatformItemsStrategy, Content: View, Source: View {
    var content: (Strategy.Content) -> Content
    var source: ZStack<Source>

    init(
        for strategy: Strategy,
        @ViewBuilder content: @escaping (Strategy.Content) -> Content,
        @ViewBuilder source: () -> Source
    ) {
        self.content = content
        self.source = ZStack(content: source)
    }

    static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let source = view[offset: { .of(&$0.source) }]
        let hostKeys = inputs.intern(PreferenceKeys(), id: .defaultValue)
        var sourceInputs = inputs.withoutGeometryDependencies
        sourceInputs.preferences = PreferencesInputs(hostKeys: hostKeys)
        Strategy.makeInputs(&sourceInputs)
        let outputs = ZStack<Source>.makeDebuggableView(
            view: source,
            inputs: sourceInputs
        )
        let child = Child(
            content: Strategy.makeContent(from: outputs),
            viewContent: view.value[offset: { .of(&$0.content) }],
            oldContent: Strategy.defaultValue
        )
        return Content.makeDebuggableView(view: _GraphValue(child), inputs: inputs)
    }

    private struct Child: StatefulRule {
        @OptionalAttribute var content: Strategy.Content?
        @Attribute var viewContent: (Strategy.Content) -> Content
        var oldContent: Strategy.Content

        typealias Value = Content

        init(
            content: OptionalAttribute<Strategy.Content>,
            viewContent: Attribute<(Strategy.Content) -> Content>,
            oldContent: Strategy.Content
        ) {
            self._content = content
            self._viewContent = viewContent
            self.oldContent = oldContent
        }

        mutating func updateValue() {
            let (viewContent, viewChanged) = $viewContent.changedValue()
            let (content, contentChanged) = $content?.changedValue() ?? (Strategy.defaultValue, false)
            defer { oldContent = content }
            let changed = Strategy.hasChanges(from: oldContent, to: content)
            guard !hasValue || (contentChanged && changed) || viewChanged else {
                return
            }
            value = withObservation {
                viewContent(content)
            }
        }
    }
}

// MARK: - PlatformItemTraitWriter

struct PlatformItemTraitWriter<Strategy, Source, Trait>: PrimitiveViewModifier
    where Strategy: UnaryPlatformItemsStrategy, Source: View,
          Trait: _ViewTraitKey, Trait.Value == PlatformItem {
    var source: Source

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        body(_Graph(), inputs)
    }

    nonisolated static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var childInputs = inputs
        var sourceInputs = inputs.withoutGeometryDependencies
        Strategy.makeInputs(&sourceInputs)
        let source = modifier[offset: { .of(&$0.source) }]
        let outputs = Source._makeView(
            view: source,
            inputs: sourceInputs
        )
        let addTrait = AddTrait(
            content: .init(outputs.platformItem),
            traits: .init(inputs.traits),
            oldContent: Strategy.defaultValue
        )
        childInputs.traits = Attribute(addTrait)
        childInputs.addTraitKey(Trait.self)
        return body(_Graph(), childInputs)
    }

    private struct AddTrait: StatefulRule, AsyncAttribute {
        @OptionalAttribute var content: PlatformItem?
        @OptionalAttribute var traits: ViewTraitCollection?
        var oldContent: PlatformItem

        typealias Value = ViewTraitCollection

        mutating func updateValue() {
            let (content, contentChanged) = $content?.changedValue() ?? (Strategy.defaultValue, false)
            let (incomingTraits, traitsChanged) = $traits?.changedValue() ?? (ViewTraitCollection(), false)
            defer { oldContent = content }
            let changed = Strategy.hasChanges(from: oldContent, to: content)
            guard !hasValue || (contentChanged && changed) || traitsChanged else {
                return
            }
            var traits = incomingTraits
            traits[Trait.self] = content
            value = traits
        }
    }
}
