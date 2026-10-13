//
//  TemporalStack.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4352BA3B6EC249A24F6BF0A1A1A4160D (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - View + TemporalState

extension View {
    func temporalState<State>(_ state: State) -> some View where State: StronglyHashable {
        modifier(TemporalStateViewModifier(state: state))
    }
}

// MARK: - TemporalStateViewModifier

private struct TemporalStateViewModifier<State>: PrimitiveViewModifier, MultiViewModifier where State: StronglyHashable {
    var state: State

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var childInputs = inputs
        childInputs.containerPosition = inputs.animatedPosition()
        var outputs = body(_Graph(), childInputs)
        if inputs.preferences.requiresDisplayList {
            let state = Attribute(MakeState(modifier: modifier.value, content: .init(outputs.displayList)))
            if inputs.preferences.contains(ArchivedViewStatesKey.self) {
                let states = Attribute(AddState(
                    state: state,
                    childStates: .init(outputs[ArchivedViewStatesKey.self]),
                    transaction: inputs.transaction
                ))
                states.flags = .transactional
                outputs[ArchivedViewStatesKey.self] = states
            }
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(TemporalStateDisplayList(
                identity: identity,
                state: state,
                size: inputs.animatedSize(),
                options: inputs[DisplayList.Options.self]
            ))
        }
        return outputs
    }

    struct MakeState: Rule {
        @Attribute var modifier: TemporalStateViewModifier
        @OptionalAttribute var content: DisplayList?

        var value: TemporalState {
            TemporalState(hash: StrongHash(of: modifier.state), content: content ?? DisplayList())
        }
    }

    struct AddState: Rule {
        @Attribute var state: TemporalState
        @OptionalAttribute var childStates: [ArchivedViewState]?
        @Attribute var transaction: Transaction

        var value: [ArchivedViewState] {
            var states = childStates ?? []
            states.append(ArchivedViewState(
                id: .init(hash: state.hash, creator: $state.identifier),
                animation: transaction.animation
            ))
            return states
        }
    }
}

// MARK: - TemporalStack

struct TemporalStack<States, Content>: UnaryView, PrimitiveView where States: Collection, States.Element: Equatable & StronglyHashable, Content: View {
    var states: States
    var alignment: Alignment
    var content: (States.Element) -> Content

    init(states: States, alignment: Alignment = .center, @ViewBuilder content: @escaping (States.Element) -> Content) {
        self.states = states
        self.alignment = alignment
        self.content = content
    }

    static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let requiresDisplayList = inputs.preferences.requiresDisplayList
        var childInputs = inputs
        if requiresDisplayList {
            childInputs.containerPosition = inputs.animatedPosition()
        }
        let children = Attribute(TemporalStackChildren(view: view.value, inputs: childInputs))
        var outputs = _ViewOutputs()
        if requiresDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(TemporalStackDisplayList(
                identity: identity,
                children: children,
                size: inputs.animatedSize(),
                position: inputs.animatedPosition(),
                containerPosition: inputs.containerPosition
            ))
        }
        if inputs.needsGeometry || inputs.requestsLayoutComputer {
            let layoutComputer = Attribute(TemporalStackLayoutComputer(
                children: children,
                alignment: view[\.alignment].value,
                environment: inputs.environment
            ))
            if inputs.needsGeometry {
                let geometries = Attribute(LayoutChildGeometries(
                    parentSize: inputs.size,
                    parentPosition: inputs.position,
                    layoutComputer: layoutComputer
                ))
                children.mutateBody(as: TemporalStackChildren<States, Content>.self, invalidating: true) {
                    $0.$childGeometries = geometries
                }
            }
            outputs.layoutComputer = layoutComputer
        }
        var visitor = TemporalStackPreferenceVisitor(children: children, outputs: outputs)
        for key in inputs.preferences.keys where key != DisplayList.Key.self {
            key.visitKey(&visitor)
        }
        return visitor.outputs
    }
}

// MARK: - TemporalState

private struct TemporalState: Equatable {
    var hash: StrongHash
    var content: DisplayList
}

// MARK: - TemporalStackChild

private struct TemporalStackChild<State> {
    var state: State
    var hash: StrongHash
    var subgraph: Subgraph
    var outputs: _ViewOutputs
    var id: UInt32
}

// MARK: - TemporalStackChildren

private struct TemporalStackChildren<States, Content>: StatefulRule where States: Collection, States.Element: Equatable & StronglyHashable, Content: View {
    @Attribute var view: TemporalStack<States, Content>
    let inputs: _ViewInputs
    @OptionalAttribute var childGeometries: [ViewGeometry]?
    let parentSubgraph = Subgraph.current!
    var children: [TemporalStackChild<States.Element>] = []
    var nextID: UInt32 = 0

    init(view: Attribute<TemporalStack<States, Content>>, inputs: _ViewInputs) {
        _view = view
        self.inputs = inputs
        _childGeometries = OptionalAttribute()
    }

    typealias Value = [TemporalStackChild<States.Element>]

