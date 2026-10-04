//
//  AccessibilityContainerModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

// MARK: - AccessibilityContainerModifier

struct AccessibilityContainerModifier: AccessibilityViewModifier {
    let behavior: AccessibilityChildBehavior

    static var options: AccessibilityModifierOptions { .geometry }

    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
        behavior.modifier.willCreateNode(for: nodes)
    }

    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
        behavior.modifier.initialAttachment(for: nodes)
    }

    func updatedAttachment(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode],
        atIndex _: Int
    ) -> AccessibilityAttachment {
        guard nodes.count == 1,
              !behavior.modifier.visibility(for: token, nodes: nodes)[.childrenIgnored, default: false],
              nodes[0].platformElement == nil else {
            return AccessibilityAttachment()
        }
        return behavior.modifier.initialAttachment(for: nodes[0].children)
    }

    func createOrUpdateNode(
        viewRendererHost: (any ViewRendererHost)?,
        existingNode: AccessibilityNode?
    ) -> AccessibilityNode {
        if let existingNode {
            return existingNode
        }
        return AccessibilityNode(viewRendererHost: viewRendererHost, isFromDisplayList: false)
    }

    static func makeAccessibilityViewModifier(
        modifier _: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        inputs.needsAccessibilityGeometry = inputs.needsGeometry
        return body(_Graph(), inputs)
    }

    var supportsPlaceholders: Bool { false }
}
