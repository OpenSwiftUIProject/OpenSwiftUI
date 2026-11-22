//
//  AccessibilityRelation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 725F422359ECCADDAF5CC82A425651EE (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - AccessibilityLabeledPairRole

/// The role of an accessibility element in a label / content pair.
@available(OpenSwiftUI_v2_0, *)
@frozen
public enum AccessibilityLabeledPairRole {
    /// This element represents the label part of the label / content pair.
    ///
    /// For example, it might be the explanatory text to the left of a control,
    /// describing what the control does.
    case label

    /// This element represents the content part of the label / content pair.
    ///
    /// For example, it might be the custom control itself.
    case content
}

@available(OpenSwiftUI_v2_0, *)
extension AccessibilityLabeledPairRole: Hashable {}

// MARK: - AccessibilityRelationshipScope

class AccessibilityRelationshipScope: ViewInput {
    static var defaultValue: AccessibilityRelationshipScope? { nil }

    enum Relationship: Hashable {
        case labeledPair(AccessibilityLabeledPairRole)
        case linkedGroup
        case focusable
        case rotorEntry
    }

    private struct Key: Hashable {
        var identifier: AnyHashable
        var namespace: Namespace.ID

        init<ID: Hashable>(identifier: ID, in namespace: Namespace.ID) {
            self.identifier = AnyHashable(identifier)
            self.namespace = namespace
        }
    }

    private struct NodeRelation: Hashable {
        var node: UniqueID
        var relationship: Relationship
    }

    private var relatedNodesByKey: [Key: [Relationship: [AccessibilityNode]]] = [:]
    private var recordsByAttribute: [AnyAttribute: (key: Key, relationship: Relationship, nodes: [AccessibilityNode])] = [:]
    private var keysByNodeRelation: [NodeRelation: Set<Key>] = [:]

    func nodes<ID: Hashable>(
        for relationship: Relationship,
        with identifier: ID,
        in namespace: Namespace.ID
    ) -> [AccessibilityNode] {
        relatedNodesByKey[Key(
            identifier: identifier,
            in: namespace
        )]?[relationship] ?? []
    }

    func nodes(
        for relationship: Relationship,
        of node: AccessibilityNode,
        returning relatedRelationship: Relationship
    ) -> [AccessibilityNode] {
        let relation = NodeRelation(node: node.id, relationship: relationship)
        guard let keys = keysByNodeRelation[relation] else { return [] }
        return keys.reduce(into: []) { result, key in
            if let nodes = relatedNodesByKey[key]?[relatedRelationship] {
                result.append(contentsOf: nodes)
            }
        }
    }

    fileprivate func update<ID: Hashable>(
        _ relationship: Relationship,
        nodes: [AccessibilityNode],
        identifier: ID,
        in namespace: Namespace.ID,
        from attribute: AnyAttribute
    ) {
        let key = Key(identifier: identifier, in: namespace)
        let record = (key: key, relationship: relationship, nodes: nodes)

        func updateRecordsByAttribute(
            _ existing: inout (key: Key, relationship: Relationship, nodes: [AccessibilityNode])?
        ) -> Bool {
            if existing?.key == record.key,
               existing?.relationship == record.relationship,
               existing?.nodes == record.nodes {
                return false
            }
            existing = record
            return true
        }

        func updateRelatedNodesByKey(_ nodesByRelationship: inout [Relationship: [AccessibilityNode]]) {
            func updateRelatedNodes(_ relatedNodes: inout [AccessibilityNode]) {
                for node in nodes where !relatedNodes.contains(node) {
                    relatedNodes.append(node)
                }
            }
            updateRelatedNodes(&nodesByRelationship[relationship, default: []])
        }

        guard updateRecordsByAttribute(&recordsByAttribute[attribute]) else { return }
        updateRelatedNodesByKey(&relatedNodesByKey[key, default: [:]])
        for node in nodes {
            let relation = NodeRelation(node: node.id, relationship: relationship)
            keysByNodeRelation[relation, default: []].insert(key)
        }
    }

    func clear(from attribute: AnyAttribute) {
        guard let record = recordsByAttribute.removeValue(forKey: attribute),
              var relatedNodes = relatedNodesByKey[record.key] else {
            return
        }
        var removedRelationships: [Relationship] = []
        // A node can participate in multiple relationships under the same key.
        for (relationship, nodes) in relatedNodes {
            if relationship == record.relationship, nodes == record.nodes {
                relatedNodes[relationship] = nil
            } else {
                guard record.nodes.allSatisfy({ nodes.contains($0) }) else { continue }
                relatedNodes[relationship]?.removeAll { record.nodes.contains($0) }
            }
            removedRelationships.append(relationship)
        }
        relatedNodesByKey[record.key] = relatedNodes
        for node in record.nodes {
            for relationship in removedRelationships {
                let relation = NodeRelation(node: node.id, relationship: relationship)
                keysByNodeRelation[relation]?.remove(record.key)
                if keysByNodeRelation[relation]?.isEmpty == true {
                    keysByNodeRelation[relation] = nil
                }
            }
        }
    }
}

// MARK: - View + Accessibility Relationships

