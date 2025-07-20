//
//  DynamicLayoutMap.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package struct DynamicLayoutMap {
    private var map: [(id: DynamicContainerID, value: LayoutProxyAttributes)]
    package var sortedArray: [LayoutProxyAttributes]
    package var sortedSeed: UInt32

    package init() {
        map = []
        sortedArray = []
        sortedSeed = .zero
    }

    package init(
        map: [(id: DynamicContainerID, value: LayoutProxyAttributes)],
        sortedArray: [LayoutProxyAttributes] = [LayoutProxyAttributes](),
        sortedSeed: UInt32 = 0 as UInt32
    ) {
        self.map = map
        self.sortedArray = sortedArray
        self.sortedSeed = sortedSeed
    }

    package subscript(id: DynamicContainerID) -> LayoutProxyAttributes {
        get {
            map.first(where: { $0.id == id })?.value ?? .init()
        }
        set {
            let index = map.firstIndex(where: { $0.id == id })
            if let index {
                if newValue.isEmpty {
                    map.remove(at: index)
                } else {
                    map[index].value = newValue
                }
            } else {
                if !newValue.isEmpty {
                    map.insert((id, newValue), at: 0)
                }
            }
            sortedSeed = .zero
        }
    }

    package mutating func remove(uniqueId: UInt32) {
        guard !map.isEmpty else {
            return
        }
        let index = map.partitionPoint { (id, value) in
            DynamicContainerID(uniqueId: uniqueId, viewIndex: 0) <= id
        }
        var endIndex = index
        guard index != map.count else {
            return
        }
        while endIndex != map.count {
            let indexUniqueId = map[index].id.uniqueId
            guard indexUniqueId == uniqueId else {
                break
            }
            endIndex &+= 1
        }
        map.removeSubrange(index ..< endIndex)
        sortedSeed = .zero
    }

    package mutating func attributes(
        info: DynamicContainer.Info
    ) -> [LayoutProxyAttributes] {
        guard sortedSeed != info.seed else {
            return sortedArray
        }
        let allUnary = info.allUnary
        sortedArray.removeAll(keepingCapacity: true)
        var activeCount = info.items.count - (info.unusedCount + info.removedCount)
        let lastActiveIndex = activeCount - 1
        if lastActiveIndex >= 0, !allUnary {
            let lastActiveItem = info.items[lastActiveIndex]
            activeCount &+= Int(lastActiveItem.count)
        }
        for index in 0 ..< activeCount {
            let targetIndex: Int
            if allUnary {
                targetIndex = index
            } else {
                var itemIndex = 0
                while index >= Int(info[itemIndex].count) {
                    itemIndex &+= 1
                }
                targetIndex = itemIndex
            }
            let viewIndex = index - numericCast(info[targetIndex].precedingViewCount)
            let uniqueId = info[targetIndex].uniqueId
            let targetId = DynamicContainerID(uniqueId: uniqueId, viewIndex: Int32(viewIndex))
            var attributes = LayoutProxyAttributes()
            if !map.isEmpty {
                let valueIndex = map.partitionPoint { (id, value) in
                    targetId <= id
                }
                if valueIndex != map.count {
                    let value = map[valueIndex]
                    if value.id == targetId {
                        attributes = value.value
                    }
                }
            }
            sortedArray.append(attributes)
        }
        sortedSeed = info.seed
        return sortedArray
    }
}
