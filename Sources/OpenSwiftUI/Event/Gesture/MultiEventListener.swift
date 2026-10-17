//
//  MultiEventListener.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 48A1B633EB30B4EB4C3B390476685C06 (SwiftUI)

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenAttributeGraphShims

// MARK: - MultiEventListener

struct MultiEventListener<Event>: PrimitiveGesture where Event: EventType {
    var allowsFailure: Bool

    static func _makeGesture(
        gesture: _GraphValue<MultiEventListener<Event>>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<[EventID: Event]> {
        let phase = Attribute(MultiEventListenerPhase(
            events: inputs.events,
            position: inputs.animatedPosition(),
            transform: inputs.transform,
            resetSeed: inputs.resetSeed,
            listener: gesture.value,
            preconvertedEventLocations: inputs.options.contains(.preconvertedEventLocations),
            allowsIncompleteEventSequences: inputs.options.contains(.allowsIncompleteEventSequences),
            endedEventIDs: [],
            lastResetSeed: .zero
        ))
        return _GestureOutputs(phase: phase)
    }

    typealias Body = Never

    typealias Value = [EventID: Event]
}

// MARK: - MultiEventListenerPhase

private struct MultiEventListenerPhase<Event>: ResettableGestureRule, CustomStringConvertible where Event: EventType {
    @Attribute var events: [EventID: any EventType]
    @Attribute var position: ViewOrigin
    @Attribute var transform: ViewTransform
    @Attribute var resetSeed: UInt32
    @Attribute var listener: MultiEventListener<Event>
    let preconvertedEventLocations: Bool
    let allowsIncompleteEventSequences: Bool
    var latestEvents: [EventID: Event] = [:]
    var endedEventIDs: Set<EventID>
    var lastResetSeed: UInt32

    typealias Value = GesturePhase<[EventID: Event]>

    typealias PhaseValue = [EventID: Event]

    var description: String {
        "MultiListener[\(Event.self)]"
    }

    mutating func resetPhase() {
        latestEvents.removeAll()
        endedEventIDs = []
        value = .possible(nil)
    }

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        var didUpdate = false
        for (eventID, rawEvent) in events {
            if !allowsIncompleteEventSequences {
                guard rawEvent.binding != nil else {
                    guard latestEvents[eventID] == nil else {
                        value = .failed
                        return
                    }
                    continue
                }
                if latestEvents[eventID] == nil, rawEvent.phase != .began {
                    value = .failed
                    return
                }
            }
            guard let event = Event(rawEvent), event.binding != nil else {
                value = .failed
                return
            }
            latestEvents[eventID] = event
            if event.phase == .began {
                endedEventIDs.remove(eventID)
            }
            didUpdate = true
        }
        guard didUpdate else {
            if !hasValue {
                value = .possible(nil)
            }
            return
        }
        var events = latestEvents
        if !preconvertedEventLocations {
            let convertedTransform = Graph.withoutUpdate { transform.withPosition(position) }
            defaultConvertEventLocations(&events) { points in
                convertedTransform.convert(
                    ViewTransform.Conversion.globalToSpace(.local),
                    points: &points
                )
            }
        }
        let activeEvents = events.optimisticFilter { eventID, _ in
            !endedEventIDs.contains(eventID)
        }
        for (eventID, event) in activeEvents where event.phase.isTerminal {
            endedEventIDs.insert(eventID)
        }
        let phase = activeEvents.values.reduce(EventPhase.failed) { phase, event in
            if phase == .active || event.phase == .began || event.phase == .active {
                .active
            } else if phase == .ended || event.phase == .ended {
                .ended
            } else {
                phase
            }
        }
        switch phase {
        case .began:
            _openSwiftUIUnreachableCode()
        case .active:
            value = .active(activeEvents)
        case .ended:
            value = .ended(activeEvents)
        case .failed:
            value = listener.allowsFailure ? .failed : .ended(activeEvents)
        @unknown default:
            _openSwiftUIUnreachableCode()
        }
    }
}
