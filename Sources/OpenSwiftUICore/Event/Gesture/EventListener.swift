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

    // TBA
    mutating func updateValue() {
        guard resetIfNeeded() else {
            return
        }

        var matchedEventID: EventID?
        var matchedEvent: Event?
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
                    if trackingID != nil, listener.ignoresOtherEvents {
                        continue
                    }
                    failureReason = .eventArrivedMidstream
                    break
                }
            }

            guard let event = Event(rawEvent) else {
                if trackingID != nil, listener.ignoresOtherEvents {
                    continue
                }
                failureReason = .unexpectedEvent
                break
            }

            if let trackingID {
                guard trackingID == eventID else {
                    if listener.ignoresOtherEvents {
                        continue
                    }
                    failureReason = .multipleMatchingEvents
                    break
                }
            } else {
                trackingID = eventID
            }

            guard matchedEvent == nil else {
                failureReason = .multipleMatchingEvents
                break
            }
            matchedEventID = eventID
            matchedEvent = event
        }

        guard failureReason == nil else {
            value = Value(
                phase: .failed,
                trackingID: trackingID,
                failureReason: failureReason
            )
            return
        }

        guard var matchedEvent, let matchedEventID else {
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
            var events = [matchedEventID: matchedEvent]
            let resolvedTransform = Graph.withoutUpdate { transform }
            let resolvedPosition = Graph.withoutUpdate { position }
            let convertedTransform = resolvedTransform.withPosition(resolvedPosition)
            defaultConvertEventLocations(&events) { points in
                convertedTransform.convert(
                    ViewTransform.Conversion.globalToSpace(.local),
                    points: &points
                )
            }
            matchedEvent = events[matchedEventID] ?? matchedEvent
        }

        switch matchedEvent.phase {
        case .began:
            value = Value(
                phase: .possible(matchedEvent),
                trackingID: trackingID,
                failureReason: nil
            )
        case .active:
            value = Value(
                phase: .active(matchedEvent),
                trackingID: trackingID,
                failureReason: nil
            )
        case .ended:
            value = Value(
                phase: .ended(matchedEvent),
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
