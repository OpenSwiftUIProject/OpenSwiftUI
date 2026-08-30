//
//  UIKitKeyPressResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIKitKeyPressResponder

final class UIKitKeyPressResponder: UIResponder {
    weak var eventBindingManager: EventBindingManager? = nil

    weak var fallbackResponderProvider: (any FallbackResponderProvider)? = nil

    private var tracker: KeyEvent.Tracker = .init()

    init(
        eventBindingManager: EventBindingManager? = nil,
        fallbackResponderProvider: (any FallbackResponderProvider)? = nil
    ) {
        self.eventBindingManager = eventBindingManager
        self.fallbackResponderProvider = fallbackResponderProvider
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    override var next: UIResponder? {
        fallbackResponderProvider?.defaultNextResponder
    }

    override func pressesBegan(
        _ presses: Set<UIPress>,
        with event: UIPressesEvent?
    ) {
        updateModifiers(from: event)
        if !sendPresses(presses, phase: .began) {
            super.pressesBegan(presses, with: event)
        }
    }

    override func pressesCancelled(
        _ presses: Set<UIPress>,
        with event: UIPressesEvent?
    ) {
        updateModifiers(from: event)
        if !sendPresses(presses, phase: .failed) {
            super.pressesCancelled(presses, with: event)
        }
    }

    override func pressesChanged(
        _ presses: Set<UIPress>,
        with event: UIPressesEvent?
    ) {
        updateModifiers(from: event)
        if !sendPresses(presses, phase: .active) {
            super.pressesChanged(presses, with: event)
        }
    }

    override func pressesEnded(
        _ presses: Set<UIPress>,
        with event: UIPressesEvent?
    ) {
        updateModifiers(from: event)
        if !sendPresses(presses, phase: .ended) {
            super.pressesEnded(presses, with: event)
        }
    }

    private func updateModifiers(from event: UIPressesEvent?) {
        guard let event else {
            return
        }
        DefaultModifierKeySource.monitor.observe(EventModifiers(event.modifierFlags))
    }

    private func sendPresses(
        _ presses: Set<UIPress>,
        phase: EventPhase
    ) -> Bool {
        guard let eventBindingManager else {
            return false
        }
        let events = presses.reduce(into: [EventID: any EventType]()) { events, press in
            guard let event = press.resolve(phase: phase) else {
                return
            }
            let identifier = EventID(
                type: KeyEvent.self,
                serial: tracker.serial(for: event)
            )
            events[identifier] = event
        }
        guard !events.isEmpty else {
            return false
        }
        return eventBindingManager.send(events) == Set(events.keys)
    }
}

// MARK: - FallbackResponderProvider

protocol FallbackResponderProvider: AnyObject {
    var defaultNextResponder: UIResponder? { get }
}
#endif
