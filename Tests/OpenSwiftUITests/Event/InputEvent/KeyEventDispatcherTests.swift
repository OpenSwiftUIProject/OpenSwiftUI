//
//  KeyEventDispatcherTests.swift
//  OpenSwiftUITests

#if os(macOS)
import AppKit
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.tags(.aigc))
struct KeyEventDispatcherTests {
    @Test
    func wantsEventChecksSubjectsWithoutPhasesOrActions() {
        let host = Host()
        let responder = Responder()
        host.focusedResponder = responder
        let dispatcher = KeyEventDispatcher()
        var calls = 0
        responder.keyPressHandlers = [
            .init(subject: .keys(["a"]), phases: .up) { _ in
                calls += 1
                return .handled
            },
        ]
        #expect(dispatcher.wantsEvent(event(.began, keys: "a"), manager: host.eventBindingManager))
        #expect(!dispatcher.wantsEvent(event(.began, keys: "b"), manager: host.eventBindingManager))
        responder.keyPressHandlers[0].subject = .characters(.decimalDigits)
        #expect(dispatcher.wantsEvent(event(.began, keys: "a1"), manager: host.eventBindingManager))
        #expect(!dispatcher.wantsEvent(event(.began, keys: "ab"), manager: host.eventBindingManager))
        responder.keyPressHandlers[0].subject = .all
        #expect(dispatcher.wantsEvent(event(.began, keys: "b"), manager: host.eventBindingManager))
        #expect(!dispatcher.wantsEvent(event(.began, keys: ""), manager: host.eventBindingManager))
        #expect(!dispatcher.wantsEvent(OtherEvent(), manager: host.eventBindingManager))
        #expect(calls == 0)
    }

    @Test
    func bindingKeepsHandlerPrefixAcrossFocusChanges() {
        let host = Host()
        let responder = Responder()
        host.focusedResponder = responder
        let id = EventID(type: KeyEvent.self, serial: 1)
        var calls: [String] = []
        responder.keyPressHandlers = [
            .init(subject: .all, phases: .up) { _ in
                calls.append("up")
                return .handled
            },
            .init(subject: .keys(["a"]), phases: [.down, .repeat]) { _ in
                calls.append("consumer")
                return .handled
            },
            .init(subject: .all, phases: .all) { _ in
                calls.append("after consumer")
                return .handled
            },
        ]
        var dispatcher = KeyEventDispatcher()
        #expect(dispatcher.receiveEvents([id: event(.began)], manager: host.eventBindingManager) == [id])
        #expect(dispatcher.bindings[id]?.count == 2)
        #expect(dispatcher.isActive)

        let replacement = Responder()
        replacement.keyPressHandlers = [
            .init(subject: .all, phases: .all) { _ in
                calls.append("new focus")
                return .handled
            },
        ]
        responder.keyPressHandlers = []
        host.focusedResponder = replacement
        #expect(dispatcher.receiveEvents([id: event(.active)], manager: host.eventBindingManager) == [id])
        #expect(dispatcher.receiveEvents([id: event(.ended)], manager: host.eventBindingManager) == [id])
        #expect(calls == ["consumer", "consumer", "up"])
        #expect(!dispatcher.isActive)
    }

    @Test
    func ignoredEventsDoNotKeepHandlers() {
        let host = Host()
        let responder = Responder()
        host.focusedResponder = responder
        let id = EventID(type: KeyEvent.self, serial: 1)
        var calls: [String] = []
        responder.keyPressHandlers = [
            .init(subject: .all, phases: .all) { _ in
                calls.append("ignored")
                return .ignored
            },
        ]
        var dispatcher = KeyEventDispatcher()
        #expect(dispatcher.receiveEvents([id: event(.began)], manager: host.eventBindingManager).isEmpty)
        #expect(!dispatcher.isActive)
        responder.keyPressHandlers = [
            .init(subject: .all, phases: .repeat) { _ in
                calls.append("replacement")
                return .handled
            },
        ]
        #expect(dispatcher.receiveEvents([id: event(.active)], manager: host.eventBindingManager) == [id])
        #expect(calls == ["ignored", "replacement"])
    }

