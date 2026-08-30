//
//  EventBindingManager.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: D63F4C292364B83D9F441CFC1A31B3F3 (SwiftUICore)

import Foundation

// MARK: - EventBindingManager [TBA]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
final public class EventBindingManager {
    package weak var host: (any EventGraphHost)?

    package weak var delegate: (any EventBindingManagerDelegate)?

    private var forwardedEventDispatchers: [ObjectIdentifier: any ForwardedEventDispatcher] = [:]

    private var eventBindings: [EventID: EventBinding] = [:]

    package private(set) var isActive: Bool = false

    package static var current: EventBindingManager? {
        guard let delegate = ViewGraph.current.delegate,
              let host = delegate as? ViewRendererHost,
              let eventGraphHost = host.as(EventGraphHost.self)
        else {
            return nil
        }
        return eventGraphHost.eventBindingManager
    }

    private var eventTimer: Timer?

    #if os(macOS)
    private var hasPendingHoverUpdate: Bool = false
    #endif

    package init() {
        _openSwiftUIEmptyStub()
    }

    deinit {
        eventTimer?.invalidate()
    }

    // TBA
    private func sendDownstream(_ events: [EventID: any EventType]) -> Set<EventID> {
        guard let host else {
            return []
        }
        let rootResponder = host.responderNode
        var dispatchedIDs = dispatchNonGestureEvents(events)
        let gestureEvents = events.optimisticFilter { _, event in
            forwardedEventDispatchers[ObjectIdentifier(Swift.type(of: event))] == nil
        }
        guard !gestureEvents.isEmpty || isActive else {
            return dispatchedIDs
        }
        var downstreamEvents: [EventID: any EventType] = [:]
        var terminalEventIDs: [EventID] = []
        for (id, inputEvent) in gestureEvents {
            var event = inputEvent
            let binding: EventBinding?
            let createdBinding: Bool
            if let existingBinding = eventBindings[id] {
                binding = existingBinding
                createdBinding = false
            } else {
                let responder: ResponderNode?
                if event.isFocusEvent, let focusedResponder = host.focusedResponder {
                    responder = focusedResponder.bindEvent(event) ?? focusedResponder
                } else {
                    responder = rootResponder?.bindEvent(event)
                }
                binding = responder.map(EventBinding.init(responder:))
                createdBinding = binding != nil
            }
            if let binding {
                event.binding = binding
                eventBindings[id] = binding
                downstreamEvents[id] = event
                if createdBinding {
                    isActive = true
                    delegate?.didBind(to: binding, id: id)
                }
            }
            if event.phase.isTerminal {
                terminalEventIDs.append(id)
            }
        }
        var phase: GesturePhase<Void> = .failed
        var nextUpdateTime: Time = .infinity
        var gestureCategory: GestureCategory = []
        if isActive, let rootResponder {
            phase = host.sendEvents(
                downstreamEvents,
                rootNode: rootResponder,
                at: .systemUptime
            )
            nextUpdateTime = host.nextGestureUpdateTime
            gestureCategory = host.gestureCategory() ?? []
            if !phase.isFailed {
                dispatchedIDs.formUnion(downstreamEvents.keys)
            }
        }
        delegate?.didUpdate(phase: phase, in: self)
        delegate?.didUpdate(gestureCategory: gestureCategory, in: self)
        if isActive, nextUpdateTime < .infinity {
            scheduleNextEventUpdate(time: nextUpdateTime)
        }
        for id in terminalEventIDs {
            eventBindings.removeValue(forKey: id)
        }
        return dispatchedIDs
    }

