//
//  PlatformItems.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: B9CDC31698DC70A42F63A10B524A44D9 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// MARK: - PlatformItemsModifier

protocol PlatformItemsModifier: UnaryViewModifier {
    static var features: PlatformItem.Features { get }

    static func updateItems(modifier: Self, items: inout PlatformItems)
}

extension PlatformItemsModifier {
    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        transformPlatformItemsOutputs(&outputs, inputs: inputs, modifier: modifier)
        return outputs
    }

    static func transformPlatformItemsOutputs<Modifier>(
        _ outputs: inout _ViewOutputs,
        inputs: _ViewInputs,
        modifier: _GraphValue<Modifier>
    ) where Modifier: PlatformItemsModifier {
        guard inputs.preferences.requiresPlatformItems,
              inputs.platformItemFeatures.contains(Modifier.features) else {
            return
        }
        outputs.preferences.platformItems = Attribute(
            PlatformItemsTransform(
                modifier: modifier.value,
                items: .init(outputs.preferences.platformItems)
            )
        )
    }
}

// MARK: - UnaryPlatformItemsModifier

protocol UnaryPlatformItemsModifier: PlatformItemsModifier {
    static func updateItem(modifier: Self, item: inout PlatformItem)
}

extension UnaryPlatformItemsModifier {
    static func updateItems(modifier: Self, items: inout PlatformItems) {
        for index in items.indices {
            updateItem(modifier: modifier, item: &items[index])
        }
    }
}

// MARK: - PlatformItemRule

protocol PlatformItemRule: StatefulRule where Value == PlatformItems {
    var config: PlatformItemRuleConfiguration { get set }

    func makeContent() -> (PlatformItem.PrimaryContent, Bool)
}

extension PlatformItemRule {
    mutating func updateValue() {
        let (content, contentChanged) = makeContent()
        let phase = config.phase
        let (id, identityChanged) = config.tracker.update(for: phase)
        guard !hasValue || contentChanged || identityChanged else {
            return
        }
        config.seed &+= 1
        let seed = VersionSeed(value: config.seed)
        let item = PlatformItem(
            id: .init(ids: [id]),
            features: config.itemFeatures,
            seed: seed,
            content: content
        )
        value = PlatformItems(
            features: config.itemsFeatures,
            seed: seed,
            items: [item]
        )
    }
}

// MARK: - PlatformItems

struct PlatformItems {
    var features: Features = []
    var seed: VersionSeed = .empty
    var items: [PlatformItem] = []

    var id: PlatformItem.ID {
        .init(ids: items.flatMap { $0.id.ids })
    }

    fileprivate struct Key: PreferenceKey {
        static let defaultValue: PlatformItems = .init()

        static func reduce(value: inout PlatformItems, nextValue: () -> PlatformItems) {
            if value.features.contains(.multiple) {
                let next = nextValue()
                value.seed.merge(next.seed)
                value.items.append(contentsOf: next.items)
            } else if let first = value.items.first {
                guard !first.hasContent else {
                    return
                }
                if let next = nextValue().items.first {
                    value.items[0].merge(next)
                }
            } else {
                value = nextValue()
            }
        }
    }

    struct Features: OptionSet {
        let rawValue: Int

        static let multiple = Features(rawValue: 1 << 0)
    }
}

extension PlatformItems: RandomAccessCollection, MutableCollection {
    var startIndex: Int { items.startIndex }

    var endIndex: Int { items.endIndex }

    subscript(index: Int) -> PlatformItem {
        get { items[index] }
        set { items[index] = newValue }
    }

    func index(after index: Int) -> Int {
        index + 1
    }

    func index(before index: Int) -> Int {
        index - 1
    }
}

// MARK: - PlatformItem

struct PlatformItem {
    var id: ID = .init(ids: [])
    var features: Features = []
    var seed: VersionSeed = .empty
    var content: PrimaryContent?
    var selection: SelectionContent?
    var children: ChildrenContent?
    var accessibility: AccessibilityContent?

    var hasContent: Bool {
        guard let content else {
            return false
        }
        return (!features.contains(.text) || content.text != nil)
            && (!features.contains(.image) || content.image != nil)
            && (!features.contains(.selection) || selection != nil)
            && (!features.contains(.secondaryText) || content.secondaryText != nil)
            && (!features.contains(.iconText) || content.iconText != nil)
            && (!features.contains(.children) || children != nil)
            && (!features.contains(.accessibility) || accessibility != nil)
    }

