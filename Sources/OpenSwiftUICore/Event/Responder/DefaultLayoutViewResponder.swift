//
//  DefaultLayoutViewResponder.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import OpenAttributeGraphShims

// MARK: - DefaultLayoutResponderFilter [6.5.4]

package struct DefaultLayoutResponderFilter: StatefulRule {
    @Attribute
    package var children: [ViewResponder]

    package let responder: MultiViewResponder

    package init(
        children: Attribute<[ViewResponder]>,
        responder: MultiViewResponder
    ) {
        self._children = children
        self.responder = responder
    }

    package typealias Value = [ViewResponder]

    package mutating func updateValue() {
        let (children, childrenChanged) = $children.changedValue()
        if childrenChanged {
            responder.children = children
        }
        if !hasValue {
            value = [responder]
        }
    }
}

// MARK: - DefaultLayoutViewResponder [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class DefaultLayoutViewResponder: MultiViewResponder {
    final package let inputs: _ViewInputs
    final package let viewSubgraph: Subgraph
    private var childSubgraph: Subgraph?
    private var childViewSubgraph: Subgraph?
    private var invalidateChildren: (() -> Void)?

    package init(inputs: _ViewInputs) {
        self.inputs = inputs
        self.viewSubgraph = Subgraph.current!
        super.init()
    }

    package init(inputs: _ViewInputs, viewSubgraph: Subgraph) {
        self.inputs = inputs
        self.viewSubgraph = Subgraph.current!
        super.init()
    }

    // MARK: - DefaultLayoutViewResponder: ResponderNode

    override open func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        let outputs: _GestureOutputs<Void> = inputs.makeDefaultOutputs()
        guard viewSubgraph.isValid else {
            return outputs
        }
        let currentSubgraph = Subgraph.current!
        let needGestureGraph = inputs.options.contains(.gestureGraph)
        childSubgraph = Subgraph(graph: (needGestureGraph ? currentSubgraph : viewSubgraph).graph)
        viewSubgraph.addChild(childSubgraph!, tag: 1)
        currentSubgraph.addChild(childSubgraph!)
        if needGestureGraph {
            childViewSubgraph = Subgraph(graph: viewSubgraph.graph)
            childSubgraph!.addChild(childViewSubgraph!, tag: 1)
        }
        childSubgraph!.apply {
            let gesture = Attribute(value: DefaultLayoutGesture(responder: self))
            let weakGesture = WeakAttribute(gesture)
            invalidateChildren = {
                Update.enqueueAction { // TODO: enqueAction(reason: 0x5)
                    weakGesture.attribute?.invalidateValue()
                }
            }
            let subgraph = (childViewSubgraph ?? childSubgraph)!
            var childInputs = inputs
            childInputs.viewInputs = self.inputs
            childInputs.copyCaches()
            childInputs.viewSubgraph = subgraph
            let childOutputs = DefaultLayoutGesture.makeDebuggableGesture(
                gesture: _GraphValue(gesture),
                inputs: childInputs
            )
            outputs.overrideDefaultValues(childOutputs)
        }
        return outputs
    }

    override open func resetGesture() {
        invalidateChildren = nil
        childSubgraph = nil
        childViewSubgraph = nil
        super.resetGesture()
    }

    // MARK: - DefaultLayoutViewResponder: MultiViewResponder

    open override func childrenDidChange() {
        if let invalidateChildren {
            invalidateChildren()
        }
        super.childrenDidChange()
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension DefaultLayoutViewResponder: Sendable {}
