//
//  DynamicLayoutView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by Scrollable and ContentTransition
//  ID: FF3C661D9D8317A1C8FE2B7FD4EDE12C (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Layout + makeDynamicView

extension Layout {
    static func makeDynamicView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        properties: LayoutProperties,
        list: Attribute<any ViewList>
    ) -> _ViewOutputs {
        var inputs = inputs
        let requiresScrollable = inputs.preferences.requiresScrollable
        let requiresScrollTargetRoleContent = inputs.preferences.requiresScrollTargetRoleContent
        let scrollTargetRole = inputs.scrollTargetRole
        let scrollTargetRemovePreference = inputs.scrollTargetRemovePreference
        let withinAccessibilityRotor = inputs.withinAccessibilityRotor
        var childComputer: Attribute<LayoutComputer>?
        let childGeometry: OptionalAttribute<[ViewGeometry]>
        let needLayout = inputs.requestsLayoutComputer || inputs.needsGeometry
        if needLayout || requiresScrollable || withinAccessibilityRotor {
            let layoutComputer = Attribute(
                DynamicLayoutComputer(
                    layout: root.value,
                    environment: inputs.environment,
                    containerInfo: .init(),
                    layoutMap: .init()
                )
            )
            childComputer = layoutComputer
            childGeometry = .init(Attribute(
                LayoutChildGeometries(
                    parentSize: inputs.size,
                    parentPosition: inputs.position,
                    layoutComputer: layoutComputer
                )
            ))
        } else {
            childGeometry = .init()
        }
        var childInputs = inputs
        childInputs.requestsLayoutComputer = false

        if requiresScrollTargetRoleContent && scrollTargetRemovePreference {
            inputs.preferences.requiresScrollTargetRoleContent = false
            inputs.preferences.requiresScrollStateRequest = false
        }
        if scrollTargetRole.attribute != nil {
            childInputs.base.scrollTargetRole = .init()
            childInputs.base.scrollTargetRemovePreference = true
            childInputs.base.setScrollPosition(storage: nil, kind: .scrollContent)
            childInputs.base.setScrollPositionAnchor(.init(), kind: .scrollContent)
        }
        func mapMutator(thunk: (inout DynamicLayoutMap) -> ()) -> () {
            guard let childComputer else { return }
            childComputer.mutateBody(
                as: DynamicLayoutComputer<Self>.self,
                invalidating: true
            ) { computer in
                thunk(&computer.layoutMap)
            }
        }
        var (containerInfo, outputs) = DynamicContainer.makeContainer(
            adaptor: DynamicLayoutViewAdaptor(
                items: list,
                childGeometries: childGeometry,
                mutateLayoutMap: mapMutator(thunk:)
            ),
            inputs: childInputs
        )
        if let childComputer {
            childComputer.mutateBody(
                as: DynamicLayoutComputer<Self>.self,
                invalidating: true
            ) { computer in
                computer.$containerInfo = containerInfo
            }
        }
        if requiresScrollable || scrollTargetRole.attribute == nil || withinAccessibilityRotor {
            // TODO: Scrollable related
        }
        if inputs.requestsLayoutComputer, let childComputer {
            outputs.layoutComputer = childComputer
        }
        return outputs
    }
}

// MARK: - DynamicLayoutViewChildGeometry

private struct DynamicLayoutViewChildGeometry: StatefulRule, AsyncAttribute {
    @Attribute var containerInfo: DynamicContainer.Info
    @Attribute var childGeometries: [ViewGeometry]
    let id: DynamicContainerID

    typealias Value = ViewGeometry

    func updateValue() {
        guard let index = containerInfo.viewIndex(id: id), index < childGeometries.count else {
            if !hasValue {
                value = .zero
            }
            return
        }
        value = childGeometries[index]
    }
}

// MARK: - DynamicLayoutViewAdaptor [WIP] ContentTransition

