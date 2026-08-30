//
//  EventBindingBridge.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E11AC34B5BFF53E1001A61D61F5B9E0F (SwiftUICore)

// MARK: - EventBindingBridge

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

    // MARK: - Event dispatch tracking

    @discardableResult
    open func send(
        _ events: [EventID: any EventType],
        source: any EventBindingSource
    ) -> Set<EventID> {
        guard !events.isEmpty else {
            return []
        }
        var downstreamEvents: [EventID: any EventType] = [:]
        let sourceID = ObjectIdentifier(source)
        for (id, event) in events {
            guard !(event is any NonGestureEventType) else {
                downstreamEvents[id] = event
                continue
            }
            if let trackedEvent = trackedEvents[id] {
                if event.phase != .active {
                    trackedEvents.removeValue(forKey: id)
                }
                guard !trackedEvent.reset else {
                    continue
                }
                downstreamEvents[id] = event
            } else {
                if event.phase == .active {
                    trackedEvents[id] = TrackedEventState(
                        sourceID: sourceID,
                        reset: false
                    )
                }
                downstreamEvents[id] = event
            }
        }
        guard !downstreamEvents.isEmpty else {
            return []
        }
        return eventBindingManager?.send(downstreamEvents) ?? []
    }

    // MARK: - Event source reset

    open func reset(
        eventSource: any EventBindingSource,
        resetForwardedEventDispatchers: Bool = false
    ) {
        let sourceID = ObjectIdentifier(eventSource)
        var hasActiveEvent = false
        for id in Array(trackedEvents.keys) {
            guard let trackedEvent = trackedEvents[id] else {
                continue
            }
            if trackedEvent.sourceID == sourceID {
                trackedEvents.removeValue(forKey: id)
            } else if !trackedEvent.reset {
                hasActiveEvent = true
            }
        }
        guard !hasActiveEvent else {
            return
        }
        eventBindingManager?.reset(
            resetForwardedEventDispatchers: resetForwardedEventDispatchers
        )
    }

    private func resetEvents() {
        for id in Array(trackedEvents.keys) {
            trackedEvents[id]?.reset = true
        }
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

// MARK: - EventBindingBridge + EventBindingManagerDelegate

@_spi(ForOpenSwiftUIOnly)
extension EventBindingBridge: EventBindingManagerDelegate {
    package func didBind(
        to newBinding: EventBinding,
        id: EventID
    ) {
        if let responderWasBoundHandler {
            Update.enqueueAction(reason: nil) {
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
        if phase.isTerminal {
            resetEvents()
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

    #if os(macOS)
    package func requestHoverUpdate(
        in eventBindingManager: EventBindingManager
    ) {
        for eventSource in eventSources {
            eventSource.didRequestHoverUpdate(in: self)
        }
    }
    #endif
}
