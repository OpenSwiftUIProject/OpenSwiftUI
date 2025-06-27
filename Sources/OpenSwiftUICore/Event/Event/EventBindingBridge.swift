//
//  EventBindingBridge.swift
//  OpenSwiftUICore
//
//  Status: WIP

// MARK: - EventBindingBridge [6.5.4] [WIP]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class EventBindingBridge {
    package weak var eventBindingManager: EventBindingManager? { preconditionFailure("TODO") }

    package var responderWasBoundHandler: ((ResponderNode) -> Void)?

    public init(eventBindingManager: EventBindingManager) {
        preconditionFailure("TODO")
    }

    public init() {
        preconditionFailure("TODO")
    }

    open var eventSources: [any EventBindingSource] { preconditionFailure("TODO") }

    @discardableResult
    open func send(
        _ events: [EventID: any EventType],
        source: any EventBindingSource
    ) -> Set<EventID> {
        preconditionFailure("TODO")
    }

    open func reset(
        eventSource: any EventBindingSource,
        resetForwardedEventDispatchers: Bool = false
    ) {
        preconditionFailure("TODO")
    }

    open func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        preconditionFailure("TODO")
    }

    open func source(for sourceType: EventSourceType) -> (any EventBindingSource)? {
        preconditionFailure("TODO")
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension EventBindingBridge: Sendable {}

@_spi(ForOpenSwiftUIOnly)
extension EventBindingBridge: EventBindingManagerDelegate {
    package func didBind(
        to newBinding: EventBinding,
        id: EventID
    ) {
        preconditionFailure("TODO")
    }

    package func didUpdate(
        phase: GesturePhase<Void>,
        in eventBindingManager: EventBindingManager
    ) {
        preconditionFailure("TODO")
    }

    package func didUpdate(
        gestureCategory: GestureCategory,
        in eventBindingManager: EventBindingManager
    ) {
        preconditionFailure("TODO")
    }
}