    mutating func updateValue() {
        let states = view.states
        var changed = false
        var index = 0
        for state in states {
            if let oldIndex = children[index...].firstIndex(where: { $0.state == state }) {
                if oldIndex != index {
                    children.swapAt(index, oldIndex)
                    changed = true
                }
            } else {
                let owner = Attribute<Value>(identifier: AnyAttribute.current!)
                let subgraph = Subgraph(graph: parentSubgraph.graph)
                parentSubgraph.addChild(subgraph)
                subgraph.apply {
                    let id = nextID
                    nextID &+= 1
                    var childInputs = inputs
                    childInputs.copyCaches()
                    // Each state represents the same view in the archive.
                    childInputs.base.pushStableIndex(0)
                    if let geometries = $childGeometries {
                        let geometry = Attribute(TemporalStackChildGeometry(
                            children: owner,
                            childID: id,
                            childGeometries: geometries
                        ))
                        childInputs.size = geometry.size()
                        childInputs.position = geometry.origin()
                    }
                    let child = Attribute(TemporalStackChildView(view: $view, state: state))
                    var outputs = Content.makeDebuggableView(view: _GraphValue(child), inputs: childInputs)
                    let hash = StrongHash(of: state)
                    if inputs.preferences.requiresAccessibilityNodes {
                        let modifier = _GraphValue(Attribute(value: AccessibilityAttachmentModifier(
                            AccessibilityProperties(AccessibilityProperties.TemporalState.self, hash)
                        )))
                        outputs.accessibilityNodes = AccessibilityAttachmentModifier.makeAccessibilityPropertiesTransform(
                            modifier: modifier,
                            inputs: childInputs,
                            outputs: outputs
                        )
                    }
                    children.insert(TemporalStackChild(state: state, hash: hash, subgraph: subgraph, outputs: outputs, id: id), at: index)
                }
                changed = true
            }
            index += 1
        }
        while children.count > index {
            let child = children.removeLast()
            child.subgraph.willInvalidate(isInserted: true)
            child.subgraph.invalidate()
            changed = true
        }
        if changed || !hasValue {
            value = children
        }
    }
}

// MARK: - TemporalStackChildView

private struct TemporalStackChildView<States, Content>: Rule where States: Collection, States.Element: Equatable & StronglyHashable, Content: View {
    @Attribute var view: TemporalStack<States, Content>
    var state: States.Element

    var value: Content {
        withObservation { view.content(state) }
    }
}

// MARK: - TemporalStackChildGeometry

private struct TemporalStackChildGeometry<State>: Rule {
    @Attribute var children: [TemporalStackChild<State>]
    var childID: UInt32
    @Attribute var childGeometries: [ViewGeometry]

    var value: ViewGeometry {
        guard let index = children.firstIndex(where: { $0.id == childID }) else { return .zero }
        return childGeometries[index]
    }
}

// MARK: - TemporalStackLayoutComputer

private struct TemporalStackLayoutComputer<State>: StatefulRule {
    @Attribute var children: [TemporalStackChild<State>]
    @Attribute var alignment: Alignment
    @Attribute var environment: EnvironmentValues

    typealias Value = LayoutComputer

    mutating func updateValue() {
        updateLayoutComputer(
            layout: _ZStackLayout(alignment: alignment),
            environment: $environment,
            attributes: children.map { LayoutProxyAttributes(layoutComputer: .init($0.outputs.layoutComputer)) }
        )
    }
}

// MARK: - TemporalStateDisplayList

private struct TemporalStateDisplayList: StatefulRule {
    let identity: DisplayList.Identity
    @Attribute var state: TemporalState
    @Attribute var size: ViewSize
    let options: DisplayList.Options

    typealias Value = DisplayList

    mutating func updateValue() {
        var item = DisplayList.Item(
            .effect(.state(state.hash), state.content),
            frame: CGRect(origin: .zero, size: size.value),
            identity: identity,
            version: DisplayList.Version(forUpdate: ())
        )
        item.canonicalize(options: options)
        value = DisplayList(item)
    }
}

// MARK: - TemporalStackDisplayList

private struct TemporalStackDisplayList<State>: Rule {
    let identity: DisplayList.Identity
    @Attribute var children: [TemporalStackChild<State>]
    @Attribute var size: ViewSize
    @Attribute var position: CGPoint
    @Attribute var containerPosition: CGPoint

    var value: DisplayList {
        let version = DisplayList.Version(forUpdate: ())
        let origin = CGPoint(x: position.x - containerPosition.x, y: position.y - containerPosition.y)
        return DisplayList(DisplayList.Item(
            .states(children.map { ($0.hash, $0.outputs.displayList?.value ?? DisplayList()) }),
            frame: CGRect(origin: origin, size: size.value),
            identity: identity,
            version: version
        ))
    }
}

// MARK: - TemporalStackPreference

private struct TemporalStackPreference<State, Key>: Rule where Key: PreferenceKey {
    @Attribute var children: [TemporalStackChild<State>]

    var value: Key.Value {
        var value = Key.defaultValue
        var isFirst = true
        for child in children {
            guard let attribute = child.outputs[Key.self] else { continue }
            if isFirst {
                value = attribute.value
                isFirst = false
            } else {
                Key.reduce(value: &value) { attribute.value }
            }
        }
        return value
    }
}

private struct TemporalStackPreferenceVisitor<State>: PreferenceKeyVisitor {
    var children: Attribute<[TemporalStackChild<State>]>
    var outputs: _ViewOutputs

    mutating func visit<Key>(key: Key.Type) where Key: PreferenceKey {
        outputs[key] = Attribute(TemporalStackPreference<State, Key>(children: children))
    }
}
