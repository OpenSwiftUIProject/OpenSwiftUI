//
//  UIKitGestureRecognizer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 062C14327F4C9197D92807A7F4DF7F3B (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIKitGestureRecognizer [WIP]

final class UIKitGestureRecognizer: UIGestureRecognizer {
    weak var eventBridge: EventBindingBridge?

    private var initialScale: CGFloat = 1.0

    private var initialAngle: Angle = .zero

    private var scrollConverter = ScrollEventConverter()

    var gestureCategory: GestureCategory = []

    private var lastInheritedPhase: _GestureInputs.InheritedPhase?

    private var lastState: UIGestureRecognizer.State?

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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TBA
    
    func didAttach(to eventBridge: EventBindingBridge?) {}

    override func shouldReceive(_ event: UIEvent) -> Bool {
        if shouldForwardInheritedPhase, lastInheritedPhase == nil {
            updateInheritedPhase([])
        }
        return super.shouldReceive(event)
    }

    @objc(_updateForActiveEvents)
    private func updateForActiveEvents() {
        guard shouldForwardInheritedPhase else {
            return
        }

        let inheritedPhase: _GestureInputs.InheritedPhase
        if let lastState,
           state != lastState,
           (lastState == .possible || lastState == .ended),
           (state == .cancelled || state == .failed)
        {
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
        send(touches: touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches: touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches: touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches: touches, with: event)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        send(presses: presses, with: event)
    }

    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        send(presses: presses, with: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        send(presses: presses, with: event)
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        send(presses: presses, with: event)
    }

    @objc(_transformChangedWithEvent:)
    private func transformChanged(with event: UITransformEvent) {
        guard let eventBridge else {
            return
        }
        let rawPhase = Int(event.phase)
        let scale = event.scale
        let rotation = event.rotation
        let location = event.location(in: nil)

        if rawPhase == 1 {
            initialScale = scale
            initialAngle = Angle(radians: -rotation)
        }

        let transformEvent = TransformEvent(
            timestamp: Time(seconds: event.timestamp),
            phase: transformPhase(rawValue: rawPhase),
            globalLocation: location,
            location: location,
            initialScale: initialScale,
            scaleDelta: scale,
            initialAngle: initialAngle,
            angleDelta: Angle(radians: -rotation - initialAngle.radians)
        )
        eventBridge.send(
            [EventID(event, subtype: TransformEvent.self): transformEvent],
            source: self
        )
    }

    @objc(_scrollingChangedWithEvent:)
    private func scrollingChanged(with event: UIScrollEvent) {
        let events = scrollConverter.convert(event, in: view?.window)
        eventBridge?.send(
            events.mapValues { $0 as any EventType },
            source: self
        )
    }

    private var shouldForwardInheritedPhase: Bool {
        isLinkedOnOrAfter(.v6)
            && !GestureContainerFeature.isEnabled
            && !CoreTesting.isRunning
    }

    private func updateInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        guard shouldForwardInheritedPhase, phase != lastInheritedPhase else {
            return
        }
        eventBridge?.setInheritedPhase(phase)
        lastInheritedPhase = phase
    }

    private func send(touches: Set<UITouch>, with event: UIEvent) {
        guard let eventBridge else {
            return
        }
        eventBridge.send(
            convert(touches: touches, with: event)
                .mapValues { $0 as any EventType },
            source: self
        )
    }

    private func send(presses: Set<UIPress>, with event: UIPressesEvent) {
        guard let eventBridge else {
            return
        }
        eventBridge.send(
            convert(presses: presses)
                .mapValues { $0 as any EventType },
            source: self
        )
    }

    private func convert(
        touches: Set<UITouch>,
        with event: UIEvent
    ) -> [EventID: TouchEvent] {
        var events: [EventID: TouchEvent] = [:]
        for touch in touches {
            let touchEvent = TouchEvent(
                timestamp: Time(seconds: touch.timestamp),
                phase: touchPhase(rawValue: touch.phase.rawValue),
                location: .zero,
                globalLocation: touch.location(in: nil),
                radius: touch.majorRadius,
                force: touch.force,
                maximumPossibleForce: touch.maximumPossibleForce,
                modifiers: EventModifiers(event.modifierFlags),
                altitude: Angle(radians: touch.altitudeAngle),
                azimuth: Angle(radians: touch.azimuthAngle(in: nil)),
                touchType: touchType(rawValue: touch.type.rawValue)
            )
            events[EventID(touch, subtype: TouchEvent.self)] = touchEvent
        }
        return events
    }

    private func convert(
        presses: Set<UIPress>
    ) -> [EventID: PhysicalButtonEvent] {
        var events: [EventID: PhysicalButtonEvent] = [:]
        for press in presses {
            let buttonEvent = PhysicalButtonEvent(
                timestamp: Time(seconds: press.timestamp),
                phase: pressPhase(rawValue: press.phase.rawValue),
                binding: nil,
                type: buttonType(rawValue: press.type.rawValue)
            )
            events[EventID(press, subtype: PhysicalButtonEvent.self)] = buttonEvent
        }
        return events
    }

    private func touchPhase(rawValue: Int) -> EventPhase {
        switch rawValue {
        case 0: .began
        case 1, 2, 5, 6: .active
        case 3, 7: .ended
        case 4: .failed
        default: preconditionFailure("Unsupported touch phase")
        }
    }

    private func pressPhase(rawValue: Int) -> EventPhase {
        switch rawValue {
        case 0: .began
        case 1, 2: .active
        case 3: .ended
        case 4: .failed
        default: preconditionFailure("Unsupported press phase")
        }
    }

    private func transformPhase(rawValue: Int) -> EventPhase {
        switch rawValue {
        case 1: .began
        case 2: .active
        case 3: .ended
        default: .failed
        }
    }

    private func touchType(rawValue: Int) -> TouchType {
        switch rawValue {
        case 0: .direct
        case 1: .indirect
        case 2: .pencil
        case 3: .indirectPointer
        default: preconditionFailure("Unsupported touch type")
        }
    }

    private func buttonType(rawValue: Int) -> PhysicalButtonEvent.ButtonType {
        switch rawValue {
        case 0: .upArrow
        case 1: .downArrow
        case 2: .leftArrow
        case 3: .rightArrow
        case 4: .select
        case 5: .menu
        case 6: .playPause
        case 7: .back
        case 30: .pageUp
        case 31: .pageDown
        default: preconditionFailure("Unsupported press type")
        }
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
        let nextState = state.nextState(for: phase)
        state = nextState
        lastState = nextState
    }

    func didUpdate(
        gestureCategory: GestureCategory,
        in eventBridge: EventBindingBridge
    ) {
        self.gestureCategory = gestureCategory
    }
}

#endif
