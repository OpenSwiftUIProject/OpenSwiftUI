//
//  PlatformItemsStrategy.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - PlatformItemsStrategy

protocol PlatformItemsStrategy {
    associatedtype Content

    static var defaultValue: Content { get }
    static var itemsFeatures: PlatformItems.Features { get }
    static var itemFeatures: PlatformItem.Features { get }

    static func hasChanges(from oldContent: Content, to newContent: Content) -> Bool
    static func makeInputs(_ inputs: inout _ViewInputs)
    static func makeContent(from outputs: _ViewOutputs) -> OptionalAttribute<Content>
}

// MARK: - MultiPlatformItemsStrategy

protocol MultiPlatformItemsStrategy: PlatformItemsStrategy where Content == PlatformItems {}

extension MultiPlatformItemsStrategy {
    static var defaultValue: PlatformItems { .init(features: itemsFeatures) }

    static var itemsFeatures: PlatformItems.Features { .multiple }

    static func hasChanges(from oldContent: PlatformItems, to newContent: PlatformItems) -> Bool {
        oldContent.seed.matches(newContent.seed) && oldContent.id == newContent.id
    }

    static func makeInputs(_ inputs: inout _ViewInputs) {
        inputs.preferences.requiresPlatformItems = true
        inputs.requestedTextRepresentation = PlatformItemsTextRepresentable.self
        inputs.requestedImageRepresentation = PlatformItemsImageRepresentable.self
        inputs.platformItemsFeatures.formUnion(itemsFeatures)
        inputs.platformItemFeatures.formUnion(itemFeatures)
        inputs.requestsPlatformItems = true
    }

    static func makeContent(from outputs: _ViewOutputs) -> OptionalAttribute<PlatformItems> {
        .init(outputs.preferences.platformItems)
    }
}

// MARK: - UnaryPlatformItemsStrategy

protocol UnaryPlatformItemsStrategy: PlatformItemsStrategy where Content == PlatformItem {}

extension UnaryPlatformItemsStrategy {
    static var defaultValue: PlatformItem { .init(id: .init(ids: [.invalid])) }

    static var itemsFeatures: PlatformItems.Features { [] }

    static func hasChanges(from oldContent: PlatformItem, to newContent: PlatformItem) -> Bool {
        !oldContent.seed.matches(newContent.seed) || oldContent.id != newContent.id
    }

    static func makeInputs(_ inputs: inout _ViewInputs) {
        inputs.preferences.requiresPlatformItems = true
        inputs.requestedTextRepresentation = PlatformItemsTextRepresentable.self
        inputs.requestedImageRepresentation = PlatformItemsImageRepresentable.self
        inputs.platformItemsFeatures.formUnion(itemsFeatures)
        inputs.platformItemFeatures.formUnion(itemFeatures)
        inputs.requestsPlatformItems = true
        if itemFeatures.contains(.accessibility) {
            inputs.preferences.add(AccessibilityAttachment.Key.self)
        }
    }

    static func makeContent(from outputs: _ViewOutputs) -> OptionalAttribute<PlatformItem> {
        .init(outputs.platformItem)
    }
}

// MARK: - MultiButtonPlatformItemsStrategy

struct MultiButtonPlatformItemsStrategy: MultiPlatformItemsStrategy {
    static var itemFeatures: PlatformItem.Features {
        [.text, .image, .selection, .secondaryText]
    }
}

// MARK: - LabelPlatformItemsStrategy

struct LabelPlatformItemsStrategy: UnaryPlatformItemsStrategy {
    static var itemFeatures: PlatformItem.Features {
        [.text, .image, .secondaryText, .iconText, .accessibility]
    }
}

// MARK: - TextPlatformItemsStrategy

struct TextPlatformItemsStrategy: UnaryPlatformItemsStrategy {
    static var itemFeatures: PlatformItem.Features { .text }
}

// MARK: - ButtonPlatformItemsStrategy

struct ButtonPlatformItemsStrategy: UnaryPlatformItemsStrategy {
    static var itemFeatures: PlatformItem.Features {
        [.text, .image, .selection, .secondaryText]
    }
}

// MARK: - StyledTextPlatformItemsStrategy

struct StyledTextPlatformItemsStrategy: UnaryPlatformItemsStrategy {
    static var itemFeatures: PlatformItem.Features { [.text, .styledText] }
}