    mutating func merge(_ other: PlatformItem) {
        id.ids.append(contentsOf: other.id.ids)
        seed.merge(other.seed)
        if let otherContent = other.content {
            if content == nil {
                content = otherContent
            } else {
                content!.merge(otherContent, features: features)
            }
        }
        if let otherSelection = other.selection {
            if selection == nil {
                selection = otherSelection
            } else {
                selection!.merge(otherSelection)
            }
        }
        if let otherChildren = other.children {
            if children == nil {
                children = otherChildren
            } else if children!.$children == nil, otherChildren.$children != nil {
                children = otherChildren
            }
        }
        if let otherAccessibility = other.accessibility {
            if accessibility == nil {
                accessibility = otherAccessibility
            } else {
                accessibility!.properties = accessibility!.properties.combined(with: otherAccessibility.properties)
            }
        }
    }

    struct PrimaryContent {
        var text: NSAttributedString?
        var secondaryText: NSAttributedString?
        var iconText: NSAttributedString?
        var image: Image.Resolved?
        var prioritizeImage: Bool = false
        var shapeStyle: AnyShapeStyle?

        mutating func merge(_ other: PrimaryContent, features: Features) {
            if let otherText = other.text {
                if text == nil {
                    text = otherText
                } else if secondaryText == nil, features.contains(.secondaryText) {
                    secondaryText = otherText
                }
            }
            if image == nil {
                image = other.image
            }
            if secondaryText == nil {
                secondaryText = other.secondaryText
            }
            if iconText == nil {
                iconText = other.iconText
            }
        }
    }

    struct SelectionContent {
        @WeakAttribute var onSelectAction: (() -> Void)??
        @WeakAttribute var onDeselectAction: (() -> Void)??
        var options: Options = []
        var auxiliaryContent: AuxiliaryContent?

        mutating func merge(_ other: SelectionContent) {
            if $onSelectAction == nil, other.$onSelectAction != nil {
                _onSelectAction = other._onSelectAction
            }
            if $onDeselectAction == nil, other.$onDeselectAction != nil {
                _onDeselectAction = other._onDeselectAction
            }
            if options.isEmpty {
                options = other.options
            }
            if auxiliaryContent == nil {
                auxiliaryContent = other.auxiliaryContent
            }
        }

        enum AuxiliaryContent {
            case documentCreationStrategy(any DocumentCreationStrategy)
        }

        struct Options: OptionSet {
            let rawValue: Int
        }
    }

    struct ChildrenContent {
        @WeakAttribute var children: PlatformItems?
    }

    struct AccessibilityContent {
        var properties: AccessibilityProperties
        @WeakAttribute var weakEnv: EnvironmentValues?

        var environment: EnvironmentValues {
            Graph.withoutUpdate {
                Update.ensure {
                    weakEnv ?? .configuredForPlatform
                }
            }
        }

        var resolvedAttributedLabel: NSAttributedString? {
            guard let label = properties.labelStorage else {
                return nil
            }
            return AccessibilityCore.textsResolvedToAttributedText(
                label.texts,
                in: environment,
                updateResolvableAttributes: true
            )
        }
    }

    struct Features: OptionSet {
        let rawValue: Int

        static let text = Features(rawValue: 1 << 0)
        static let image = Features(rawValue: 1 << 1)
        static let styledText = Features(rawValue: 1 << 2)
        static let selection = Features(rawValue: 1 << 3)
        static let secondaryText = Features(rawValue: 1 << 4)
        static let iconText = Features(rawValue: 1 << 5)
        static let children = Features(rawValue: 1 << 6)
        static let accessibility = Features(rawValue: 1 << 7)
    }

    struct ID: Hashable {
        var ids: [ViewIdentity]
    }
}

// MARK: - PlatformItemsTransform

private struct PlatformItemsTransform<Modifier>: StatefulRule where Modifier: PlatformItemsModifier {
    @Attribute var modifier: Modifier
    @OptionalAttribute var items: PlatformItems?
    var seed: UInt32 = 0

    typealias Value = PlatformItems

    mutating func updateValue() {
        let (items, itemsChanged) = $items?.changedValue() ?? (.init(), false)
        let (modifier, modifierChanged) = $modifier.changedValue()
        guard !hasValue || modifierChanged || itemsChanged else {
            return
        }
        var result = items
        Modifier.updateItems(modifier: modifier, items: &result)
        seed.unsafeIncrement()
        result.seed.merge(.init(value: seed))
        for index in result.indices {
            result[index].seed.merge(.init(value: seed))
        }
        value = result
    }
}

// TODO: PlatformItemsGenerator

// MARK: - PlatformItemRuleConfiguration

struct PlatformItemRuleConfiguration {
    @Attribute var phase: _GraphInputs.Phase
    let itemsFeatures: PlatformItems.Features
    let itemFeatures: PlatformItem.Features
    var tracker: ViewIdentity.Tracker = .init(id: .invalid, resetSeed: 0)
    var seed: UInt32 = 0