struct DynamicLayoutViewAdaptor: DynamicContainerAdaptor {
    private struct MakeTransition: TransitionVisitor {
        var containerInfo: Attribute<DynamicContainer.Info>
        var uniqueId: UInt32
        var item: DynamicViewListItem
        var inputs: _ViewInputs
        var makeElt: (_ViewInputs) -> _ViewOutputs
        var outputs: _ViewOutputs?
        var isArchived: Bool

        mutating func visit<T>(_ transition: T) where T: Transition {
            let helper =  TransitionHelper(
                list: .init(item.list),
                info: containerInfo,
                uniqueID: uniqueId,
                transition: transition,
                phase: .identity
            )
            if isArchived {
                makeArchivedTransition(helper: helper)
            } else {
                let transition = Attribute(
                    ViewListTransition(helper: helper)
                )
                let makeElt = self.makeElt
                outputs = T.makeView(
                    view: .init(transition),
                    inputs: inputs,
                    body: { _, inputs in
                        makeElt(inputs)
                    }
                )
            }
        }

        mutating func makeArchivedTransition<T>(helper: TransitionHelper<T>) where T: Transition {
            guard helper.transition.hasContentTransition else {
                outputs = makeElt(inputs)
                return
            }
            // TODO: archived transition
            _openSwiftUIUnimplementedFailure()
        }
    }

    struct ItemLayout {
        var release: ViewList.Elements.Release?
    }

    @Attribute var items: ViewList
    @OptionalAttribute var childGeometries: [ViewGeometry]?
    var mutateLayoutMap: ((inout DynamicLayoutMap) -> ()) -> ()

    func updatedItems() -> ViewList? {
        let (items, itemsChanged) = $items.changedValue()
        guard itemsChanged else {
            return nil
        }
        return items
    }

    func foreachItem(
        items: any ViewList,
        _ body: (DynamicViewListItem) -> Void
    ) {
        var index = 0
        items.applySublists(from: &index, list: $items) { sublist in
            body(.init(
                id: sublist.id,
                elements: sublist.elements,
                traits: sublist.traits,
                list: sublist.list
            ))
            return true
        }
    }

    static func containsItem(
        _ items: any ViewList,
        _ item: DynamicViewListItem
    ) -> Bool {
        var index = 0
        let result = items.applySublists(from: &index, list: nil) { sublist in
            sublist.id != item.id
        }
        return !result
    }

    func makeItemLayout(
        item: DynamicViewListItem,
        uniqueId: UInt32,
        inputs: _ViewInputs,
        containerInfo: Attribute<DynamicContainer.Info>,
        containerInputs: (inout _ViewInputs) -> ()
    ) -> (_ViewOutputs, DynamicLayoutViewAdaptor.ItemLayout) {
        let isArchived = inputs.archivedView.isArchived
        let traits = item.traits
        let transition: AnyTransition?
        if let t = traits.optionalTransition(ignoringIdentity: !isArchived) {
            let prefersCrossFadeTransitions = Graph.withoutUpdate {
                inputs.environment.value.accessibilityPrefersCrossFadeTransitions
            }
            transition = t.adjustedForAccessibility(prefersCrossFade: prefersCrossFadeTransitions)
        } else {
            transition = nil
        }
        var containerID = DynamicContainerID(uniqueId: uniqueId, viewIndex: 0)
        let outputs = item.elements.makeAllElements(inputs: inputs) { elementInputs, body in
            var elementInputs = elementInputs
            if elementInputs.needsGeometry {
                let childGeometry = Attribute(
                    DynamicLayoutViewChildGeometry(
                        containerInfo: containerInfo,
                        childGeometries: $childGeometries!,
                        id: containerID
                    )
                )
                elementInputs.size = childGeometry.size()
                elementInputs.position = childGeometry.origin()
            }
            let outputs: _ViewOutputs
            if let transition {
                var makeTransition = MakeTransition(
                    containerInfo: containerInfo,
                    uniqueId: uniqueId,
                    item: item,
                    inputs: elementInputs,
                    makeElt: body,
                    isArchived: isArchived
                )
                transition.visitBase(applying: &makeTransition)
                outputs = makeTransition.outputs!
            } else {
                outputs = body(elementInputs)
            }
            mutateLayoutMap({
                $0[containerID] = LayoutProxyAttributes(
                    layoutComputer: .init(outputs.layoutComputer),
                    traitsList: .init(item.list)
                )
            })
            containerID.viewIndex &+= 1
            return outputs
        }
        return (outputs ?? .init(), .init(release: item.elements.retain()))
    }

