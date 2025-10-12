//
//  DynamicContainer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by DynamicPreferenceCombiner
//  ID: E7D4CD2D59FB8C77D6C7E9C534464C17 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - DynamicContainerID

package struct DynamicContainerID: Hashable, Comparable {
    package var uniqueId: UInt32

    package var viewIndex: Int32

    package init(uniqueId: UInt32, viewIndex: Int32) {
        self.uniqueId = uniqueId
        self.viewIndex = viewIndex
    }

    package static func < (lhs: DynamicContainerID, rhs: DynamicContainerID) -> Bool {
        lhs.uniqueId < rhs.uniqueId || (lhs.uniqueId == rhs.uniqueId && lhs.viewIndex < rhs.viewIndex)
    }
}

// MARK: - DynamicContainer

package struct DynamicContainer {
    package typealias ID = DynamicContainerID

    package struct Info: Equatable {
        package fileprivate(set) var items: [DynamicContainer.ItemInfo] = []

        package fileprivate(set) var indexMap: [UInt32: Int] = [:]

        fileprivate(set) var displayMap: [UInt32]?

        fileprivate(set) var removedCount: Int = .zero

        fileprivate(set) var unusedCount: Int = .zero

        fileprivate(set) var allUnary: Bool = true

        fileprivate(set) var seed: UInt32 = .zero

        func viewIndex(id: ID) -> Int? {
            guard let value = indexMap[id.uniqueId] else {
                return nil
            }
            return value + Int(id.viewIndex)
        }

        func item(for subgraph: Subgraph) -> ItemInfo? {
            items.first { info in
                info.subgraph.isAncestor(of: subgraph)
            }
        }

        @inline(__always)
        subscript(_ index: Int) -> ItemInfo {
            precondition(index >= 0 && index < items.count, "invalid view index")
            return items[index]
        }

        package static func == (lhs: DynamicContainer.Info, rhs: DynamicContainer.Info) -> Bool {
            lhs.seed == rhs.seed
        }
    }

    package class ItemInfo {
        fileprivate let subgraph: Subgraph

        final package let uniqueId: UInt32

        fileprivate let viewCount: Int32

        fileprivate let outputs: _ViewOutputs

        fileprivate let needsTransitions: Bool

        fileprivate var listener: DynamicAnimationListener?

        fileprivate var zIndex: Double = .zero

        fileprivate var removalOrder: UInt32 = .zero

        fileprivate(set) var precedingViewCount: Int32 = .zero

        fileprivate var resetSeed: UInt32 = .zero

        final package fileprivate(set) var phase: TransitionPhase?

        package init(
            subgraph: Subgraph,
            uniqueId: UInt32,
            viewCount: Int32,
            phase: TransitionPhase,
            needsTransitions: Bool,
            outputs: _ViewOutputs
        ) {
            self.subgraph = subgraph
            self.uniqueId = uniqueId
            self.viewCount = viewCount
            self.outputs = outputs
            self.needsTransitions = needsTransitions
            self.phase = phase
        }

        package var list: Attribute<any ViewList>? { nil }

        package var id: ViewList.ID? { nil }

        final package func `for`<Adapter>(
            _ type: Adapter.Type
        ) -> DynamicContainer._ItemInfo<Adapter> where Adapter: DynamicContainerAdaptor {
            unsafeDowncast(self, to: DynamicContainer._ItemInfo<Adapter>.self)
        }

        @inline(__always)
        var count: Int32 {
            viewCount + precedingViewCount
        }
    }

    final package class _ItemInfo<Adaptor>: DynamicContainer.ItemInfo where Adaptor: DynamicContainerAdaptor {
        init(
            item: Adaptor.Item,
            itemLayout: Adaptor.ItemLayout,
            subgraph: Subgraph,
            uniqueId: UInt32,
            viewCount: Int32,
            phase: TransitionPhase,
            needsTransitions: Bool,
            outputs: _ViewOutputs
        ) {
            self.item = item
            self.itemLayout = itemLayout
            super.init(
                subgraph: subgraph,
                uniqueId: uniqueId,
                viewCount: viewCount,
                phase: phase,
                needsTransitions: needsTransitions,
                outputs: outputs
            )
        }

        package fileprivate(set) var item: Adaptor.Item

        package let itemLayout: Adaptor.ItemLayout

        override package var list: Attribute<any ViewList>? {
            item.list
        }

        override package var id: _ViewList_ID? {
            item.viewID
        }
    }

    package static func makeContainer<Adaptor>(
        adaptor: Adaptor,
        inputs: _ViewInputs
    ) -> (Attribute<DynamicContainer.Info>, _ViewOutputs) where Adaptor: DynamicContainerAdaptor {
        var outputs = _ViewOutputs()
        for key in inputs.preferences.keys {
            func project<K>(_ key: K.Type) where K: PreferenceKey {
                outputs[key] = Attribute(DynamicPreferenceCombiner<K>(info: .init()))
            }
            project(key)
        }
        let asyncSignal = Attribute(value: ())
        let info = Attribute(DynamicContainerInfo(
            asyncSignal: asyncSignal,
            adaptor: adaptor,
            inputs: inputs,
            outputs: outputs
        ))
        info.addInput(asyncSignal, options: ._4, token: 0)
        info.flags = .transactional
        outputs.forEachPreference { key, identifier in
            func project<K>(_ key: K.Type) where K: PreferenceKey {
                identifier.mutateBody(
                    as: DynamicPreferenceCombiner<K>.self,
                    invalidating: true
                ) { combiner in
                    combiner.$info = info
                }
            }
            project(key)
        }
        return (info, outputs)
    }
}

