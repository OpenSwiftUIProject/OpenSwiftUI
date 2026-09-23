//
//  SDLMouseEventSource.swift
//  OpenSwiftUI

#if OPENSWIFTUI_SDL3
import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import SwiftSDL3

final class SDLMouseEventSource: EventBindingManagerDelegate {
    private struct Pointer: Hashable {
        var device: SDL_MouseID
        var button: UInt8
    }

    private let manager: EventBindingManager
    private var serial = 0
    private var sequences: [Pointer: Int] = [:]
    private var pressed: [Pointer: MouseEvent] = [:]

    init(manager: EventBindingManager) {
        self.manager = manager
    }

    func handle(_ event: SDL_Event, window: OpaquePointer, size: CGSize) {
        switch SDL_EventType(event.type) {
        case SDL_EVENT_MOUSE_BUTTON_DOWN, SDL_EVENT_MOUSE_BUTTON_UP:
            let button = event.button
            guard button.windowID == SDL_GetWindowID(window) else { return }
            let pointer = Pointer(device: button.which, button: button.button)
            let began = event.type == SDL_EVENT_MOUSE_BUTTON_DOWN.rawValue
            if began {
                guard pressed[pointer] == nil else { return }
                if pressed.isEmpty, button.clicks <= 1 {
                    Update.ensure { manager.reset() }
                    sequences.removeAll(keepingCapacity: true)
                }
                if button.clicks <= 1 || sequences[pointer] == nil {
                    serial &+= 1
                    sequences[pointer] = serial
                }
            } else if pressed[pointer] == nil {
                return
            }
            let mouse = makeEvent(
                pointer: pointer, phase: began ? .began : .ended,
                timestamp: button.timestamp,
                point: Self.location(x: button.x, y: button.y, window: window, size: size)
            )
            pressed[pointer] = began ? mouse : nil
            manager.send(mouse, id: sequences[pointer]!)
        case SDL_EVENT_MOUSE_MOTION:
            let motion = event.motion
            guard motion.windowID == SDL_GetWindowID(window) else { return }
            var events: [EventID: any EventType] = [:]
            for pointer in Array(pressed.keys) where pointer.device == motion.which {
                let mouse = makeEvent(
                    pointer: pointer, phase: .active, timestamp: motion.timestamp,
                    point: Self.location(x: motion.x, y: motion.y, window: window, size: size)
                )
                pressed[pointer] = mouse
                events[EventID(type: MouseEvent.self, serial: sequences[pointer]!)] = mouse
            }
            if !events.isEmpty { manager.send(events) }
        default: break
        }
    }

    // SDL coordinates are window units, not necessarily pixels or OSUI points.
    static func location(x: Float, y: Float, window: OpaquePointer, size: CGSize) -> CGPoint {
        var width: Int32 = 0, height: Int32 = 0
        SDL_GetWindowSize(window, &width, &height)
        guard width > 0, height > 0 else { return .zero }
        return CGPoint(x: CGFloat(x) * size.width / CGFloat(width),
                       y: CGFloat(y) * size.height / CGFloat(height))
    }

    private func makeEvent(pointer: Pointer, phase: EventPhase, timestamp: UInt64, point: CGPoint) -> MouseEvent {
        let button: MouseEvent.Button
        switch Int32(pointer.button) {
        case SDL_BUTTON_LEFT: button = .primary
        case SDL_BUTTON_RIGHT: button = .secondary
        default: button = .other(Int(pointer.button))
        }
        let flags = UInt32(SDL_GetModState())
        var modifiers: EventModifiers = []
        if flags & SDL_KMOD_SHIFT != 0 { modifiers.insert(.shift) }
        if flags & SDL_KMOD_CTRL != 0 { modifiers.insert(.control) }
        if flags & SDL_KMOD_ALT != 0 { modifiers.insert(.option) }
        if flags & SDL_KMOD_GUI != 0 { modifiers.insert(.command) }
        if flags & SDL_KMOD_CAPS != 0 { modifiers.insert(.capsLock) }
        let now = SDL_GetTicksNS()
        let time = Time.systemUptime + (Double(timestamp == 0 ? now : timestamp) - Double(now)) / 1e9
        return MouseEvent(timestamp: time, button: button, phase: phase,
                          location: point, globalLocation: point, modifiers: modifiers)
    }

    func cancel() {
        Update.ensure {
            let events: [EventID: any EventType] = Dictionary(uniqueKeysWithValues: pressed.map { pointer, mouse in
                var mouse = mouse
                mouse.phase = .failed
                return (EventID(type: MouseEvent.self, serial: sequences[pointer]!), mouse)
            })
            pressed.removeAll(keepingCapacity: true)
            sequences.removeAll(keepingCapacity: true)
            if !events.isEmpty { manager.send(events) }
            manager.reset()
        }
    }

    func didUpdate(phase: GesturePhase<Void>, in eventBindingManager: EventBindingManager) {
        if phase.isTerminal { eventBindingManager.reset() }
    }
}
#endif