    func removeItemLayout(uniqueId: UInt32, itemLayout: ItemLayout) {
        mutateLayoutMap({ $0.remove(uniqueId: uniqueId)})
    }
}

// MARK: - DynamicLayoutComputer

private struct DynamicLayoutComputer<L>: StatefulRule, AsyncAttribute, CustomStringConvertible where L: Layout {
    @Attribute var layout: L
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var containerInfo: DynamicContainer.Info?

    var layoutMap: DynamicLayoutMap

    typealias Value = LayoutComputer

    mutating func updateValue() {
        updateLayoutComputer(
            layout: layout,
            environment: $environment,
            attributes: layoutMap.attributes(info: containerInfo!)
        )
    }

    var description: String {
        "\(L.self) → LayoutComputer"
    }
}

// TODO: DynamicLayoutScrollable

struct DynamicLayoutScrollable {}

// TODO: - ViewListContentTransition

// FIXME
struct ContentTransitionEffect {}

private struct ViewListContentTransition<T>: StatefulRule, AsyncAttribute where T: Transition {
    var helper: TransitionHelper<T>
    @Attribute var size: ViewSize
    @Attribute var environment: EnvironmentValues

    init(
        helper: TransitionHelper<T>,
        size: Attribute<ViewSize>,
        environment: Attribute<EnvironmentValues>
    ) {
        self.helper = helper
        self._size = size
        self._environment = environment
    }

    typealias Value = ContentTransitionEffect

    func updateValue() {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ViewListArchivedAnimation

private struct ViewListArchivedAnimation: Rule, AsyncAttribute {
    struct Effect: _RendererEffect {
        var animation: Animation?
        var value: StrongHash?

        func effectValue(size: CGSize) -> DisplayList.Effect {
            guard let value else {
                return .identity
            }
            return .interpolatorAnimation(
                .init(
                    value: value,
                    animation: animation
                )
            )
        }
    }

    @OptionalAttribute var traitsList: (any ViewList)?

    var value: Effect {
        guard let traitsList else {
            return .init()
        }
        guard let trait = traitsList.traits.archivedAnimationTrait else {
            return .init()
        }
        return Effect(animation: trait.animation, value: trait.hash)
    }
}

// MARK: - TransitionHelper

private struct TransitionHelper<T> where T: Transition {
    @OptionalAttribute var list: (any ViewList)?
    @Attribute var info: DynamicContainer.Info
    let uniqueID: UInt32
    var transition: T
    var phase: TransitionPhase

    mutating func update() -> Bool {
        var changed = false
        if let index = info.indexMap[uniqueID] {
            let itemInfo = info.items[index]
            if let itemPhase = itemInfo.phase {
                changed = phase != itemPhase
                phase = itemPhase
            }
        }
        guard phase != .didDisappear else {
            return changed
        }
        let traits = list?.traits ?? .init()
        traits.transition.base(as: T.self).map {
            transition = $0
            changed = true
        }
        return changed
    }
}

// MARK: - ViewListTransition

private struct ViewListTransition<T>: StatefulRule, AsyncAttribute where T: Transition {
    var helper: TransitionHelper<T>

    typealias Value = T.Body

    mutating func updateValue() {
        let changed = helper.update()
        guard changed || !hasValue else {
            return
        }
        value = helper.transition.body(content: .init(), phase: helper.phase)
    }
}