    init(inputs: _ViewInputs) {
        _phase = inputs.viewPhase
        itemsFeatures = inputs.platformItemsFeatures
        itemFeatures = inputs.platformItemFeatures
    }
}

// MARK: - PlatformItems + Inputs and Outputs

extension PreferencesInputs {
    var requiresPlatformItems: Bool {
        get {
            contains(PlatformItems.Key.self)
        }
        set {
            if newValue {
                add(PlatformItems.Key.self)
            } else {
                remove(PlatformItems.Key.self)
            }
        }
    }
}

extension PreferencesOutputs {
    var platformItems: Attribute<PlatformItems>? {
        get { self[PlatformItems.Key.self] }
        set { self[PlatformItems.Key.self] = newValue }
    }
}

extension _ViewInputs {
    var requestsPlatformItems: Bool {
        get { self[RequestsPlatformItemsKey.self] }
        set { self[RequestsPlatformItemsKey.self] = newValue }
    }

    var platformItemsFeatures: PlatformItems.Features {
        get { self[PlatformItemsFeaturesKey.self] }
        set { self[PlatformItemsFeaturesKey.self] = newValue }
    }

    var platformItemFeatures: PlatformItem.Features {
        get { self[PlatformItemFeaturesKey.self] }
        set { self[PlatformItemFeaturesKey.self] = newValue }
    }

    private struct RequestsPlatformItemsKey: ViewInputBoolFlag {}

    private struct PlatformItemFeaturesKey: ViewInput {
        static var defaultValue: PlatformItem.Features {
            []
        }
    }

    private struct PlatformItemsFeaturesKey: ViewInput {
        static var defaultValue: PlatformItems.Features {
            []
        }
    }
}

extension _ViewOutputs {
    mutating func makePlatformItem<ItemRule>(
        inputs: _ViewInputs,
        itemRule: ItemRule
    ) where ItemRule: PlatformItemRule {
        guard inputs.preferences.requiresPlatformItems else {
            return
        }
        preferences.makePreferenceWriter(
            inputs: inputs.preferences,
            key: PlatformItems.Key.self,
            value: Attribute(itemRule)
        )
    }

    private struct FirstItem: Rule {
        @Attribute var items: PlatformItems

        var value: PlatformItem {
            if items.isEmpty {
                return .init(id: .init(ids: [.invalid]))
            }
            return items[0]
        }
    }
}

// MARK: - PlatformItemsImageRepresentable

struct PlatformItemsImageRepresentable: PlatformImageRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItems
            && inputs.platformItemFeatures.contains(.image)
    }

    static func makeRepresentation(
        inputs: _ViewInputs,
        context: Attribute<PlatformImageRepresentableContext>,
        outputs: inout _ViewOutputs
    ) {
        outputs.makePlatformItem(
            inputs: inputs,
            itemRule: PlatformItemContent(context: context, config: .init(inputs: inputs))
        )
    }

    private struct PlatformItemContent: PlatformItemRule, AsyncAttribute {
        @Attribute var context: PlatformImageRepresentableContext
        var config: PlatformItemRuleConfiguration

        func makeContent() -> (PlatformItem.PrimaryContent, Bool) {
            let (context, changed) = $context.changedValue()
            return (
                .init(
                    image: context.image,
                    prioritizeImage: true,
                    shapeStyle: context.foregroundStyle
                ),
                changed
            )
        }
    }
}

// MARK: - PlatformItemsTextRepresentable

struct PlatformItemsTextRepresentable: PlatformTextRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItems
            && inputs.platformItemFeatures.contains(.text)
    }

    static func representationOptions(inputs: _ViewInputs) -> PlatformTextRepresentationOptions {
        inputs.platformItemFeatures.contains(.styledText) ? [.includeStyledText] : []
    }

    static func makeRepresentation(
        inputs: _ViewInputs,
        context: Attribute<PlatformTextRepresentableContext>,
        outputs: inout _ViewOutputs
    ) {
        outputs.makePlatformItem(
            inputs: inputs,
            itemRule: PlatformItemContent(context: context, config: .init(inputs: inputs))
        )
    }

    private struct PlatformItemContent: PlatformItemRule, AsyncAttribute {
        @Attribute var context: PlatformTextRepresentableContext
        var config: PlatformItemRuleConfiguration

        func makeContent() -> (PlatformItem.PrimaryContent, Bool) {
            let (context, changed) = $context.changedValue()
            let content = context.text.map { PlatformItem.PrimaryContent(text: $0) } ?? .init()
            return (content, changed)
        }
    }
}