// MARK: - DynamicAnimationListener

private class DynamicAnimationListener: AnimationListener, @unchecked Sendable {
    weak var viewGraph: ViewGraph?
    let asyncSignal: WeakAttribute<Void>
    var count: Int = 0

    init(viewGraph: ViewGraph?, asyncSignal: WeakAttribute<Void>) {
        self.viewGraph = viewGraph
        self.asyncSignal = asyncSignal
    }

    override func animationWasAdded() {
        count &+= 1
    }

    override func animationWasRemoved() {
        count &-= 1
        guard count == 0, let viewGraph else {
            return
        }
        viewGraph.continueTransaction { [asyncSignal] in
            asyncSignal.attribute?.invalidateValue()
        }
    }
}

// MARK: - DynamicPreferenceCombiner [WIP]

private struct DynamicPreferenceCombiner<K>: Rule, AsyncAttribute, CustomStringConvertible where K: PreferenceKey {
    @OptionalAttribute
    var info: DynamicContainer.Info?

    var value: K.Value {
        // TODO:
        _openSwiftUIUnimplementedWarning()
        return K.defaultValue
    }

    var description: String {
        "∪+ \(K.readableName)"
    }
}

// MARK: - DynamicContainerInfo [WIP]

struct DynamicContainerInfo<Adapter>: StatefulRule, AsyncAttribute, ObservedAttribute, CustomStringConvertible where Adapter: DynamicContainerAdaptor {
    @Attribute var asyncSignal: Void
    var adaptor: Adapter
    let inputs: _ViewInputs
    let outputs: _ViewOutputs
    let parentSubgraph: Subgraph
    var info: DynamicContainer.Info
    var lastUniqueId: UInt32
    var lastRemoved: UInt32
    var lastResetSeed: UInt32
    var needsPhaseUpdate: Bool

    init(
        asyncSignal: Attribute<Void>,
        adaptor: Adapter,
        inputs: _ViewInputs,
        outputs: _ViewOutputs,
        info: DynamicContainer.Info = .init(),
        lastUniqueId: UInt32 = 0,
        lastRemoved: UInt32 = 0,
        lastResetSeed: UInt32 = .max,
        needsPhaseUpdate: Bool = false
    ) {
        self._asyncSignal = asyncSignal
        self.adaptor = adaptor
        self.inputs = inputs
        self.outputs = outputs
        self.parentSubgraph = Subgraph.current!
        self.info = info
        self.lastUniqueId = lastUniqueId
        self.lastRemoved = lastRemoved
        self.lastResetSeed = lastResetSeed
        self.needsPhaseUpdate = needsPhaseUpdate
    }

    typealias Value = DynamicContainer.Info

