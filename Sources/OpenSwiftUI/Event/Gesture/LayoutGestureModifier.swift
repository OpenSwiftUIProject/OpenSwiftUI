//
//  LayoutGestureModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C5092FB715856B3D6BCF7C86F15C00D4 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - View + layoutGesture

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Routes events to the responders of this view through a layout gesture.
    ///
    /// - Parameter transform: A closure that creates the layout gesture for
    ///   the responder that owns this view's child responders.
    /// - Returns: A view whose child responders receive events through the
    ///   gesture that `transform` creates.
    nonisolated func layoutGesture<G>(
        _ transform: @escaping (MultiViewResponder) -> G
    ) -> some View where G: Gesture, G.Value == Void {
        modifier(LayoutGestureModifier(transform: transform))
    }
}

// MARK: - LayoutGestureResponder

private final class LayoutGestureResponder<G>: MultiViewResponder where G: Gesture, G.Value == Void {
    let modifier: Attribute<LayoutGestureModifier<G>>
    let inputs: _ViewInputs
    let viewSubgraph: Subgraph
    private var childSubgraph: Subgraph?
    private var childViewSubgraph: Subgraph?
    private var invalidateChildren: (() -> Void)?

    init(modifier: Attribute<LayoutGestureModifier<G>>, inputs: _ViewInputs) {
        self.modifier = modifier
        self.inputs = inputs
        self.viewSubgraph = Subgraph.current!
        super.init()
    }

    // MARK: - LayoutGestureResponder: ResponderNode

    override func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
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
            let gesture = Attribute(LayoutGestureChild(modifier: modifier, node: self))
            let weakGesture = WeakAttribute(gesture)
            invalidateChildren = {
                Update.enqueueAction(reason: nil) {
                    weakGesture.attribute?.invalidateValue()
                }
            }
            let subgraph = (childViewSubgraph ?? childSubgraph)!
            var childInputs = inputs
            childInputs.mergeViewInputs(self.inputs, viewSubgraph: subgraph)
            let childOutputs = G.makeDebuggableGesture(
                gesture: _GraphValue(gesture),
                inputs: childInputs
            )
            outputs.overrideDefaultValues(childOutputs)
        }
        return outputs
    }

    override func resetGesture() {
        invalidateChildren = nil
        childSubgraph = nil
        childViewSubgraph = nil
        super.resetGesture()
    }

    // MARK: - LayoutGestureResponder: MultiViewResponder

    override func childrenDidChange() {
        if let invalidateChildren {
            invalidateChildren()
        }
        super.childrenDidChange()
    }
}

// MARK: - LayoutGestureModifier

/// A modifier that installs a layout gesture over the responders of its
/// content.
///
/// The modifier collects the view responders of its content under a single
/// ``MultiViewResponder``. When the responder makes its gesture, it asks
/// `transform` for the gesture that routes events to those children.
struct LayoutGestureModifier<G>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where G: Gesture, G.Value == Void {
    /// Creates the layout gesture for the responder that owns the content.
    var transform: (MultiViewResponder) -> G

    init(transform: @escaping (MultiViewResponder) -> G) {
        self.transform = transform
    }

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresViewResponders {
            let filter = LayoutResponderFilter(
                children: outputs.viewResponders(),
                responder: LayoutGestureResponder(modifier: modifier.value, inputs: inputs)
            )
            outputs.preferences.viewResponders = Attribute(filter)
        }
        return outputs
    }
}

// MARK: - LayoutGestureChild

private struct LayoutGestureChild<G>: Rule where G: Gesture, G.Value == Void {
    @Attribute var modifier: LayoutGestureModifier<G>
    let node: MultiViewResponder

    var value: G {
        modifier.transform(node)
    }
}

// MARK: - LayoutResponderFilter

private struct LayoutResponderFilter<G>: StatefulRule where G: Gesture, G.Value == Void {
    @Attribute var children: [ViewResponder]
    let responder: LayoutGestureResponder<G>

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        responder.updateChildren($children.changedValue())
        if !hasValue {
            value = [responder]
        }
    }
}
