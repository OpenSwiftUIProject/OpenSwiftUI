//
//  EventBindingBridge.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: E11AC34B5BFF53E1001A61D61F5B9E0F (SwiftUICore)

// MARK: - EventBindingBridge [6.5.4] [WIP]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class EventBindingBridge {
    package private(set) weak var eventBindingManager: EventBindingManager?

    package var responderWasBoundHandler: ((ResponderNode) -> Void)?

    private struct TrackedEventState {
        var sourceID: ObjectIdentifier
        var reset: Bool
    }

    private var trackedEvents: [EventID: TrackedEventState] = [:]

    public init(eventBindingManager: EventBindingManager) {
        self.eventBindingManager = eventBindingManager
    }

    public init() {}

    open var eventSources: [any EventBindingSource] { [] }

    @discardableResult
    open func send(
        _ events: [EventID: any EventType],
        source: any EventBindingSource
    ) -> Set<EventID> {
        openSwiftUIUnimplementedFailure()
    }

    open func reset(
        eventSource: any EventBindingSource,
        resetForwardedEventDispatchers: Bool = false
    ) {
        openSwiftUIUnimplementedFailure()
    }

    private func resetEvent() {
        openSwiftUIUnimplementedFailure()
    }

    open func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        eventBindingManager?.setInheritedPhase(phase)
    }

    open func source(for sourceType: EventSourceType) -> (any EventBindingSource)? {
        nil
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension EventBindingBridge: Sendable {}

// MARK: - EventBindingBridge + EventBindingManagerDelegate [6.5.4]

@_spi(ForOpenSwiftUIOnly)
extension EventBindingBridge: EventBindingManagerDelegate {
    package func didBind(
        to newBinding: EventBinding,
        id: EventID
    ) {
        if let responderWasBoundHandler {
            // TODO: Update.enqueueAction(reason:_:)
            Update.enqueueAction {
                responderWasBoundHandler(newBinding.responder)
            }
        }
        for eventSource in eventSources {
            eventSource.didBind(to: newBinding, id: id, in: self)
        }
    }

    package func didUpdate(
        phase: GesturePhase<Void>,
        in eventBindingManager: EventBindingManager
    ) {
        for eventSource in eventSources {
            eventSource.didUpdate(phase: phase, in: self)
        }
    }

    package func didUpdate(
        gestureCategory: GestureCategory,
        in eventBindingManager: EventBindingManager
    ) {
        for eventSource in eventSources {
            eventSource.didUpdate(gestureCategory: gestureCategory, in: self)
        }
    }
}
