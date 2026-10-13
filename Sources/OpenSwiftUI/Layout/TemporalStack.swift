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

/// Tags a view's rendered content with the state it represents.
///
/// Use this modifier inside the archived body of a control that can
/// present several states, such as a toggle driven by an app intent.
/// The archive renders every state ahead of time, and the host selects
/// the content to display by matching the hash of the live state against
/// the tags that this modifier writes.
///
/// When the view hierarchy requires a display list, the modifier wraps the
/// content in a state effect keyed by the strong hash of `state`, and it
/// records an archived view state so that the host can animate between
/// states with the current transaction. Outside of an archive, the modifier
/// has no effect.
extension View {
    func temporalState<State>(_ state: State) -> some View where State: StronglyHashable {
        modifier(TemporalStateViewModifier(state: state))
    }
}

// MARK: - TemporalStateViewModifier

/// A modifier that wraps its content in a state effect and reports the
/// state to the enclosing archive.
///
/// The modifier only produces work when the inputs require a display list.
/// It stores the strong hash of the state together with the content display
/// list, appends an ``ArchivedViewState`` for the archived view states
/// preference, and replaces the display list with a single state effect item
/// that the host resolves at display time.
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

/// A view that renders one child for each possible state of an archived
/// control and stacks them at the same position.
///
/// A temporal stack is the archived counterpart of a stateful control. The
/// host that displays an archive cannot evaluate view bodies, so the archive
/// must contain every presentation the control can take. The stack builds a
/// child view for each element of `states` by calling `content`, keeps each
/// child in its own subgraph, and records all children in a single display
/// list item whose entries are keyed by the strong hash of their state.
///
/// For example, an archived toggle that an app intent drives renders its
/// on, off, and mixed presentations at once:
///
///     TemporalStack(states: ToggleState.allCases) { state in
///         // Build the toggle presentation for `state` with a constant binding.
///     }
///     .temporalState(toggleState)
///
/// The children share the layout of a Z-stack with the given alignment, so
/// the stack takes the size of its largest state and every state reports the
/// same geometry. Preferences from the children reduce into one value per key
/// in state order.
///
/// The host chooses the child to show by matching the hash that the
/// ``View/temporalState(_:)`` modifier writes for the live state.
struct TemporalStack<States, Content>: UnaryView, PrimitiveView where States: Collection, States.Element: Equatable & StronglyHashable, Content: View {
    var states: States
    var alignment: Alignment
    var content: (States.Element) -> Content

    /// Creates a temporal stack for the given states.
    ///
    /// - Parameters:
    ///   - states: The collection of states to render. Each state must be
    ///     equatable so that the stack can reuse children across updates,
    ///     and strongly hashable so that the archive can identify them.
    ///   - alignment: The alignment that positions every child within the
    ///     stack. The default is ``Alignment/center``.
    ///   - content: A view builder that creates the presentation for one
    ///     state.
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

/// The hash of a state together with the display list that presents it.
private struct TemporalState: Equatable {
    var hash: StrongHash
    var content: DisplayList
}

// MARK: - TemporalStackChild

/// The graph resources that a temporal stack keeps for one state.
///
/// Each child owns a subgraph so that the stack can invalidate it in
/// isolation when the state disappears from the collection. The identifier
/// is stable for the lifetime of the child and lets geometry lookups survive
/// reordering.
private struct TemporalStackChild<State> {
    var state: State
    var hash: StrongHash
    var subgraph: Subgraph
    var outputs: _ViewOutputs
    var id: UInt32
}

// MARK: - TemporalStackChildren

/// A rule that reconciles the children of a temporal stack with its states.
///
/// The rule walks the states in order. It reuses an existing child whose
/// state matches, moving it forward when the order changed, and it creates a
/// new child for a state that has no match. Children for states that no
/// longer exist are removed from the end and their subgraphs are invalidated.
/// The rule only publishes a new value when the children changed.
///
/// A new child is built in its own subgraph with a copy of the stack inputs.
/// Every child pushes the same stable index because all states stand for the
/// same view in the archive. When geometry is required, the child reads its
/// size and origin from the stack's layout through a
/// ``TemporalStackChildGeometry`` rule. When accessibility nodes are
/// required, the child's nodes carry the hash of the state so that the host
/// can select the nodes that match the live state.
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

/// A rule that evaluates the stack's content builder for one state.
private struct TemporalStackChildView<States, Content>: Rule where States: Collection, States.Element: Equatable & StronglyHashable, Content: View {
    @Attribute var view: TemporalStack<States, Content>
    var state: States.Element

    var value: Content {
        withObservation { view.content(state) }
    }
}

// MARK: - TemporalStackChildGeometry

/// A rule that reads the geometry of one child from the stack's child
/// geometries.
///
/// The rule looks the child up by its identifier rather than by index, so it
/// stays valid when the stack reorders its children. It returns a zero
/// geometry while the child is not part of the layout.
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

/// A rule that lays the children out as a Z-stack with the stack's
/// alignment.
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

/// A rule that produces the display list for a single tagged state.
///
/// The list contains one item whose value is a state effect keyed by the
/// hash of the state and whose content is the original display list. The
/// item spans the view's size at a zero origin.
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

/// A rule that produces the display list for a temporal stack.
///
/// The list contains one states item that pairs the hash of every child
/// with that child's display list, in state order. The item is positioned
/// relative to the container so that the host can place the selected state
/// without further layout.
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

/// A rule that reduces one preference key across the children of a
/// temporal stack.
///
/// The first child that provides the preference seeds the value, and later
/// children fold into it through the key's reduce function. Children that do
/// not provide the preference are skipped.
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

/// A visitor that installs a ``TemporalStackPreference`` rule for every
/// preference key the inputs request.
private struct TemporalStackPreferenceVisitor<State>: PreferenceKeyVisitor {
    var children: Attribute<[TemporalStackChild<State>]>
    var outputs: _ViewOutputs

    mutating func visit<Key>(key: Key.Type) where Key: PreferenceKey {
        outputs[key] = Attribute(TemporalStackPreference<State, Key>(children: children))
    }
}