@available(OpenSwiftUI_v2_0, *)
extension View {
    /// Links multiple accessibility elements so that the user can quickly
    /// navigate from one element to another, even when the elements are not near
    /// each other in the accessibility hierarchy.
    ///
    /// For example, this lets a user jump between content in a list and the same
    /// content in a detail view. Elements marked with `accessibilityLinkedGroup`
    /// are linked when their identifiers and namespaces match.
    ///
    /// - Parameters:
    ///   - id: The hashable identifier for a set of linked elements within the
    ///     given namespace.
    ///   - namespace: The namespace that groups the linked elements by identifier.
    nonisolated public func accessibilityLinkedGroup<ID>(
        id: ID,
        in namespace: Namespace.ID
    ) -> some View where ID: Hashable {
        accessibilityRelationship(.linkedGroup, id: id, in: namespace)
    }

    /// Pairs an accessibility element representing a label with the element
    /// for the matching content.
    ///
    /// Use `accessibilityLabeledPair` with a role of ``AccessibilityLabeledPairRole/label``
    /// to identify the label, and a role of ``AccessibilityLabeledPairRole/content``
    /// to identify the content.
    ///
    /// - Parameters:
    ///   - role: Determines whether this element should be used as the label
    ///     in the pair, or the content in the pair.
    ///   - id: The identifier for the label / content pair. Elements with
    ///     matching identifiers within the same namespace will be paired
    ///     together.
    ///   - namespace: The namespace used to organize label and content. Label
    ///     and content under the same namespace with matching identifiers will
    ///     be paired together.
    nonisolated public func accessibilityLabeledPair<ID>(
        role: AccessibilityLabeledPairRole,
        id: ID,
        in namespace: Namespace.ID
    ) -> some View where ID: Hashable {
        accessibilityRelationship(.labeledPair(role), id: id, in: namespace)
    }

    nonisolated func accessibilityRelationship<ID>(
        _ relationship: AccessibilityRelationshipScope.Relationship,
        id: ID,
        in namespace: Namespace.ID
    ) -> some View where ID: Hashable {
        modifier(RelationshipModifier(relationship: relationship, id: id, namespace: namespace))
    }
}

// MARK: - RelationshipModifier

private struct RelationshipModifier<ID: Hashable>: PrimitiveViewModifier, MultiViewModifier, Equatable, CustomStringConvertible {
    var relationship: AccessibilityRelationshipScope.Relationship
    var id: ID
    var namespace: Namespace.ID

    var description: String {
        "AccessibilityRelationshipModifier relationship: \(relationship) id \(id) namespace: \(namespace)"
    }

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresAccessibilityNodes,
           let scope = inputs[AccessibilityRelationshipScope.self],
           let nodeList = outputs.accessibilityNodes {
            let transform = Attribute(Transform(
                modifier: modifier.value,
                nodeList: nodeList,
                accessibilityEnabled: inputs.accessibilityEnabled,
                scope: scope
            ))
            transform.flags = .removable
            outputs.accessibilityNodes = transform
        }
        return outputs
    }
}

// MARK: - Transform

private struct Transform<ID: Hashable>: StatefulRule, ObservedAttribute, RemovableAttribute, CustomStringConvertible {
    typealias Value = AccessibilityNodeList

    struct State: Equatable {
        var modifier: RelationshipModifier<ID>
        var nodeIDs: Set<UniqueID>
    }

    @Attribute var modifier: RelationshipModifier<ID>
    @Attribute var nodeList: AccessibilityNodeList
    @Attribute var accessibilityEnabled: Bool
    var selfAttribute = AnyAttribute.nil
    var scope: AccessibilityRelationshipScope
    var state: State?
    var isRemoved = false

    var description: String { "AccessibilityRelationshipTransform" }

    mutating func updateValue() {
        guard accessibilityEnabled, !isRemoved else {
            value = nodeList
            return
        }
        if selfAttribute == .nil {
            selfAttribute = attribute.identifier
        }
        let (nodeList, changed) = $nodeList.changedValue()
        if updateScope(nodeList: nodeList, changed: changed) {
            value = AccessibilityNodeList(nodes: nodeList.nodes, version: .init(forUpdate: ()))
        } else {
            value = nodeList
        }
    }

    mutating func updateScope(nodeList: AccessibilityNodeList, changed: Bool) -> Bool {
        let modifier = modifier
        let state = State(modifier: modifier, nodeIDs: Set(nodeList.nodes.map(\.id)))
        guard self.state != state, changed else { return false }
        self.state = state
        scope.clear(from: selfAttribute)
        scope.update(
            modifier.relationship,
            nodes: nodeList.nodes,
            identifier: modifier.id,
            in: modifier.namespace,
            from: selfAttribute
        )
        for node in nodeList.nodes {
            node.relationshipScope = scope
        }
        return true
    }

    mutating func insert() {
        guard isRemoved else { return }
        isRemoved = false
        _ = updateScope(nodeList: nodeList, changed: true)
    }

    mutating func destroy() {
        isRemoved = true
        scope.clear(from: selfAttribute)
    }

    static func willRemove(attribute: AnyAttribute) {
        let body = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: Self.self)
        body.pointee.destroy()
    }

    static func didReinsert(attribute: AnyAttribute) {
        let body = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: Self.self)
        body.pointee.insert()
    }
}