    private func scheduleNextEventUpdate(time: Time) {
        eventTimer?.invalidate()
        eventTimer = nil
        let interval = time - .systemUptime
        guard interval > 0, interval.isFinite else {
            return
        }
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else {
                return
            }
            eventTimer = nil
            _ = send([:])
        }
        RunLoop.main.add(timer, forMode: .common)
        eventTimer = timer
    }

    // TBA
    package func addForwardedEventDispatcher(_ dispatcher: any ForwardedEventDispatcher) {
        forwardedEventDispatchers[ObjectIdentifier(type(of: dispatcher).eventType)] = dispatcher
    }

    // TBA
    package func rebindEvent(
        _ identifier: EventID,
        to: ResponderNode?
    ) -> (from: EventBinding?, to: EventBinding?)? {
        let oldBinding = eventBindings[identifier]
        guard oldBinding?.responder !== to else {
            return nil
        }
        let newBinding = to.map(EventBinding.init(responder:))
        eventBindings[identifier] = newBinding
        return (oldBinding, newBinding)
    }

    // TBA
    package func willRemoveResponder(_ from: ResponderNode) {
        let nextResponder = from.nextResponder
        for (identifier, binding) in eventBindings {
            var responder: ResponderNode? = binding.responder
            while responder !== from && responder !== nextResponder {
                responder = responder?.nextResponder
            }
            guard responder === from else {
                continue
            }
            eventBindings[identifier] = nextResponder.map(EventBinding.init(responder:))
        }
    }

    // TBA
    package func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        guard let host else {
            return
        }
        Update.locked {
            host.setInheritedPhase(phase)
            _ = send([:])
        }
    }

    @discardableResult
    package func send(_ events: [EventID: any EventType]) -> Set<EventID> {
        Update.locked { [weak self] in
            guard let self else {
                return []
            }
            return sendDownstream(events)
        }
    }

    // TBA
    package func send<E>(_ event: E, id: Int) where E: EventType {
        send([EventID(type: E.self, serial: id): event])
    }

    // TBA
    package var rootResponder: ResponderNode? { host?.responderNode }

    // TBA
    package var focusedResponder: ResponderNode? { host?.focusedResponder }

    // TBA
    package func reset(resetForwardedEventDispatchers: Bool = false) {
        Update.enqueueAction(reason: nil) { [weak self] in
            self?.host?.resetEvents()
        }
        if resetForwardedEventDispatchers {
            for (key, var dispatcher) in forwardedEventDispatchers {
                dispatcher.reset()
                forwardedEventDispatchers[key] = dispatcher
            }
        }
        eventBindings = [:]
        eventTimer?.invalidate()
        eventTimer = nil
        isActive = false
    }

    // TBA
    package func isActive<E>(for eventType: E.Type) -> Bool where E: EventType {
        for dispatcher in forwardedEventDispatchers.values {
            if type(of: dispatcher).eventType == eventType {
                return dispatcher.isActive
            }
        }
        return isActive
    }

    // TBA
    package func binds<E>(_ event: E) -> Bool where E: EventType {
        for dispatcher in forwardedEventDispatchers.values {
            if Swift.type(of: event) == type(of: dispatcher).eventType {
                return dispatcher.wantsEvent(event, manager: self)
            }
        }
        return false
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension EventBindingManager: Sendable {}

@_spi(ForOpenSwiftUIOnly)
extension EventBindingManager {
    #if os(macOS)
    // TBA

    package func enqueueHoverUpdateIfNeeded() {
        guard !hasPendingHoverUpdate else {
            return
        }
        hasPendingHoverUpdate = true
        Update.enqueueAction(reason: nil) { [weak self] in
            guard let self else {
                return
            }
            hasPendingHoverUpdate = false
            delegate?.requestHoverUpdate(in: self)
        }
    }
    #endif

    // TBA
    private func dispatchNonGestureEvents(_ events: [EventID: any EventType]) -> Set<EventID> {
        var dispatchedIDs: Set<EventID> = []
        for key in forwardedEventDispatchers.keys {
            guard var dispatcher = forwardedEventDispatchers[key] else {
                continue
            }
            let matchingEvents = events.optimisticFilter { _, event in
                Swift.type(of: event) == type(of: dispatcher).eventType
            }
            guard !matchingEvents.isEmpty else {
                continue
            }
            dispatchedIDs.formUnion(dispatcher.receiveEvents(matchingEvents, manager: self))
            forwardedEventDispatchers[key] = dispatcher
            if dispatchedIDs.count == events.count {
                break
            }
        }
        return dispatchedIDs
    }
}

// MARK: - ForwardedEventDispatcher

package protocol ForwardedEventDispatcher {
    static var eventType: any EventType.Type { get }

    var isActive: Bool { get }

    func wantsEvent(
        _ event: any EventType,
        manager: EventBindingManager
    ) -> Bool

    mutating func receiveEvents(
        _ events: [EventID: any EventType],
        manager: EventBindingManager
    ) -> Set<EventID>

    mutating func reset()
}

extension ForwardedEventDispatcher {
    package var isActive: Bool {
        false
    }

    package func wantsEvent(
        _ event: any EventType,
        manager: EventBindingManager
    ) -> Bool {
        true
    }

    package mutating func reset() {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - EventBindingManagerDelegate

package protocol EventBindingManagerDelegate: AnyObject {
    func didBind(
        to newBinding: EventBinding,
        id: EventID
    )

    func didUpdate(
        phase: GesturePhase<Void>,
        in eventBindingManager: EventBindingManager
    )

    func didUpdate(
        gestureCategory: GestureCategory,
        in eventBindingManager: EventBindingManager
    )

    #if os(macOS)
    func requestHoverUpdate(
        in eventBindingManager: EventBindingManager
    )
    #endif
}

extension EventBindingManagerDelegate {
    package func didBind(
        to newBinding: EventBinding,
        id: EventID
    ) {
        _openSwiftUIEmptyStub()
    }

    package func didUpdate(
        gestureCategory: GestureCategory,
        in eventBindingManager: EventBindingManager
    ) {
        _openSwiftUIEmptyStub()
    }

    #if os(macOS)
    package func requestHoverUpdate(
        in eventBindingManager: EventBindingManager
    ) {
        _openSwiftUIEmptyStub()
    }
    #endif
}
