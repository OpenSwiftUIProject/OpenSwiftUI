//
//  AccessibilityTraitsAdditions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 478AFED66621CDE70653987BE563E31B (SwiftUI)

public import OpenSwiftUICore
import OpenSwiftUI_SPI

// MARK: - AccessibilityTraitStorageProxy

@_spi(Ultraviolet)
@available(OpenSwiftUI_v3_0, *)
public struct AccessibilityTraitStorageProxy: Equatable, Hashable, Codable {
    var value: AccessibilityTraitStorage

    public init() {
        value = .init()
    }

    public var isDefault: Bool {
        value.isDefault
    }

    public var uv_descriptions: [String] {
        AccessibilityTrait.allCases.compactMap { trait in
            value[trait, default: false] ? trait.displayDescription : nil
        }
    }
}

@_spi(Ultraviolet)
@available(*, unavailable)
extension AccessibilityTraitStorageProxy: Sendable {}

// MARK: - View + AccessibilityTraits

@available(OpenSwiftUI_v2_0, *)
extension View {
    /// Adds the given traits to the view.
    nonisolated public func accessibilityAddTraits(
        _ traits: AccessibilityTraits
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibility(AccessibilityProperties.TraitsKey.self, .init(adding: traits))
    }

    /// Removes the given traits from this view.
    nonisolated public func accessibilityRemoveTraits(
        _ traits: AccessibilityTraits
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibility(AccessibilityProperties.TraitsKey.self, .init(removing: traits))
    }
}

extension View {
    @_disfavoredOverload
    nonisolated func accessibilityAddTraits(
        _ trait: AccessibilityTrait
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibility(AccessibilityProperties.TraitsKey.self, .init(adding: trait))
    }

    @_disfavoredOverload
    nonisolated func accessibilityRemoveTraits(
        _ trait: AccessibilityTrait
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibility(AccessibilityProperties.TraitsKey.self, .init(removing: trait))
    }
}

// MARK: - ModifiedContent + AccessibilityTraits

@available(OpenSwiftUI_v2_0, *)
extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    /// Adds the given traits to the view.
    nonisolated public func accessibilityAddTraits(
        _ traits: AccessibilityTraits
    ) -> ModifiedContent<Content, Modifier> {
        update(AccessibilityProperties.TraitsKey.self, combining: .init(adding: traits))
    }

    /// Removes the given traits from this view.
    nonisolated public func accessibilityRemoveTraits(
        _ traits: AccessibilityTraits
    ) -> ModifiedContent<Content, Modifier> {
        update(AccessibilityProperties.TraitsKey.self, combining: .init(removing: traits))
    }
}

extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    @_disfavoredOverload
    nonisolated func accessibilityAddTraits(
        _ trait: AccessibilityTrait
    ) -> ModifiedContent<Content, Modifier> {
        update(AccessibilityProperties.TraitsKey.self, combining: .init(adding: trait))
    }

    @_disfavoredOverload
    nonisolated func accessibilityAddTraits(
        _ traits: [AccessibilityTrait]
    ) -> ModifiedContent<Content, Modifier> {
        update(AccessibilityProperties.TraitsKey.self, combining: .init(adding: traits))
    }

    @_disfavoredOverload
    nonisolated func accessibilityRemoveTraits(
        _ traits: [AccessibilityTrait]
    ) -> ModifiedContent<Content, Modifier> {
        update(AccessibilityProperties.TraitsKey.self, combining: .init(removing: traits))
    }
}

// MARK: - View + AccessibilityTraits (Deprecated)

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds the given traits to the view.
    @available(*, deprecated, renamed: "accessibilityAddTraits(_:)")
    nonisolated public func accessibility(
        addTraits traits: AccessibilityTraits
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibilityAddTraits(traits)
    }

    /// Removes the given traits from this view.
    @available(*, deprecated, renamed: "accessibilityRemoveTraits(_:)")
    nonisolated public func accessibility(
        removeTraits traits: AccessibilityTraits
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibilityRemoveTraits(traits)
    }
}

// MARK: - ModifiedContent + AccessibilityTraits (Deprecated)

@available(OpenSwiftUI_v1_0, *)
extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    /// Adds the given traits to the view.
    @available(*, deprecated, renamed: "accessibilityAddTraits(_:)")
    nonisolated public func accessibility(
        addTraits traits: AccessibilityTraits
    ) -> ModifiedContent<Content, Modifier> {
        accessibilityAddTraits(traits)
    }

    /// Removes the given traits from this view.
    @available(*, deprecated, renamed: "accessibilityRemoveTraits(_:)")
    nonisolated public func accessibility(
        removeTraits traits: AccessibilityTraits
    ) -> ModifiedContent<Content, Modifier> {
        accessibilityRemoveTraits(traits)
    }
}

// MARK: - AccessibilityTraitResolver

protocol AccessibilityTraitResolver {
    func resolve(into traits: inout AXOpenSwiftUITraits, for storage: AccessibilityTraitStorage)
}
