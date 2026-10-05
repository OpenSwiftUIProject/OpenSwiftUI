//
//  AccessibilityFocusStore.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2CCA6A140D82DC7D61A1924E7705DDD6 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore
import struct OpenSwiftUICore.UniqueID

// MARK: - AccessibilityFocusStoreLocation

class AccessibilityFocusStoreLocation<Value>: AnyLocation<Value>, Location where Value: Hashable {
    var store = AccessibilityFocusStore()
    weak var host: GraphHost?
    var resetValue: Value
    var technologies: AccessibilityTechnologies
    var deferredUpdate: (Value, DisplayList.Version)?
    var resolvedEntry: AccessibilityFocusStore.Entry<Value>?
    var resolvedVersion = DisplayList.Version()
    var _wasRead = false

    init(host: GraphHost, resetValue: Value, technologies: AccessibilityTechnologies) {
        self.host = host
        self.resetValue = resetValue
        self.technologies = technologies
        super.init()
    }

    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    override var wasRead: Bool {
        get { _wasRead }
        set { _wasRead = newValue }
    }

    func getValue(forReading: Bool) -> Value {
        if GraphHost.isUpdating, forReading {
            _wasRead = true
        }
        if resolvedEntry == nil || store.version != resolvedVersion {
            resolvedEntry = resolve()
            resolvedVersion = store.version
        }
        return resolvedEntry?.prototype ?? resetValue
    }

    private func resolve() -> AccessibilityFocusStore.Entry<Value>? {
        var result: AccessibilityFocusStore.Entry<Value>?
        store.plists[id]?.forEach(keyType: AccessibilityFocusStore.Key<Value>.self) { entry, stop in
            guard let entry else { return }

            func find(_ match: AccessibilityFocus.Match) -> AccessibilityFocusStore.Entry<Value>? {
                var nodeIDs: Set<UniqueID> = []
                for technology in AccessibilityTechnology.allCases where technologies.contains(.init(list: [technology])) {
                    nodeIDs = (store.matchData[technology]?[match] ?? []).union(nodeIDs)
                }
                for nodeID in nodeIDs where entry.nodeIDs.contains(nodeID) {
                    return entry
                }
                return nil
            }

            if let entry = find(.directlyFocused)
                ?? find(.implicitlyFocused)
                ?? find(.platformChildFocused)
                ?? find(.containerChildFocused) {
                result = entry
                stop = true
            }
        }
        return result
    }

    override func get() -> Value {
        getValue(forReading: false)
    }

    override func update() -> (Value, Bool) {
        let oldValue = resolvedEntry?.prototype
        let value = getValue(forReading: false)
        return (value, !compareValues(oldValue, Optional(value)))
    }

    func deferUpdate(_ value: Value) {
        deferredUpdate = (value, resolvedVersion)
    }

    func performDeferredUpdate() {
        if let (value, version) = deferredUpdate,
           version.value == resolvedVersion.value || version.value == 0 {
            set(value, transaction: .current)
        } else {
            deferredUpdate = nil
        }
    }

    override func set(_ value: Value, transaction: Transaction) {
        host?.asyncTransaction(transaction) { [weak self] in
            guard let self else { return }
            deferredUpdate = nil
            guard let entry = find(for: value) else {
                deferUpdate(value)
                return
            }
            let nodes = entry.orderedNodes.compactMap(\.base)
            var target = nodes.first {
                $0.impliedVisibility(consideringParent: true, with: nil) != .hidden
            }
            if target == nil {
                for node in nodes {
                    var ancestor: AccessibilityNode? = node
                    while let node = ancestor {
                        if node.impliedVisibility(consideringParent: true, with: nil) != .hidden {
                            target = node
                            break
                        }
                        ancestor = node.parent
                    }
                    if target != nil {
                        break
                    }
                }
            }
            if let target {
                AccessibilityFocus.move(to: target.platformElement ?? target, for: technologies)
            }
        }
    }

    private func find(for value: Value) -> AccessibilityFocusStore.Entry<Value>? {
        var result: AccessibilityFocusStore.Entry<Value>?
        store.plists[id]?.forEach(keyType: AccessibilityFocusStore.Key<Value>.self) { entry, stop in
            if let entry, value == entry.prototype {
                result = entry
                stop = true
            }
        }
        return result
    }
}

// MARK: - AccessibilityFocusStore

struct AccessibilityFocusStore {
    var version: DisplayList.Version = .init()
    var matchData: [AccessibilityTechnology: [AccessibilityFocus.Match: Set<UniqueID>]] = [:]
    var plists: [ObjectIdentifier: PropertyList] = [:]

    struct Entry<A> where A: Hashable {
        var prototype: A
        var orderedNodes: [WeakBox<AccessibilityNode>]
        var nodeIDs: Set<UniqueID>
    }

    struct Key<A>: PropertyKey where A: Hashable {
        static var defaultValue: Entry<A>? { nil }
    }

    init() {
        _openSwiftUIEmptyStub()
    }

    init(_ list: AccessibilityFocusStoreList) {
        version = list.version
        makeStoreContent(list)
    }

    private mutating func makeStoreContent(_ list: AccessibilityFocusStoreList) {
        for item in list.items {
            var plist = plists[item.propertyID] ?? PropertyList()
            item.storeUpdateAction.update(item.orderedNodes, item.nodeIDs, &plist)
            plists[item.propertyID] = plist
            item.matches.forEach { technology, match in
                var matches = matchData[technology] ?? [:]
                matches[match] = item.nodeIDs.union(matches[match] ?? [])
                matchData[technology] = matches
            }
        }
    }
}

// MARK: - AccessibilityFocusStoreList

struct AccessibilityFocusStoreList {
    var items: [Item] = []

