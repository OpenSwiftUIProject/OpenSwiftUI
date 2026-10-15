#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Foundation
import UIKit
import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

final class AndroidTouchGestureRecognizer: UIGestureRecognizer, EventBindingSource {
    private weak var eventBridge: EventBindingBridge?
    private var activeTouches: Set<UITouch> = []

    init() {
        super.init()
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
    }

    nonisolated func attach(to eventBridge: EventBindingBridge) {
        MainActor.assumeIsolated { self.eventBridge = eventBridge }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard isEnabled else { return }
        activeTouches.formUnion(touches)
        send(touches, phase: .began)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches.intersection(activeTouches), phase: .active)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches.intersection(activeTouches), phase: .ended)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        send(touches.intersection(activeTouches), phase: .failed)
    }

    func cancelTouches() {
        send(activeTouches, phase: .failed)
    }

    private func send(_ touches: Set<UITouch>, phase: EventPhase) {
        guard !touches.isEmpty, let view, let eventBridge else { return }
        var events: [EventID: any EventType] = [:]
        let timestamp = Time.systemUptime
        for touch in touches {
            let point = touch.location(in: view)
            let location = Foundation.CGPoint(x: point.x, y: point.y)
            let id = EventID(type: TouchEvent.self, serial: Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque()))
            // The graph's global space is the hosting view, not the SDL window.
            events[id] = TouchEvent(
                timestamp: timestamp,
                phase: phase,
                location: location,
                globalLocation: location,
                radius: 0,
                force: 0,
                maximumPossibleForce: 0,
                modifiers: [],
                altitude: .zero,
                azimuth: .zero,
                touchType: .direct
            )
        }
        if phase.isTerminal { activeTouches.subtract(touches) }
        Update.ensure {
            eventBridge.send(events, source: self)
            if activeTouches.isEmpty {
                eventBridge.reset(eventSource: self)
            }
        }
    }
}
#endif
