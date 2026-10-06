//
//  AccessibilityLabelModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0D3243EDC3DD4D641848661DCC354D4B (SwiftUI)

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AccessibilityLabelModifier

struct AccessibilityLabelModifier<Content: View>: AccessibilityConfigurationModifier {
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

// MARK: - View + AccessibilityLabelModifier

extension View {
    func accessibilityLabel() -> some View {
        AccessibilityLabelModifier().body(content: self)
    }
}