    var version: DisplayList.Version {
        items.reduce(DisplayList.Version()) { max($0, $1.version) }
    }

    struct Key: HostPreferenceKey {
        static let defaultValue = AccessibilityFocusStoreList()

        static func reduce(value: inout AccessibilityFocusStoreList, nextValue: () -> AccessibilityFocusStoreList) {
            value.items.append(contentsOf: nextValue().items)
        }
    }

    struct Item {
        var version: DisplayList.Version
        var propertyID: ObjectIdentifier
        var storeUpdateAction: AccessibilityFocusStoreUpdateAction
        var orderedNodes: [WeakBox<AccessibilityNode>]
        var nodeIDs: Set<UniqueID>
        var matches: [AccessibilityTechnology: AccessibilityFocus.Match]
    }
}

// MARK: - AccessibilityFocusStoreInputKey

private struct AccessibilityFocusStoreInputKey: ViewInput {
    static var defaultValue: OptionalAttribute<AccessibilityFocusStore> { .init() }
}

extension _ViewInputs {
    var accessibilityFocusStore: Attribute<AccessibilityFocusStore>? {
        get { base.accessibilityFocusStore }
        set { base.accessibilityFocusStore = newValue }
    }
}

extension _GraphInputs {
    var accessibilityFocusStore: Attribute<AccessibilityFocusStore>? {
        get { self[AccessibilityFocusStoreInputKey.self].attribute }
        set { self[AccessibilityFocusStoreInputKey.self] = .init(newValue) }
    }
}

// MARK: - AccessibilityFocusStoreListModifier

struct AccessibilityFocusStoreListModifier<A>: PrimitiveViewModifier, MultiViewModifier where A: Hashable {
    let binding: AccessibilityFocusState<A>.Binding
    let prototype: A

    init(binding: AccessibilityFocusState<A>.Binding, prototype: A) {
        self.binding = binding
        self.prototype = prototype
    }

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.preferences.requiresAccessibilityNodes else {
            return _ViewOutputs()
        }
        var outputs = body(_Graph(), inputs)
        let list = Attribute(ItemFilter(
            modifier: modifier.value,
            accessibilityNodeList: .init(outputs.accessibilityNodes),
            currentFocus: .init(inputs.accessibilityFocus),
            accessibilityEnabled: inputs.accessibilityEnabled
        ))
        let transform = Attribute(ListTransform(list: list))
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: AccessibilityFocusStoreList.Key.self,
            transform: transform
        )
        return outputs
    }

    struct ListTransform: Rule {
        @Attribute var list: AccessibilityFocusStoreList

        var value: (inout AccessibilityFocusStoreList) -> Void {
            { [list] value in
                value.items.append(contentsOf: list.items)
            }
        }
    }

    private struct ItemFilter: StatefulRule {
        @Attribute var modifier: AccessibilityFocusStoreListModifier
        @OptionalAttribute var accessibilityNodeList: AccessibilityNodeList?
        @OptionalAttribute var currentFocus: AccessibilityFocus?
        @Attribute var accessibilityEnabled: Bool
        var matches: [AccessibilityTechnology: AccessibilityFocus.Match] = [:]
        var nodeIDs: [UniqueID] = []

        typealias Value = AccessibilityFocusStoreList

        mutating func updateValue() {
            guard accessibilityEnabled else {
                value = AccessibilityFocusStoreList()
                return
            }
            let (modifier, modifierChanged) = $modifier.changedValue()
            let nodeList = accessibilityNodeList ?? AccessibilityNodesKey.defaultValue
            let oldNodeIDs = nodeIDs
            nodeIDs = nodeList.nodes.map(\.id)
            let nodesChanged = nodeIDs != oldNodeIDs
            var newMatches: [AccessibilityTechnology: AccessibilityFocus.Match] = [:]
            for technology in AccessibilityTechnology.focusSupportingTechnologies {
                var match: AccessibilityFocus.Match?
                for node in nodeList.nodes {
                    let focus = currentFocus ?? AccessibilityFocus()
                    guard let target = focus.byTechnology[technology],
                          target.match(focusStoreNode: node) != nil else {
                        continue
                    }
                    let nodeMatch = target.match(focusStoreNode: node)!
                    if let previousMatch = match {
                        if nodeMatch.takesPriority(over: previousMatch) {
                            match = nodeMatch
                        }
                    } else {
                        match = nodeMatch
                    }
                    if match == .directlyFocused {
                        break
                    }
                }
                newMatches[technology] = match
            }
            let matchesChanged = newMatches != matches
            if matchesChanged {
                matches = newMatches
            }
            if matchesChanged || modifierChanged || nodesChanged || !hasValue {
                let action = AccessibilityFocusStoreUpdateAction(prototype: modifier.prototype)
                value = AccessibilityFocusStoreList(items: [.init(
                    version: .init(forUpdate: ()),
                    propertyID: modifier.binding.propertyID,
                    storeUpdateAction: action,
                    orderedNodes: nodeList.nodes.map { WeakBox($0) },
                    nodeIDs: Set(nodeList.nodes.map(\.id)),
                    matches: matches
                )])
            }
        }
    }
}

// MARK: - AccessibilityFocusStoreUpdateAction

struct AccessibilityFocusStoreUpdateAction {
    let update: ([WeakBox<AccessibilityNode>], Set<UniqueID>, inout PropertyList) -> Void

    init<A>(prototype: A) where A: Hashable {
        update = { orderedNodes, nodeIDs, plist in
            plist[AccessibilityFocusStore.Key<A>.self] = .init(
                prototype: prototype,
                orderedNodes: orderedNodes,
                nodeIDs: nodeIDs
            )
        }
    }
}
