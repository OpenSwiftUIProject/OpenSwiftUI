//
//  UIKitGestureRecognizer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 062C14327F4C9197D92807A7F4DF7F3B (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIKitGestureRecognizer

class UIKitGestureRecognizer: UIGestureRecognizer {
    weak var eventBridge: EventBindingBridge?

    private var initialScale: CGFloat = 1.0

    private var initialAngle: Angle = .zero

    private var scrollConverter = ScrollEventConverter()

    var gestureCategory: GestureCategory = []

    private var lastInheritedPhase: _GestureInputs.InheritedPhase?

    private var lastState: UIGestureRecognizer.State?

    @inline(__always)
    final var shouldForwardInheritedPhase: Bool {
        isLinkedOnOrAfter(.v6)
            && !GestureContainerFeature.isEnabled
            && !CoreTesting.isRunning
    }

    func didAttach(to eventBridge: EventBindingBridge?) {
        _openSwiftUIEmptyStub()
    }

    private func updateInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        guard shouldForwardInheritedPhase, phase != lastInheritedPhase else {
            return
        }
        eventBridge?.setInheritedPhase(phase)
        lastInheritedPhase = phase
    }

    private func convert(
        touches: Set<UITouch>,
        with event: UIEvent
    ) -> [EventID: TouchEvent] {
        var events: [EventID: TouchEvent] = [:]
        for touch in touches {
            let eventID = EventID(touch, subtype: TouchEvent.self)
            let touchEvent = withExtendedLifetime(view) {
                let phase = EventPhase(touch.phase)
                let globalLocation = touch.location(in: nil)
                let timestamp = Time(seconds: touch.timestamp)
                let radius = touch.majorRadius
                let force = touch.force
                let maximumPossibleForce = touch.maximumPossibleForce
                let modifiers = EventModifiers(event.modifierFlags)
                let altitude = Angle(radians: touch.altitudeAngle)
                let azimuth = Angle(radians: touch.azimuthAngle(in: nil))
                let type = TouchType(touch.type)
                return TouchEvent(
                    timestamp: timestamp,
                    phase: phase,
                    location: .zero,
                    globalLocation: globalLocation,
                    radius: radius,
                    force: force,
                    maximumPossibleForce: maximumPossibleForce,
                    modifiers: modifiers,
                    altitude: altitude,
                    azimuth: azimuth,
                    touchType: type
                )
            }
            events[eventID] = touchEvent
        }
        return events
    }

    private func send(touches: Set<UITouch>, event: UIEvent) {
        let events = convert(touches: touches, with: event)
        eventBridge?.send(events, source: self)
    }

    private func convert(
        buttonEvents: Set<UIPress>,
        with event: UIEvent
    ) -> [EventID: PhysicalButtonEvent] {
        var events: [EventID: PhysicalButtonEvent] = [:]
        for press in buttonEvents {
            let eventID = EventID(press, subtype: PhysicalButtonEvent.self)
            let timestamp = Time(seconds: press.timestamp)
            let phase = EventPhase(press.phase)
            let type = PhysicalButtonEvent.ButtonType(press.type)
            let buttonEvent = PhysicalButtonEvent(
                timestamp: timestamp,
                phase: phase,
                binding: nil,
                type: type
            )
            events[eventID] = buttonEvent
        }
        return events
    }

    private func send(buttonEvents: Set<UIPress>, event: UIEvent) {
        let events = convert(buttonEvents: buttonEvents, with: event)
        eventBridge?.send(events, source: self)
    }

    func eventBindingSourceDidUpdate(
        phase: GesturePhase<Void>,
        in eventBridge: EventBindingBridge
    ) {
        let nextState = state.nextState(for: phase)
        state = nextState
        lastState = nextState
    }

    func eventBindingSourceDidUpdate(
        gestureCategory: GestureCategory,
        in eventBridge: EventBindingBridge
    ) {
        self.gestureCategory = gestureCategory
    }

    init() {
        super.init(target: nil, action: nil)
        let types: [UIPress.PressType] = [
            .upArrow,
            .downArrow,
            .leftArrow,
            .rightArrow,
            .select,
            .menu,
            .playPause,
            .back,
        ]
        allowedPressTypes = types.map { NSNumber(value: $0.rawValue) }
        delaysTouchesEnded = false
    }

    override func shouldReceive(_ event: UIEvent) -> Bool {
        if shouldForwardInheritedPhase, lastInheritedPhase == nil {
            updateInheritedPhase([])
        }
        return super.shouldReceive(event)
    }

    override func _updateForActiveEvents() {
        guard shouldForwardInheritedPhase else {
            return
        }

        let inheritedPhase: _GestureInputs.InheritedPhase
        if let lastState,
           state != lastState,
           (lastState == .possible || lastState == .ended),
           (state == .failed || state == .cancelled) {
            inheritedPhase = .active
        } else {
            inheritedPhase = _hasUnmetFailureRequirements ? [] : .failed
        }
        updateInheritedPhase(inheritedPhase)
    }

    override func reset() {
        eventBridge?.reset(
            eventSource: self,
            resetForwardedEventDispatchers: false
        )
        scrollConverter.reset()
        lastState = nil
        lastInheritedPhase = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches: touches, event: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches: touches, event: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches: touches, event: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches: touches, event: event)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        send(buttonEvents: presses, event: event)
    }

    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        send(buttonEvents: presses, event: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        send(buttonEvents: presses, event: event)
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        send(buttonEvents: presses, event: event)
    }

    override func _transformChanged(with event: UITransformEvent) {
        if event.phase == .began {
            initialScale = event.scale
            initialAngle = Angle(radians: -event.rotation)
        }
        let location = event.location(in: nil)
        let transformEvent = TransformEvent(
            timestamp: Time(seconds: event.timestamp),
            phase: .init(event.phase),
            globalLocation: location,
            location: location,
            initialScale: initialScale,
            scaleDelta: event.scale,
            initialAngle: initialAngle,
            angleDelta: Angle(radians: -event.rotation) - initialAngle
        )
        let events = [EventID(event, subtype: TransformEvent.self): transformEvent]
        eventBridge?.send(events, source: self)
    }

    override func _scrollingChanged(with event: UIScrollEvent) {
        let events = scrollConverter.convert(event, in: view?.window)
        eventBridge?.send(events, source: self)
    }
}

// MARK: - UIKitGestureRecognizer + EventBindingSource

extension UIKitGestureRecognizer: EventBindingSource {
    func attach(to eventBridge: EventBindingBridge) {
        self.eventBridge = eventBridge
        didAttach(to: self.eventBridge)
    }

    func `as`<T>(_ type: T.Type) -> T? {
        if UIGestureRecognizer.self == type {
            return unsafeBitCast(self as UIGestureRecognizer, to: T.self)
        } else {
            return nil
        }
    }

    func didUpdate(
        phase: GesturePhase<Void>,
        in eventBridge: EventBindingBridge
    ) {
        eventBindingSourceDidUpdate(
            phase: phase,
            in: eventBridge
        )
    }

    func didUpdate(
        gestureCategory: GestureCategory,
        in eventBridge: EventBindingBridge
    ) {
        eventBindingSourceDidUpdate(
            gestureCategory: gestureCategory,
            in: eventBridge
        )
    }
}

#endif
