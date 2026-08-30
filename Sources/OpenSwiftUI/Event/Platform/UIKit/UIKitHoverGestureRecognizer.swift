//
//  UIKitHoverGestureRecognizer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIKitHoverGestureRecognizer

final class UIKitHoverGestureRecognizer: UIHoverGestureRecognizer, EventBindingSource {
    weak var eventBridge: EventBindingBridge?

    init() {
        super.init(target: nil, action: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func attach(to eventBridge: EventBindingBridge) {
        self.eventBridge = eventBridge
    }

    func `as`<T>(_ type: T.Type) -> T? {
        guard type == UIGestureRecognizer.self else {
            return nil
        }
        return unsafeBitCast(self, to: type)
    }

    override func reset() {
        eventBridge?.reset(
            eventSource: self,
            resetForwardedEventDispatchers: false
        )
    }

    override func _hoverEntered(
        _ hoverEvents: Set<UITouch>,
        with event: UIEvent
    ) {
        let events = convert(
            hoverEvents: hoverEvents,
            with: event,
            phase: .active
        )
        eventBridge?.send(events, source: self)
    }

    override func _hoverMoved(
        _ hoverEvents: Set<UITouch>,
        with event: UIEvent
    ) {
        let events = convert(
            hoverEvents: hoverEvents,
            with: event,
            phase: .active
        )
        eventBridge?.send(events, source: self)
    }

    override func _hoverExited(
        _ hoverEvents: Set<UITouch>,
        with event: UIEvent
    ) {
        let events = convert(
            hoverEvents: hoverEvents,
            with: event,
            phase: .ended
        )
        eventBridge?.send(events, source: self)
    }

    override func _hoverCancelled(
        _ hoverEvents: Set<UITouch>,
        with event: UIEvent
    ) {
        let events = convert(
            hoverEvents: hoverEvents,
            with: event,
            phase: .failed
        )
        eventBridge?.send(events, source: self)
    }

    private func convert(
        hoverEvents: Set<UITouch>,
        with event: UIEvent,
        phase: EventPhase
    ) -> [EventID: HoverEvent] {
        var events: [EventID: HoverEvent] = [:]
        for hoverEvent in hoverEvents {
            let view = self.view
            let id = EventID(hoverEvent, subtype: HoverEvent.self)
            let event = withExtendedLifetime(view) {
                HoverEvent(
                    timestamp: Time(seconds: hoverEvent.timestamp),
                    phase: phase,
                    globalLocation: hoverEvent.location(in: nil)
                )
            }
            events[id] = event
        }
        return events
    }
}
#endif
