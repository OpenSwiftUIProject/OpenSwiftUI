//
//  EventBindingManager.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: D63F4C292364B83D9F441CFC1A31B3F3 (SwiftUICore)

import Foundation

// MARK: - EventBindingManager [6.5.4] [WIP]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
final public class EventBindingManager {
    package weak var host: (any EventGraphHost)?

    package weak var delegate: (any EventBindingManagerDelegate)?

    private var forwardedEventDispatchers: [ObjectIdentifier: any ForwardedEventDispatcher] = [:]

    private var eventBindings: [EventID: EventBinding] = [:]

    private(set) package var isActive: Bool = false

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

    package init() {}

    deinit {
        eventTimer?.invalidate()
    }

    package func addForwardedEventDispatcher(_ dispatcher: any ForwardedEventDispatcher) {
        forwardedEventDispatchers[ObjectIdentifier(type(of: dispatcher).eventType)] = dispatcher
    }

    package func rebindEvent(
        _ identifier: EventID,
        to: ResponderNode?
    ) -> (from: EventBinding?, to: EventBinding?)? {
        openSwiftUIUnimplementedFailure()
    }

    package func willRemoveResponder(_ from: ResponderNode) {
        openSwiftUIUnimplementedFailure()
    }

    package func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        openSwiftUIUnimplementedFailure()
    }

    private func sendDownstream(_ events: [EventID: any EventType]) -> Set<EventID> {
        openSwiftUIUnimplementedFailure()
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

    package func send<E>(_ event: E, id: Int) where E: EventType {
        openSwiftUIUnimplementedFailure()
    }

    package var rootResponder: ResponderNode? { openSwiftUIUnimplementedFailure() }

    package var focusedResponder: ResponderNode? { openSwiftUIUnimplementedFailure() }

    package func reset(resetForwardedEventDispatchers: Bool = false) {
        openSwiftUIUnimplementedFailure()
    }

    package func isActive<E>(for eventType: E.Type) -> Bool where E: EventType {
        openSwiftUIUnimplementedFailure()
    }

    package func binds<E>(_ event: E) -> Bool where E: EventType {
        openSwiftUIUnimplementedFailure()
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension EventBindingManager: Sendable {}

// MARK: - ForwardedEventDispatcher [6.5.4]

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
    package var isActive: Bool { false }

    package func wantsEvent(
        _ event: any EventType,
        manager: EventBindingManager
    ) -> Bool {
        true
    }

    package mutating func reset() {}
}

// MARK: - EventBindingManagerDelegate [6.5.4]

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
}

extension EventBindingManagerDelegate {
    package func didBind(
        to newBinding: EventBinding,
        id: EventID
    ) {}

    package func didUpdate(
        gestureCategory: GestureCategory,
        in eventBindingManager: EventBindingManager
    ) {}
}
