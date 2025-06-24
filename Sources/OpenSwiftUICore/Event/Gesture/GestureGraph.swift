//
//  GestureGraph.swift
//  OpenSwiftUICore
//
//  Status: WIP

package protocol GestureGraphDelegate: AnyObject {
    func enqueueAction(_ action: @escaping () -> Void)
}

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
        get { preconditionFailure("TODO") }
    }
}
