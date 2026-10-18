//
//  KeyEventDispatcher.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: DEEBAE35447F92C37FF6C5895EB67C42 (SwiftUI)

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - KeyEventDispatcher

struct KeyEventDispatcher: ForwardedEventDispatcher {
    var bindings: [EventID: [KeyPress.Handler]] = [:]

    static var eventType: any EventType.Type { KeyEvent.self }

    var isActive: Bool { !bindings.isEmpty }

    func wantsEvent(_ event: any EventType, manager: EventBindingManager) -> Bool {
        guard let responder = manager.focusedResponder as? any FocusResponder,
              let press = KeyPress(for: event) else {
            return false
        }
        return responder.keyPressHandlers.contains { $0.matches(press) }
    }

    mutating func receiveEvents(
        _ events: [EventID: any EventType],
        manager: EventBindingManager
    ) -> Set<EventID> {
        guard let responder = manager.focusedResponder as? any FocusResponder else {
            return []
        }
        var handled: Set<EventID> = []
        var terminal: [EventID] = []
        for (id, event) in events {
            guard let press = KeyPress(for: event) else { continue }
            if bind(id, press, responder) {
                handled.insert(id)
            }
            if event.phase.isTerminal {
                terminal.append(id)
            }
        }
        for id in terminal {
            bindings.removeValue(forKey: id)
        }
        return handled
    }

    mutating func reset() {
        bindings = [:]
    }

    private mutating func bind(
        _ id: EventID,
        _ press: KeyPress,
        _ responder: any FocusResponder
    ) -> Bool {
        if let handlers = bindings[id] {
            return handlers.contains {
                $0.matches(press) && $0.phases.contains(press.phase) && $0.action(press) == .handled
            }
        }
        var handlers: [KeyPress.Handler] = []
        for handler in responder.keyPressHandlers {
            handlers.append(handler)
            if handler.matches(press),
               handler.phases.contains(press.phase),
               handler.action(press) == .handled {
                // Keep the handlers through the consumer for later phases of this key.
                bindings[id] = handlers
                return true
            }
        }
        return false
    }
}

extension KeyPress.Handler {
    @inline(__always)
    fileprivate func matches(_ press: KeyPress) -> Bool {
        switch subject {
        case let .keys(keys):
            keys.contains(press.key)
        case let .characters(characters):
            !characters.intersection(CharacterSet(charactersIn: press.characters)).isEmpty
        case .all:
            true
        }
    }
}
