//
//  AccessibilityAttachmentModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims
public import OpenSwiftUICore

// MARK: - AccessibilityAttachmentModifier

/// A view modifier that adds accessibility properties to the view
@available(OpenSwiftUI_v1_0, *)
public struct AccessibilityAttachmentModifier: AccessibilityViewModifier {
    var storage: MutableBox<AccessibilityAttachment>
    let behavior: AccessibilityChildBehavior?

    init(_ properties: AccessibilityProperties) {
        storage = MutableBox(AccessibilityAttachment(properties: properties))
        behavior = nil
    }

    static var options: AccessibilityModifierOptions { [.geometry, .scrapeable] }

    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
        if let behavior {
            return behavior.modifier.willCreateNode(for: nodes)
        }
        return nodes.isEmpty && !storage.value.isEmpty
    }

    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
        var attachment = storage.value
        if let behavior {
            let child = behavior.modifier.initialAttachment(for: nodes)
            attachment.properties.merge(with: child.properties)
            if attachment.platformElement == nil, let element = child.platformElement {
                attachment.platformElement = element
            }
        }
        return attachment
    }

    func updatedAttachment(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode],
        atIndex index: Int
    ) -> AccessibilityAttachment {
        var attachment = storage.value
        if let behavior {
            let child = AccessibilityContainerModifier(behavior: behavior).updatedAttachment(
                for: token,
                nodes: nodes,
                atIndex: index
            )
            attachment.properties.merge(with: child.properties)
            if attachment.platformElement == nil, let element = child.platformElement {
                attachment.platformElement = element
            }
        }
        return attachment
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
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if !inputs.preferences.requiresAccessibilityNodes,
           inputs.preferences.contains(AccessibilityAttachment.Key.self) {
            let attachment = modifier.value.storage[keyPath: \.value]
            outputs.preferences.makePreferenceTransformer(
                inputs: inputs.preferences,
                key: AccessibilityAttachment.Key.self,
                transform: Attribute(AccessibilityAttachment.DeferredTransform(attachment: attachment))
            )
        }
        return outputs
    }

    var supportsPlaceholders: Bool { behavior == nil }
}

@available(*, unavailable)
extension AccessibilityAttachmentModifier: Sendable {}

// MARK: - Accessibility property modifiers

extension View {
    func accessibility<K>(
        _ key: K.Type,
        _ value: K.PropertyValue,
        isEnabled: Bool = true
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> where K: AccessibilityPropertiesKey {
        let properties = isEnabled ? AccessibilityProperties(key, value) : AccessibilityProperties()
        return modifier(AccessibilityAttachmentModifier(properties))
    }

    func accessibility() -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        modifier(AccessibilityAttachmentModifier(AccessibilityProperties()))
    }
}

extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    func update<K>(
        _ key: K.Type,
        replacing value: K.PropertyValue,
        isEnabled: Bool = true
    ) -> ModifiedContent<Content, Modifier> where K: AccessibilityPropertiesKey {
        if isEnabled {
            modifier.storage.value.properties[key] = value
        }
        return self
    }

    func update<K>(
        _ key: K.Type,
        combining value: K.PropertyValue,
        isEnabled: Bool = true
    ) -> ModifiedContent<Content, Modifier> where K: AccessibilityPropertiesKey, K.PropertyValue: AccessibilityCombinable {
        if isEnabled {
            let child = modifier.storage.value.properties[key]
            modifier.storage.value.properties[key] = value
            modifier.storage.value.properties[key].merge(with: child)
        }
        return self
    }
}
