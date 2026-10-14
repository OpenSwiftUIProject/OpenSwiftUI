//
//  AccessibilityPlatform.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 4EFBB0540F336979925886EE21020A43 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AccessibilityPlatformViewModifier

struct AccessibilityPlatformViewModifier: AccessibilityViewModifier {
    var platformView: PlatformView
    var properties: AccessibilityProperties

    static var options: AccessibilityModifierOptions { .geometry }

    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
        true
    }

    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
        AccessibilityAttachment(properties: properties, platformElement: platformView)
    }

    func createOrUpdateNode(
        viewRendererHost: (any ViewRendererHost)?,
        existingNode: AccessibilityNode?
    ) -> AccessibilityNode {
        let node = existingNode ?? AccessibilityNode(
            viewRendererHost: viewRendererHost,
            isFromDisplayList: false
        )
        platformView.accessibilityNodeForPlatformElement = node
        return node
    }

    static func makeAccessibilityViewModifier(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if !inputs.preferences.requiresAccessibilityNodes,
           inputs.preferences.contains(AccessibilityAttachment.Key.self) {
            let attachment = Attribute(PlatformViewAttachment(
                properties: modifier[\.properties].value,
                view: modifier[\.platformView].value
            ))
            outputs.preferences.makePreferenceTransformer(
                inputs: inputs.preferences,
                key: AccessibilityAttachment.Key.self,
                transform: Attribute(AccessibilityAttachment.DeferredTransform(attachment: attachment))
            )
        }
        return outputs
    }

    var supportsPlaceholders: Bool { false }

    private struct PlatformViewAttachment: Rule {
        @Attribute var properties: AccessibilityProperties
        @Attribute var view: PlatformView

        var value: AccessibilityAttachment {
            AccessibilityAttachment(properties: properties, platformElement: view)
        }
    }
}
