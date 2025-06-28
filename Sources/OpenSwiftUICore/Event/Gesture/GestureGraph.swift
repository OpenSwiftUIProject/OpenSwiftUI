//
//  GestureGraph.swift
//  OpenSwiftUICore
//
//  Status: WIP

// MARK: - GestureGraphDelegate [6.5.4]

package protocol GestureGraphDelegate: AnyObject {
    func enqueueAction(_ action: @escaping () -> Void)
}

// MARK: - GestureGraph [6.5.4] [WIP]

final package class GestureGraph: GraphHost, EventGraphHost, CustomStringConvertible {
    package init(eventBindingManager: EventBindingManager) {
        preconditionFailure("TODO")
    }

    final package let eventBindingManager: EventBindingManager

    final package var description: String {
        get { preconditionFailure("TODO") }
    }

    override final package func instantiateOutputs() {
        preconditionFailure("TODO")
    }

    override final package func uninstantiateOutputs() {
        preconditionFailure("TODO")
    }

    override final package func timeDidChange() {
        preconditionFailure("TODO")
    }

    final package var responderNode: ResponderNode? {
        get { preconditionFailure("TODO") }
    }

    final package var focusedResponder: ResponderNode? {
        get { preconditionFailure("TODO") }
    }

    final package var nextGestureUpdateTime: Time {
        get { preconditionFailure("TODO") }
    }

    final package func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        preconditionFailure("TODO")
    }

    final package func sendEvents(
        _ events: [EventID: any EventType],
        rootNode: ResponderNode,
        at time: Time
    ) -> GesturePhase<Void> {
        preconditionFailure("TODO")
    }

    final package func resetEvents() {
        preconditionFailure("TODO")
    }

    final package func enqueueAction(_ action: @escaping () -> Void) {
        preconditionFailure("TODO")
    }

    final package func gestureCategory() -> GestureCategory? {
        preconditionFailure("TODO")
    }

//    @objc deinit {
//        preconditionFailure("TODO")
//    }
}

extension GestureGraph {
    package static var current: GestureGraph {
        GraphHost.currentHost as! GestureGraph
    }
}
