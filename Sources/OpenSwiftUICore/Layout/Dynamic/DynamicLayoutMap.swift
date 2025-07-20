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

        while endIndex != map.count {
            let indexUniqueId = map[index].id.uniqueId
            guard indexUniqueId == uniqueId else {
                break
            }
            endIndex &+= 1
        }
        map.removeSubrange(index ..< endIndex)
    }
}
