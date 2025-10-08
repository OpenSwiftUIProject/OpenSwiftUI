//
//  DynamicLayoutView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
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
        let containsScrollable = inputs.preferences.containsScrollable
        let containsScrollTargetRoleContent = inputs.preferences.containsScrollTargetRoleContent
        let scrollTargetRole = inputs.scrollTargetRole
        let scrollTargetRemovePreference = inputs.scrollTargetRemovePreference
        let withinAccessibilityRotor = inputs.withinAccessibilityRotor

        // FIXME
        var layoutComputer: Attribute<LayoutComputer>!
        let childGeometry: Attribute<[ViewGeometry]>?
        let needLayout = inputs.requestsLayoutComputer || inputs.needsGeometry
        if needLayout || containsScrollable || withinAccessibilityRotor {
            layoutComputer = Attribute(
                DynamicLayoutComputer(
                    layout: root.value,
                    environment: inputs.environment,
                    containerInfo: .init(),
                    layoutMap: .init()
                )
            )
            childGeometry = Attribute(
                LayoutChildGeometries(
                    parentSize: inputs.size,
                    parentPosition: inputs.position,
                    layoutComputer: layoutComputer
                )
            )
        } else {
            childGeometry = nil // .nil here
        }

        // var context2
        var childInputs = inputs
        childInputs.requestsLayoutComputer = false

        if containsScrollTargetRoleContent && scrollTargetRemovePreference {
            inputs.preferences.containsScrollTargetRoleContent = false
            inputs.preferences.containsScrollStateRequest = false
        }
        if let role = scrollTargetRole.attribute {
            childInputs.base.scrollTargetRole = .init()
            childInputs.base.scrollTargetRemovePreference = true
            childInputs.base.setScrollPosition(storage: nil, kind: .scrollContent)
            childInputs.base.setScrollPositionAnchor(.init(), kind: .scrollContent)
        }
        _openSwiftUIUnimplementedFailure()
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

// TODO: - DynamicLayoutViewAdaptor

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