    mutating func updateValue() {
        let viewPhase = inputs.viewPhase.value
        let resetSeed = viewPhase.resetSeed
        let disableTransitions: Bool
        if resetSeed != lastResetSeed {
            lastResetSeed = resetSeed
            disableTransitions = true
        } else {
            disableTransitions = inputs.base.animationsDisabled
        }
        var needsUpdate = false
        if needsPhaseUpdate {
            for item in info.items {
                guard item.phase == .willAppear else {
                    continue
                }
                needsUpdate = true
                item.phase = .identity
            }
            needsPhaseUpdate = false
        }
        let (changed, hasDepth) = updateItems(disableTransitions: disableTransitions)
        if !changed {
            for (index, item) in info.items.enumerated().reversed() {
                guard let phase = item.phase else {
                    continue
                }
                guard phase == .didDisappear else {
                    break
                }
                if tryRemovingItem(at: index, disableTransitions: disableTransitions) {
                    needsUpdate = true
                }
            }
        }
        if needsUpdate {
            let totalCount = info.items.count
            let unusedCount = info.unusedCount
            let inusedCount = totalCount - unusedCount
            let removedCount = info.removedCount
            let validCount = inusedCount - removedCount
            if validCount < inusedCount {
                var slice = info.items[validCount..<inusedCount]
                slice.sort { $0.removalOrder < $1.removalOrder }
                info.items[validCount..<inusedCount] = slice
            }
            info.indexMap.removeAll(keepingCapacity: true)
            info.allUnary = true
            Swift.assert(inusedCount > 0)
            if totalCount != unusedCount {
                var precedingCount: Int32 = 0
                var allUnary = true
                for index in 0..<inusedCount {
                    let item = info.items[index]
                    info.indexMap[item.uniqueId] = index
                    item.precedingViewCount = precedingCount
                    allUnary = allUnary && item.viewCount == 1
                    info.allUnary = allUnary
                    precedingCount &+= item.viewCount
                }
            }
            precondition(info.indexMap.count == inusedCount, "DynamicLayoutItem identifiers must be unique.")
            if hasDepth {
                let capacity = abs(removedCount != 0 ? validCount + inusedCount : validCount)
                var displayMap: [UInt32] = []
                displayMap.reserveCapacity(capacity)
                for index in 0 ..< validCount {
                    displayMap.append(numericCast(index))
                }
                func lessThen(_ lhs: UInt32, _ rhs: UInt32) -> Bool {
                    info.items[Int(lhs)].zIndex < info.items[Int(rhs)].zIndex
                }
                if totalCount > 31 {
                    displayMap.sort(by: lessThen(_:_:))
                } else {
                    displayMap.insertionSort(by: lessThen(_:_:))
                }
                if removedCount != 0 {
                    func addRemoved() {
                        for index in validCount ..< inusedCount {
                            displayMap.append(numericCast(index))
                        }
                    }
                    let hasAddRemoved: Bool
                    if isLinkedOnOrAfter(.v5) {
                        addRemoved()
                        hasAddRemoved = true
                    } else {
                        hasAddRemoved = false
                    }
                    if validCount != 0 {
                        for index in 0 ..< validCount {
                            displayMap.append(numericCast(displayMap[index]))
                        }
                    }
                    if !hasAddRemoved {
                        addRemoved()
                    }
                    var slice = displayMap[validCount..<validCount + inusedCount]
                    slice.insertionSort(by: lessThen(_:_:))
                    displayMap[validCount..<validCount + inusedCount] = slice
                }
                info.displayMap = displayMap
            } else {
                info.displayMap = nil
            }
            if totalCount != unusedCount {
                for index in 0 ..< inusedCount {
                    let target: Int
                    if let displayMap = info.displayMap {
                        if removedCount == 0 {
                            target = Int(displayMap[index])
                        } else {
                            target = Int(displayMap[info.items.count - (info.unusedCount + info.removedCount)])
                        }
                    } else {
                        if removedCount == 0 {
                            target = index
                        } else {
                            let i = index - info.removedCount
                            target = i >= 0 ? i : info.items.count - (info.unusedCount + info.removedCount)
                        }
                    }
                    info.items[target].subgraph.index = UInt32(index)
                }
            }
        } else {
            if info.items.isEmpty, hasValue {
                return
            }
        }
        info.seed &+= 1
        value = info
    }

