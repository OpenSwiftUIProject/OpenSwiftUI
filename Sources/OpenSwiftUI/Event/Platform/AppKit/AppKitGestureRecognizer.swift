//
//  AppKitGestureRecognizer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 25FE44535476195900B7BAAA6C5B48FF (SwiftUI)

#if os(macOS)
import AppKit
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - AppKitGestureRecognizer

class AppKitGestureRecognizer: NSGestureRecognizer {
    private weak var eventBridge: EventBindingBridge?
    private var gestureCategory: GestureCategory = []
    private var lastInheritedPhase: _GestureInputs.InheritedPhase?
    private var lastState: State?
    private var mouseSeed: Int = 0
    private var magnifySeed: Int = 0
    private var accumulatedMagnification: CGFloat = 1
    private var rotateSeed: Int = 0
    private var accumulatedRotation: Angle = .zero

    init(eventBridge: EventBindingBridge) {
        self.eventBridge = eventBridge
        super.init(target: nil, action: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private func sendInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        guard lastInheritedPhase != phase else { return }
        eventBridge?.setInheritedPhase(phase)
        lastInheritedPhase = phase
    }

    private func sendEvent<E: EventType>(_ event: E, serial: Int) -> Bool {
        guard let eventBridge else { return false }
        let id = EventID(type: E.self, serial: serial)
        return eventBridge.send([id: event], source: self) == [id]
    }

    override func _updateForActiveEvents() {
        let currentState = state
        let phase: _GestureInputs.InheritedPhase
        if let lastState, currentState != lastState,
           lastState == .possible || lastState == .ended,
           state == .failed || state == .cancelled {
            phase = .active
        } else {
            phase = _hasUnmetFailureRequirements() ? [] : .failed
        }
        sendInheritedPhase(phase)
    }

    override func reset() {
        eventBridge?.reset(eventSource: self, resetForwardedEventDispatchers: false)
        lastState = nil
        lastInheritedPhase = nil
    }

    private func sendMouseEvent(_ event: NSEvent, phase: EventPhase, button: MouseEvent.Button) -> Bool {
        if phase == .began, event.clickCount == 1 {
            mouseSeed &+= 1
        }
        return sendEvent(MouseEvent(
            timestamp: Time(seconds: event.timestamp),
            button: button,
            phase: phase,
            location: .zero,
            globalLocation: globalLocation(of: event),
            modifiers: EventModifiers(event.modifierFlags)
        ), serial: mouseSeed)
    }

    private func globalLocation(of event: NSEvent) -> CGPoint {
        var location = event.locationInWindow
        if _SemanticFeature_v3.isEnabled {
            location.y = (view?.window?.frame.height ?? 0) - location.y
        }
        return location
    }

    override func mouseDown(with event: NSEvent) {
        if sendMouseEvent(event, phase: .began, button: .primary), let view {
            event.window?._latchView(view, for: event)
        }
    }

    override func mouseDragged(with event: NSEvent) {
        _ = sendMouseEvent(event, phase: .active, button: .primary)
    }

    override func mouseUp(with event: NSEvent) {
        _ = sendMouseEvent(event, phase: .ended, button: .primary)
    }

    override func rightMouseDown(with event: NSEvent) {
        _ = sendMouseEvent(event, phase: .began, button: .secondary)
    }

    override func rightMouseDragged(with event: NSEvent) {
        _ = sendMouseEvent(event, phase: .active, button: .secondary)
    }

    override func rightMouseUp(with event: NSEvent) {
        _ = sendMouseEvent(event, phase: .ended, button: .secondary)
    }

    override func otherMouseDown(with event: NSEvent) {
        _ = sendMouseEvent(event, phase: .began, button: .other(event.buttonNumber))
    }

    override func otherMouseDragged(with event: NSEvent) {
        _ = sendMouseEvent(event, phase: .active, button: .other(event.buttonNumber))
    }

    override func otherMouseUp(with event: NSEvent) {
        _ = sendMouseEvent(event, phase: .ended, button: .other(event.buttonNumber))
    }

    private func sendMagnifyEvent(_ event: NSEvent) -> Bool {
        if event.phase == .began {
            magnifySeed &+= 1
            accumulatedMagnification = 1
        }
        defer { accumulatedMagnification += event.magnification }
        guard let phase = EventPhase(event.phase) else { return false }
        return sendEvent(MagnifyEvent(
            timestamp: Time(seconds: event.timestamp),
            phase: phase,
            binding: nil,
            globalLocation: globalLocation(of: event),
            scaleDelta: event.magnification,
            initialScale: accumulatedMagnification
        ), serial: magnifySeed)
    }

    override func magnify(with event: NSEvent) {
        _ = sendMagnifyEvent(event)
    }

    private func sendRotateEvent(_ event: NSEvent) -> Bool {
        if event.phase == .began {
            rotateSeed &+= 1
            accumulatedRotation = .zero
        }
        let delta = Angle.degrees(-Double(event.rotation))
        defer { accumulatedRotation.animatableData += delta.animatableData }
        guard let phase = EventPhase(event.phase) else { return false }
        return sendEvent(RotateEvent(
            timestamp: Time(seconds: event.timestamp),
            phase: phase,
            binding: nil,
            globalLocation: globalLocation(of: event),
            angleDelta: delta,
            initialAngle: accumulatedRotation
        ), serial: rotateSeed)
    }

    override func rotate(with event: NSEvent) {
        _ = sendRotateEvent(event)
    }
}

// MARK: - AppKitGestureRecognizer + EventBindingSource

extension AppKitGestureRecognizer: EventBindingSource {
    func attach(to eventBridge: EventBindingBridge) {
        self.eventBridge = eventBridge
    }

    func didUpdate(phase: GesturePhase<Void>, in eventBridge: EventBindingBridge) {
        let newState: State
        switch (phase, state) {
        case (.active, .possible): newState = .began
        case (.active, .began), (.active, .changed): newState = .changed
        case (.ended, .possible), (.ended, .began), (.ended, .changed): newState = .ended
        case (.failed, .possible): newState = .failed
        case (.failed, .began), (.failed, .changed): newState = .cancelled
        default: return
        }
        state = newState
        lastState = newState
    }

    func didUpdate(gestureCategory: GestureCategory, in eventBridge: EventBindingBridge) {
        self.gestureCategory = gestureCategory
    }
}

// MARK: - EventPhase + NSEvent.Phase

extension EventPhase {
    fileprivate init?(_ phase: NSEvent.Phase) {
        switch phase {
        case .began: self = .began
        case .stationary, .changed: self = .active
        case .ended: self = .ended
        case .cancelled: self = .failed
        default: return nil
        }
    }
}
#endif
