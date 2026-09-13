//
//  EventListener.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D4E5D14C6252B45A30FB249B3DBDFD35 (SwiftUICore)

import Foundation
import OpenAttributeGraphShims

// MARK: - EventListener

package struct EventListener<Event>: PrimitiveGesture where Event: EventType {
    package var ignoresOtherEvents: Bool

    package init(ignoresOtherEvents: Bool = false) {
        self.ignoresOtherEvents = ignoresOtherEvents
    }

    package static func _makeGesture(
        gesture: _GraphValue<EventListener<Event>>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Event> {
        let phase = Attribute(EventListenerPhase(
            listener: gesture.value,
            events: inputs.events,
            position: inputs.animatedPosition(),
            transform: inputs.transform,
            resetSeed: inputs.resetSeed,
            preconvertedEventLocations: inputs.options.contains(.preconvertedEventLocations),
            allowsIncompleteEventSequences: inputs.options.contains(.allowsIncompleteEventSequences),
            trackingID: nil,
            lastResetSeed: .zero
        ))
        return _GestureOutputs(phase: phase.phase())
    }

    package typealias Body = Never

    package typealias Value = Event
}

extension EventListener: PrimitiveDebuggableGesture {}

// MARK: - EventListenerPhase

private struct EventListenerPhase<Event>: ResettableGestureRule, CustomStringConvertible where Event: EventType {
    enum FailureReason: Hashable {
        case rebound
        case eventArrivedMidstream
        case multipleMatchingEvents
        case unexpectedEvent
        case eventFailed
    }

    struct Value: DebuggableGesturePhase {
        var phase: GesturePhase<Event>
        var trackingID: EventID?
        var failureReason: FailureReason?

        var properties: ArrayWith2Inline<(String, String)> {
            var properties = ArrayWith2Inline<(String, String)>()
            if let failureReason {
                properties.append(("failure", String(describing: failureReason)))
            }
            if let trackingID {
                properties.append(("trackingID", trackingID.description))
            }
            return properties
        }
    }

    @Attribute var listener: EventListener<Event>
    @Attribute var events: [EventID: any EventType]
    @Attribute var position: ViewOrigin
    @Attribute var transform: ViewTransform
    @Attribute var resetSeed: UInt32
    let preconvertedEventLocations: Bool
    let allowsIncompleteEventSequences: Bool
    var trackingID: EventID?
    var lastResetSeed: UInt32

    typealias PhaseValue = Event

    var description: String {
        var description = "Listener[\(Event.self)]"
        if let trackingID {
            description += " \(trackingID)"
        }
        return description
    }

    mutating func resetPhase() {
        trackingID = nil
        value = Value(phase: .possible(nil), trackingID: nil, failureReason: nil)
    }

    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }
        var matchedEvent: (any EventType)?
        var failureReason: FailureReason?
        for (eventID, rawEvent) in events {
            guard rawEvent.binding != nil else {
                if trackingID == eventID {
                    failureReason = .rebound
                    break
                }
                continue
            }
            if !allowsIncompleteEventSequences {
                if trackingID != eventID && rawEvent.phase != .began {
                    if trackingID == nil || !listener.ignoresOtherEvents {
                        failureReason = .eventArrivedMidstream
                        break
                    }
                }
            }
            guard Event(rawEvent) != nil else {
                if trackingID != nil, listener.ignoresOtherEvents {
                    continue
                }
                failureReason = .unexpectedEvent
                break
            }
            if let trackingID {
                if trackingID != eventID && !listener.ignoresOtherEvents {
                    failureReason = .multipleMatchingEvents
                    break
                }
            } else {
                trackingID = eventID
            }
            matchedEvent = rawEvent
        }
        guard failureReason == nil else {
            value = Value(
                phase: .failed,
                trackingID: trackingID,
                failureReason: failureReason
            )
            return
        }
        guard var matchedEvent else {
            guard !hasValue else {
                return
            }
            value = Value(
                phase: .possible(nil),
                trackingID: trackingID,
                failureReason: nil
            )
            return
        }
        if !preconvertedEventLocations {
            let convertedTransform = Graph.withoutUpdate { transform.withPosition(position) }
            let trackingID = trackingID!
            var events = [trackingID: matchedEvent]
            defaultConvertEventLocations(&events) { points in
                convertedTransform.convert(
                    ViewTransform.Conversion.globalToSpace(.local),
                    points: &points
                )
            }
            matchedEvent = events[trackingID]!
        }
        guard let event = Event(matchedEvent) else {
            return
        }
        switch matchedEvent.phase {
        case .began, .active:
            value = Value(
                phase: .active(event),
                trackingID: trackingID,
                failureReason: nil
            )
        case .ended:
            value = Value(
                phase: .ended(event),
                trackingID: trackingID,
                failureReason: nil
            )
        case .failed:
            value = Value(
                phase: .failed,
                trackingID: trackingID,
                failureReason: .eventFailed
            )
        }
    }
}