    mutating func makeItem(
        _ item: Adapter.Item,
        uniqueId: UInt32,
        container: Attribute<DynamicContainer.Info>,
        disableTransitions: Bool
    ) -> DynamicContainer.ItemInfo {
        let phase: TransitionPhase
        let needsTransitions = item.needsTransitions
        if !disableTransitions && needsTransitions {
            let weakAsyncSignal = WeakAttribute($asyncSignal)
            GraphHost.currentHost.continueTransaction {
                guard let asyncSignal = weakAsyncSignal.attribute else {
                    return
                }
                asyncSignal.invalidateValue()
            }
            needsPhaseUpdate = true
            phase = .willAppear
        } else {
            phase = .identity
        }
        let newSubgraph = Subgraph(
            graph: parentSubgraph.graph,
            attribute: item.list?.identifier ?? .nil
        )
        parentSubgraph.addChild(newSubgraph)
        return newSubgraph.apply {
            var inputs = inputs
            inputs.copyCaches()
            let (containerOutputs, itemLayout) = adaptor.makeItemLayout(
                item: item,
                uniqueId: uniqueId,
                inputs: inputs,
                containerInfo: container
            ) {
                $0.transaction = Attribute(
                    DynamicTransaction(
                        info: container,
                        transaction: $0.transaction,
                        uniqueId: uniqueId,
                        wasRemoved: false
                    )
                )
                $0.viewPhase = Attribute(
                    DynamicViewPhase(
                        info: container,
                        phase: $0.viewPhase,
                        uniqueId: uniqueId
                    )
                )
            }
            return DynamicContainer._ItemInfo<Adapter>(
                item: item,
                itemLayout: itemLayout,
                subgraph: newSubgraph,
                uniqueId: uniqueId,
                viewCount: Int32(item.count),
                phase: phase,
                needsTransitions: needsTransitions,
                outputs: containerOutputs
            )
        }
    }

    private mutating func updateItems(
        disableTransitions: Bool
    ) -> (changed: Bool, hasDepth: Bool) {
        var (changed, hasDepth) = (false, false)
        guard let items = adaptor.updatedItems() else {
            hasDepth = info.displayMap != nil
            return (changed, hasDepth)
        }
        var target = 0
        var count = info.items.count
        adaptor.foreachItem(items: items) { item in
            var reusedIndex = -1
            var foundMatch = false
            for index in target ..< count {
                let inforItem = info.items[index].for(Adapter.self)
                guard inforItem.item.matchesIdentity(of: item) else {
                    if reusedIndex < 0, inforItem.phase == nil {
                        reusedIndex = inforItem.item.canBeReused(by: item) ? index : reusedIndex
                    }
                    continue
                }
                foundMatch = true
                if target != index {
                    info.items.swapAt(target, index)
                    changed = true
                }
                inforItem.item = item
                if inforItem.phase != .identity {
                    unremoveItem(at: target)
                    changed = true
                }
                break
            }
            if !foundMatch {
                if reusedIndex < 0 {
                    if Adapter.Item.supportsReuse {
                        for index in target ..< count {
                            let infoItem = info.items[index].for(Adapter.self)
                            guard !infoItem.needsTransitions,
                               infoItem.item.canBeReused(by: item),
                               !Adapter.containsItem(items, infoItem.item) else {
                                continue
                            }
                            reusedIndex = index
                            break
                        }
                    }
                }
                if reusedIndex >= 0 {
                    let infoItem = info.items[reusedIndex].for(Adapter.self)
                    infoItem.item = item
                    unremoveItem(at: reusedIndex)
                    if target < reusedIndex {
                        info.items.swapAt(target, reusedIndex)
                    }
                } else {
                    lastUniqueId &+= 1
                    let createdItem = makeItem(
                        item,
                        uniqueId: lastUniqueId,
                        container: attribute,
                        disableTransitions: disableTransitions
                    )
                    info.items.append(createdItem)
                    if target < count {
                        info.items.swapAt(target, count)
                    }
                    count &+= 1
                }
                changed = true
            }
            let zIndex = item.zIndex
            hasDepth = hasDepth || (zIndex != 0)

            let infoItem = info.items[target]
            if zIndex != infoItem.zIndex {
                infoItem.zIndex = zIndex
                changed = true
            }
            target &+= 1
        }
        for index in (target ..< count).reversed() {
            let phase = info.items[index].phase
            guard !tryRemovingItem(at: index, disableTransitions: disableTransitions) else {
                changed = true
                continue
            }
            let infoItem = info.items[index]
            let zIndex = infoItem.zIndex
            hasDepth = hasDepth || (zIndex != 0)
            if zIndex != info.items[target].zIndex {
                info.items[target].zIndex = zIndex
                changed = true
            }
            if phase != info.items[target].phase {
                changed = true
            }
        }
        return (changed, hasDepth)
    }

