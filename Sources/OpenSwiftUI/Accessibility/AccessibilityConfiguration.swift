//
//  AccessibilityConfiguration.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 0D3243EDC3DD4D641848661DCC354D4B (SwiftUI)

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AccessibilityConfigurationModifier

protocol AccessibilityConfigurationModifier {
    associatedtype Configuration = Never
    associatedtype Body
    associatedtype Content

    var configuration: Configuration { get }
    func body(content: Self.Content) -> Self.Body
}

extension AccessibilityConfigurationModifier where Configuration == Never {
    var configuration: Configuration { _openSwiftUIBaseClassAbstractMethod() }
}

// MARK: - AccessibilityTraitsModifier

struct AccessibilityTraitsModifier<Content: View>: AccessibilityConfigurationModifier {
    var traits: AccessibilityTraitSet

    init(traits: AccessibilityTraitSet) {
        self.traits = traits
    }

    func body(content: Content) -> some View {
        content
            .accessibilityCaptureViewResponders()
            .modifier(ChildModifier(traits: traits))
            .accessibilityIgnoreViewResponders()
    }

    private struct ChildModifier: AccessibilityViewModifier {
        var traits: AccessibilityTraitSet

        static var options: AccessibilityModifierOptions { [] }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            false
        }

        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            AccessibilityAttachment()
        }

        func updatedAttachment(
            for token: AccessibilityAttachmentToken,
            nodes: [AccessibilityNode],
            atIndex index: Int
        ) -> AccessibilityAttachment {
            guard index == 0 else {
                return .properties(AccessibilityProperties())
            }
            return .properties(AccessibilityProperties(
                AccessibilityProperties.TraitsKey.self,
                .init(implying: traits)
            ))
        }

        func createOrUpdateNode(
            viewRendererHost: (any ViewRendererHost)?,
            existingNode: AccessibilityNode?
        ) -> AccessibilityNode {
            existingNode ?? AccessibilityNode(viewRendererHost: viewRendererHost, isFromDisplayList: false)
        }

        static func makeAccessibilityViewModifier(
            modifier: _GraphValue<Self>,
            inputs: _ViewInputs,
            body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
        ) -> _ViewOutputs {
            body(_Graph(), inputs)
        }

        var supportsPlaceholders: Bool { false }
    }
}

// MARK: - AccessibilityLabelModifier

struct AccessibilityLabelModifier<Content: View>: AccessibilityConfigurationModifier {
    init() {
        _openSwiftUIEmptyStub()
    }

    func body(content: Content) -> some View {
        content
            .accessibilityCaptureViewResponders()
            .modifier(ChildModifier())
            .accessibilityIgnoreViewResponders()
    }

    private struct ChildModifier: AccessibilityViewModifier {
        let properties: AccessibilityProperties

        init() {
            properties = AccessibilityProperties(
                AccessibilityProperties.TraitsKey.self,
                .init(adding: .isLabel)
            )
        }

        static var options: AccessibilityModifierOptions { [] }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            false
        }

        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            AccessibilityAttachment()
        }

        func updatedAttachment(
            for token: AccessibilityAttachmentToken,
            nodes: [AccessibilityNode],
            atIndex index: Int
        ) -> AccessibilityAttachment {
            .properties(properties)
        }

        func createOrUpdateNode(
            viewRendererHost: (any ViewRendererHost)?,
            existingNode: AccessibilityNode?
        ) -> AccessibilityNode {
            existingNode ?? AccessibilityNode(viewRendererHost: viewRendererHost, isFromDisplayList: false)
        }

        static func makeAccessibilityViewModifier(
            modifier: _GraphValue<Self>,
            inputs: _ViewInputs,
            body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
        ) -> _ViewOutputs {
            body(_Graph(), inputs)
        }

        var supportsPlaceholders: Bool { false }
    }
}

// TODO: AccessibilityStepperModifier
// TODO: AccessibilityAdjustableModifier
// TODO: AccessibilityAdjustableModifier.Configuration
// TODO: AccessibilityNavigationLinkButtonModifier
// TODO: AccessibilityNavigationLinkButtonModifier.Representable
// TODO: AccessibilityLinkModifier
// TODO: AccessibilityLinkModifier.Configuration
// TODO: AccessibilitySliderModifier
// TODO: AccessibilityGroupBoxLabelModifier
// TODO: AccessibilityGroupBoxContentModifier
// TODO: AccessibilityDisclosureModifier
// TODO: AccessibilityTableCellModifier
// TODO: AccessibilityListCoreCellModifier
// TODO: AccessibilityButtonModifier.Attachment
// TODO: AccessibilityDefaultActionRepresentableConfiguration
// TODO: AccessibilityNavigationLinkButtonModifier.Attachment
// TODO: AccessibilityToggleModifier
// TODO: AccessibilityToggleModifier.RepresentationModifier
// TODO: AccessibilityButtonModifier
// TODO: AccessibilityButtonModifier.Representable
// TODO: AccessibilityBadgedViewNeedsValue
// TODO: AccessibilityNavigationLinkButtonModifier.Configuration
// TODO: AccessibilityBadgedViewProvidesOwnValue
// TODO: AccessibilityGaugeModifier
// TODO: AccessibilitySidebarListModifier
// TODO: AccessibilityButtonModifier.Configuration
// TODO: AccessibilityDisclosureModifier.Configuration
// TODO: AccessibilityDisclosureModifier.List
// TODO: AccessibilityPlaybackButtonModifier.Configuration
// TODO: AccessibilityPlaybackButtonModifier
// TODO: AccessibilityPlaybackButtonModifier.ValueStyle
// TODO: AccessibilityImageModifier.Configuration
// TODO: AccessibilityImageModifier
// TODO: AccessibilityStaticTextModifier.Configuration
// TODO: AccessibilityStaticTextModifier
// TODO: AccessibilityDisclosureModifier.List.Configuration
// TODO: AccessibilityGaugeModifier.Configuration
// TODO: AccessibilityBadgedViewModifier.Badge
// TODO: AccessibilityBadgedViewModifier
// TODO: AccessibilityBadgedViewModifier.Configuration

// MARK: - AccessibilityButtonShapeModifier [WIP]

struct AccessibilityButtonShapeModifier<Content: View>: AccessibilityConfigurationModifier {
    func body(content: Content) -> some View {
        content.modifier(Child())
    }

    private struct Child: ViewModifier {
//        @Environment(\.accessibilityShowButtonShapes)
//        private var accessibilityShowButtonShapes: Bool

        func body(content: Child.Content) -> some View {
//            if accessibilityShowButtonShapes {
                content
                // .buttonStyle(BorderedButtonStyle())
//            } else {
//                content
//            }
        }
    }
}

// MARK: - View + AccessibilityConfiguration

extension View {
    func accessibilityConfiguration<M>(_ modifier: M) -> M.Body where M: AccessibilityConfigurationModifier, M.Content == Self, M.Body: View {
        modifier.body(content: self)
    }
}
