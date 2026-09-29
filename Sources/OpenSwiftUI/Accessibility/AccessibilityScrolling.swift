//
//  AccessibilityScrolling.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 0E5D36A33D50442A9EDB086D241B5AD6 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import struct OpenSwiftUICore.UniqueID

// MARK: - AccessibilityLazyLayoutNode

class AccessibilityLazyLayoutNode: AccessibilityNode {

    // TODO: accessibilityElements

    // FIXME
    #if canImport(ObjectiveC)
    @objc
    #endif
    /*override*/ var _accessibilityHitTestShouldFallbackToNearestChild: Bool {
        true
    }
}

// MARK: - AccessibilitySectionContext

struct AccessibilitySectionContext: Equatable {
    var id: UInt32
    var isHeader: Bool
    var isFooter: Bool
}

// MARK: - AccessibilityScrollableContext

enum AccessibilityScrollableContext {
    case lazyLayout(any ScrollableCollection, AccessibilityLayoutRole?, _ViewList_ID.Canonical, AccessibilitySectionContext?)
    case list(_ViewList_ID.Canonical)
    case dynamicLayout(any ScrollableCollection, _ViewList_ID.Canonical)
}

// MARK: - makeAccessibilityLayoutScrollableTransform

func makeAccessibilityLayoutScrollableTransform(
    isLazy: Bool,
    role: AccessibilityLayoutRole?,
    placedSubviews: OptionalAttribute<[_LazyLayout_PlacedSubview]>,
    inputs: _ViewInputs,
    outputs: _ViewOutputs
) -> Attribute<AccessibilityNodeList>? {
    guard let scrollables = outputs[ScrollablePreferenceKey.self],
          let nodeList = outputs.accessibilityNodes else {
        return outputs.accessibilityNodes
    }
    return Attribute(LayoutScrollableTransform(
        isLazy: isLazy,
        role: role,
        accessibilityEnabled: inputs.accessibilityEnabled,
        nodeList: OptionalAttribute(nodeList),
        scrollables: scrollables,
        placedSubviews: placedSubviews,
        previousNodes: []
    ))
}

// MARK: - LayoutScrollableTransform [TBA]

private struct LayoutScrollableTransform: StatefulRule, CustomStringConvertible {
    var isLazy: Bool
    var role: AccessibilityLayoutRole?
    @Attribute var accessibilityEnabled: Bool
    @OptionalAttribute var nodeList: AccessibilityNodeList?
    @Attribute var scrollables: [any Scrollable]
    @OptionalAttribute var placedSubviews: [_LazyLayout_PlacedSubview]?
    var previousNodes: [AccessibilityNode]

    typealias Value = AccessibilityNodeList

    mutating func updateValue() {
        let token = AccessibilityAttachmentToken(attribute)
        guard accessibilityEnabled, let nodeList else {
            for node in previousNodes {
                node.removeAttachment(isInPlatformItemList: false, token: token)
            }
            previousNodes = []
            value = AccessibilityNodeList(nodes: [], version: .init())
            return
        }
        guard let collection = scrollables.compactMap({ $0 as? any ScrollableCollection }).first else {
            value = nodeList
            return
        }
        let (_, scrollablesChanged) = $scrollables.changedValue()
        let nodesChanged = nodeList.nodes != previousNodes
        guard scrollablesChanged || nodesChanged else {
            value = nodeList
            return
        }

        var collectionIDs: Set<_ViewList_ID.Canonical> = []
        var nodeIDs: [UniqueID: (_ViewList_ID.Canonical, AccessibilitySectionContext?)] = [:]
        let placedSubviews = placedSubviews
        for node in nodeList.nodes {
            guard let subgraph = node.subgraph,
                  let id = collection.collectionViewID(for: subgraph) else {
                continue
            }
            let section = placedSubviews?.first { $0.item.id.canonicalID == id }.map {
                AccessibilitySectionContext(
                    id: $0.item.section.id ?? 0,
                    isHeader: $0.item.section.isHeader,
                    isFooter: $0.item.section.isFooter
                )
            }
            nodeIDs[node.id] = (id, section)
            collectionIDs.insert(id)
        }

        var changed = false
        if isLazy || collectionIDs.count > 1 {
            for node in nodeList.nodes {
                guard let (id, section) = nodeIDs[node.id] else {
                    if node.hasAttachment(token: token) {
                        node.removeAttachment(isInPlatformItemList: false, token: token)
                        changed = true
                    }
                    continue
                }
                var properties = AccessibilityProperties()
                properties.scrollableContext = isLazy
                    ? .lazyLayout(collection, role, id, section)
                    : .dynamicLayout(collection, id)
                let attachment = AccessibilityAttachment.properties(properties)
                if node.hasAttachment(token: token) {
                    if node.updateAttachment(attachment, isInPlatformItemList: false, token: token, merge: false) {
                        changed = true
                    }
                } else {
                    node.addAttachment(attachment, isInPlatformItemList: false, token: token)
                    changed = true
                }
            }
        }
        for node in previousNodes where !nodeList.nodes.contains(node) {
            node.removeAttachment(isInPlatformItemList: false, token: token)
            changed = true
        }
        previousNodes = nodeList.nodes
        value = AccessibilityNodeList(
            nodes: nodeList.nodes,
            version: changed ? .init(forUpdate: ()) : nodeList.version
        )
    }

    var description: String {
        "    AccessibilityLayoutScrollableTransform     isLazy \(isLazy)     role \(String(describing: role))"
    }
}

// MARK: - AccessibilityScrollableModifier [TBA]

struct AccessibilityScrollableModifier: AccessibilityViewModifier {
    var isLazy: Bool
    @Attribute var scrollables: [any Scrollable]
    var properties: AccessibilityProperties

    static var options: AccessibilityModifierOptions { [] }

    private var scrollableCollection: (any ScrollableCollection)? {
        scrollables.first as? any ScrollableCollection
    }

    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
        scrollableCollection != nil && isLazy
    }

    func createOrUpdateNode(
        viewRendererHost: (any ViewRendererHost)?,
        existingNode: AccessibilityNode?
    ) -> AccessibilityNode {
        let isLazy = scrollableCollection != nil && isLazy
        if let existingNode, (existingNode is AccessibilityLazyLayoutNode) == isLazy {
            return existingNode
        }
        if isLazy {
            return AccessibilityLazyLayoutNode(viewRendererHost: viewRendererHost, isFromDisplayList: false)
        } else {
            return AccessibilityNode(viewRendererHost: viewRendererHost, isFromDisplayList: false)
        }
    }

    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
        guard let collection = scrollableCollection else {
            return .properties(properties)
        }
        var properties = properties
        properties.scrollableCollection = collection
        properties.visibility = .init(adding: .containerElement)
        return .properties(properties)
    }

    func updatedAttachment(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode],
        atIndex index: Int
    ) -> AccessibilityAttachment {
        initialAttachment(for: nodes)
    }
}

// MARK: - AccessibilityScrollableContextModifier

struct AccessibilityScrollableContextModifier: AccessibilityViewModifier {
    var context: AccessibilityScrollableContext

    static var options: AccessibilityModifierOptions { [] }

    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool { false }

    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
        var properties = AccessibilityProperties()
        properties.scrollableContext = context
        return .properties(properties)
    }

    func updatedAttachment(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode],
        atIndex index: Int
    ) -> AccessibilityAttachment {
        initialAttachment(for: nodes)
    }
}
