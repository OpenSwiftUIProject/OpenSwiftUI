//
//  EventGraphHost.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - EventGraphHost [6.5.4]

package protocol EventGraphHost: AnyObject {
    var eventBindingManager: EventBindingManager { get }

    var responderNode: ResponderNode? { get }

    var focusedResponder: ResponderNode? { get }

    var nextGestureUpdateTime: Time { get }

    func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase)

    func sendEvents(
        _ events: [EventID: any EventType],
        rootNode: ResponderNode,
        at time: Time
    ) -> GesturePhase<Void>

    func resetEvents()

    func gestureCategory() -> GestureCategory?
}