    mutating func tryRemovingItem(
        at index: Int,
        disableTransitions: Bool
    ) -> Bool {
        let items = info.items
        guard let phase = items[index].phase else {
            return false
        }
        switch phase {
        case .willAppear:
            preconditionFailure("")
        case .identity:
            guard !disableTransitions, items[index].needsTransitions else {
                eraseItem(at: index)
                return true
            }
            lastRemoved = max(lastRemoved &+ 1, 1)
            items[index].removalOrder = lastRemoved
            info.removedCount &+= 1
            items[index].phase = .didDisappear
            if let listener = items[index].listener {
                listener.viewGraph = nil
            }
            let newListener = DynamicAnimationListener(
                viewGraph: .current,
                asyncSignal: WeakAttribute($asyncSignal)
            )
            items[index].listener = newListener
            newListener.animationWasAdded()
            Update.enqueueAction { // TODO: reason
                newListener.animationWasRemoved()
            }
            return false
        case .didDisappear:
            let listener = items[index].listener!
            guard listener.count == 0 else {
                return false
            }
            eraseItem(at: index)
            return true
        }
    }

    mutating func unremoveItem(at index: Int) {
        let items = info.items
        let phase: TransitionPhase
        switch items[index].phase {
        case .willAppear, .identity:
            items[index].resetSeed &-= 1
            phase = .identity
        case .didDisappear:
            info.removedCount &-= 1
            items[index].removalOrder = 0
            phase = .identity
        case nil:
            info.unusedCount &-= 1
            let subgraph = items[index].subgraph
            parentSubgraph.addChild(subgraph)
            subgraph.didReinsert()
            phase = .willAppear
        }
        let newPhase = items[index].needsTransitions ? phase : .identity
        items[index].phase = newPhase
        guard newPhase == .willAppear else {
            return
        }
        needsPhaseUpdate = true
        let weakAsyncSignal = WeakAttribute($asyncSignal)
        GraphHost.currentHost.continueTransaction {
            guard let asyncSignal = weakAsyncSignal.attribute else {
                return
            }
            asyncSignal.invalidateValue()
        }
    }

    func eraseItem(at index: Int) {
        _openSwiftUIUnimplementedWarning()
    }

    // DynamicPreferenceCombiner + ObservedAttribute

    mutating func destroy() {
        for item in info.items {
            item.listener?.viewGraph = nil
            if item.phase == nil {
                let subgraph = item.subgraph
                subgraph.willInvalidate(isInserted: false)
                subgraph.invalidate()
            }
        }
    }

    // DynamicPreferenceCombiner + CustomStringConvertible

    var description: String {
        "DynamicContainer<\(Adapter.self)>"
    }
}

// MARK: - DynamicViewPhase

private struct DynamicViewPhase: Rule, AsyncAttribute {
    @Attribute
    var info: DynamicContainer.Info

    @Attribute
    var phase: ViewPhase

    let uniqueId: UInt32

    var value: ViewPhase {
        var phase = phase
        guard let index = info.indexMap[uniqueId] else {
            return phase
        }
        let resetSeed = info.items[index].resetSeed
        let isBeingRemoved = info.items[index].phase == .didDisappear
        phase.resetSeed += resetSeed
        phase.isBeingRemoved = phase.isBeingRemoved || isBeingRemoved
        return phase
    }
}

// MARK: - DynamicTransaction

private struct DynamicTransaction: StatefulRule, AsyncAttribute {
    @Attribute
    var info: DynamicContainer.Info

    @Attribute
    var transaction: Transaction

    let uniqueId: UInt32

    var wasRemoved: Bool

    typealias Value = Transaction

    mutating func updateValue() {
        guard let index = info.indexMap[uniqueId],
              let transitionPhase = info.items[index].phase
        else {
            value = Transaction()
            return
        }
        var transaction = transaction
        let oldWasRemoved = wasRemoved
        wasRemoved = false
        switch transitionPhase {
        case .willAppear:
            transaction.animation = nil
            transaction.disablesAnimations = true
        case .identity:
            break
        case .didDisappear:
            if !oldWasRemoved, let listener = info.items[index].listener {
                transaction.addAnimationListener(listener)
            }
            wasRemoved = true
        }
        value = transaction
    }
}