    @Test
    func missingFocusKeepsBindingsUntilReset() {
        let host = Host()
        let responder = Responder()
        host.focusedResponder = responder
        let id = EventID(type: KeyEvent.self, serial: 1)
        var calls = 0
        responder.keyPressHandlers = [
            .init(subject: .all, phases: .all) { _ in
                calls += 1
                return .handled
            },
        ]
        var dispatcher = KeyEventDispatcher()
        #expect(dispatcher.receiveEvents([id: event(.began)], manager: host.eventBindingManager) == [id])
        host.focusedResponder = nil
        #expect(!dispatcher.wantsEvent(event(.active), manager: host.eventBindingManager))
        #expect(dispatcher.receiveEvents([id: event(.ended)], manager: host.eventBindingManager).isEmpty)
        #expect(calls == 1)
        #expect(dispatcher.isActive)
        dispatcher.reset()
        #expect(!dispatcher.isActive)
    }

    @Test(arguments: [EventPhase.ended, .failed])
    func terminalEventsRemoveBindingsEvenWhenIgnored(phase: EventPhase) {
        let host = Host()
        let responder = Responder()
        host.focusedResponder = responder
        let id = EventID(type: KeyEvent.self, serial: 1)
        responder.keyPressHandlers = [
            .init(subject: .all, phases: .down) { _ in .handled },
        ]
        var dispatcher = KeyEventDispatcher()
        #expect(dispatcher.receiveEvents([id: event(.began)], manager: host.eventBindingManager) == [id])
        #expect(dispatcher.receiveEvents([id: event(phase)], manager: host.eventBindingManager).isEmpty)
        #expect(!dispatcher.isActive)
    }

    @Test
    func phaseAndSubjectFiltersPrecedeActions() {
        let host = Host()
        let responder = Responder()
        host.focusedResponder = responder
        let id = EventID(type: KeyEvent.self, serial: 1)
        var calls: [String] = []
        responder.keyPressHandlers = [
            .init(subject: .keys(["b"]), phases: .all) { _ in
                calls.append("wrong key")
                return .handled
            },
            .init(subject: .all, phases: .up) { _ in
                calls.append("wrong phase")
                return .handled
            },
            .init(subject: .characters(.decimalDigits), phases: .down) { _ in
                calls.append("character")
                return .handled
            },
        ]
        var dispatcher = KeyEventDispatcher()
        #expect(dispatcher.receiveEvents([id: event(.began, keys: "a1")], manager: host.eventBindingManager) == [id])
        #expect(calls == ["character"])
        #expect(dispatcher.bindings[id]?.count == 3)
    }

    private func event(_ phase: EventPhase, keys: String = "a") -> KeyEvent {
        KeyEvent(
            phase: phase,
            timestamp: .zero,
            modifiers: [],
            keys: keys,
            stringValue: keys.uppercased(),
            keyID: 1
        )
    }

    private final class Responder: ResponderNode, FocusResponder {
        override var nextResponder: ResponderNode? { nil }
        var platformItem: NSView? { nil }
        var viewItem: FocusItem.ViewItem? { nil }
        var frame: CGRect? { nil }
        var isEnabled: Bool { true }
        var effectiveLayoutDirection: LayoutDirection? { nil }
        var firstKeyViewInSubtree: NSView?
        var lastKeyViewInSubtree: NSView?
        var focusItem: FocusItem? { nil }
        var focusAccessibilityNode: AccessibilityNode?
        var keyPressHandlers: [KeyPress.Handler] = []
        var evaluateDefaultFocus: EvaluateDefaultFocusAction? { nil }
        var focusRingView: (NSView & FocusRingDelegate)? { nil }
        var delegatesFocusEffect: Bool { false }
        func setFocusRingView(_ view: (NSView & FocusRingDelegate)?) {}
    }

    private final class Host: EventGraphHost {
        let eventBindingManager = EventBindingManager()
        var responderNode: ResponderNode? { focusedResponder }
        var focusedResponder: ResponderNode?
        var nextGestureUpdateTime: Time { .infinity }

        init() {
            eventBindingManager.host = self
        }

        func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {}
        func resetEvents() {}
        func gestureCategory() -> GestureCategory? { nil }
        func sendEvents(
            _ events: [EventID: any EventType],
            rootNode: ResponderNode,
            at time: Time
        ) -> GesturePhase<Void> { .failed }
    }

    private struct OtherEvent: EventType {
        var phase: EventPhase { .began }
        var timestamp: Time { .zero }
        var binding: EventBinding?
    }
}
#endif
