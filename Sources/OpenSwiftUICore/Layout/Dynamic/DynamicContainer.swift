//
//  DynamicContainer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by DynamicPreferenceCombiner and DynamicContainerInfo
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
        package private(set) var items: [DynamicContainer.ItemInfo] = []

        package private(set) var indexMap: [UInt32: Int] = [:]

        private var displayMap: [UInt32]?

        private var removedCount: Int = .zero

        private var unusedCount: Int = .zero

        private var allUnary: Bool = true

        private var seed: UInt32 = .zero

        private func viewIndex(id: ID) -> Int? {
            guard let value = indexMap[id.uniqueId] else {
                return nil
            }
            return value + Int(id.viewIndex)
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

        fileprivate var precedingViewCount: Int32 = .zero

        fileprivate var resetSeed: UInt32 = .zero

        final package private(set) var phase: TransitionPhase?

        final package func `for`<A>(_ type: A.Type) -> DynamicContainer._ItemInfo<A> where A: DynamicContainerAdaptor {
            unsafeDowncast(self, to: DynamicContainer._ItemInfo<A>.self)
        }

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

        package private(set) var item: Adaptor.Item

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
    var count: Int

    init(viewGraph: ViewGraph?, asyncSignal: WeakAttribute<Void>) {
        self.viewGraph = viewGraph
        self.asyncSignal = asyncSignal
        self.count = 0
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

struct DynamicContainerInfo<Adapter>: StatefulRule, AsyncAttribute where Adapter: DynamicContainerAdaptor { // FIXME
    @Attribute
    var asyncSignal: Void

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

    func updateValue() {
        _openSwiftUIUnimplementedFailure()
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
