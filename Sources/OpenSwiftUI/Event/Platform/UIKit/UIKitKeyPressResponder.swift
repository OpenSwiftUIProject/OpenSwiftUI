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
        fallbackResponderProvider: (any FallbackResponderProvider)? = nil,
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
        DefaultModifierKeySource.monitor.value = EventModifiers(event.modifierFlags)
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

// FIXME

extension UIPress: KeyEventProvider {
    func resolve(phase: EventPhase) -> KeyEvent? {
        guard let key else {
            return nil
        }
        return KeyEvent(
            phase: phase,
            timestamp: Time(seconds: timestamp),
            modifiers: EventModifiers(key.modifierFlags),
            keys: keyEquivalentString(key.charactersIgnoringModifiers),
            stringValue: keyEquivalentString(key.characters),
            keyID: AnyHashable(key.keyCode)
        )
    }
}

// MARK: - Key Input Conversion

private let keyInputToKeyEquivalentMap: [String: Character] = [
    UIKeyCommand.inputUpArrow: "\u{F700}",
    UIKeyCommand.inputDownArrow: "\u{F701}",
    UIKeyCommand.inputLeftArrow: "\u{F702}",
    UIKeyCommand.inputRightArrow: "\u{F703}",
    UIKeyCommand.inputEscape: "\u{001B}",
    UIKeyCommand.inputDelete: "\u{0008}",
    UIKeyCommand.inputPageUp: "\u{F72C}",
    UIKeyCommand.inputPageDown: "\u{F72D}",
    UIKeyCommand.inputHome: "\u{F729}",
    UIKeyCommand.inputEnd: "\u{F72B}",
    UIKeyCommand.f1: "\u{F704}",
    UIKeyCommand.f2: "\u{F705}",
    UIKeyCommand.f3: "\u{F706}",
    UIKeyCommand.f4: "\u{F707}",
    UIKeyCommand.f5: "\u{F708}",
    UIKeyCommand.f6: "\u{F709}",
    UIKeyCommand.f7: "\u{F70A}",
    UIKeyCommand.f8: "\u{F70B}",
    UIKeyCommand.f9: "\u{F70C}",
    UIKeyCommand.f10: "\u{F70D}",
    UIKeyCommand.f11: "\u{F70E}",
    UIKeyCommand.f12: "\u{F70F}",
]

private func keyEquivalentString(_ input: String) -> String {
    guard let keyEquivalent = keyInputToKeyEquivalentMap[input] else {
        return input
    }
    return String(keyEquivalent)
}


#endif
