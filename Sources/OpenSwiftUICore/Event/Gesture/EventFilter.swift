//
//  EventFilter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: DE98B8F5384114B687077BAB0EFA27D9 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - EventFilter

package struct EventFilter<Value>: GestureModifier {
    package var predicate: (any EventType) -> Bool

    package init(predicate: @escaping (any EventType) -> Bool) {
        self.predicate = predicate
    }

    package static func _makeGesture(
        modifier: _GraphValue<EventFilter<Value>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Value>
    ) -> _GestureOutputs<Value> {
        let filteredEvents = Attribute(EventFilterEvents(
            modifier: modifier.value,
            events: inputs.events
        ))
        var newInputs = inputs
        newInputs.events = filteredEvents[offset: { .of(&$0.events) }]
        let outputs = body(newInputs)
        let phase = Attribute(EventFilterPhase(
            phase: outputs.phase,
            filteredEvents: filteredEvents
        ))
        return outputs.withPhase(phase)
    }

    package typealias BodyValue = Value
}

// MARK: - EventFilterPhase

private struct EventFilterPhase<BodyValue>: Rule {
    @Attribute var phase: GesturePhase<BodyValue>
    @Attribute var filteredEvents: FilteredEvents

    typealias Value = GesturePhase<BodyValue>

    var value: GesturePhase<BodyValue> {
        guard !filteredEvents.failed else {
            return .failed
        }
        return phase
    }
}

// MARK: - FilteredEvents

private struct FilteredEvents {
    var events: [EventID: any EventType]
    var failed: Bool
}

// MARK: - EventFilterEvents

private struct EventFilterEvents<BodyValue>: Rule {
    @Attribute var modifier: EventFilter<BodyValue>
    @Attribute var events: [EventID: any EventType]

    typealias Value = FilteredEvents

    var value: FilteredEvents {
        let filtered = events.optimisticFilter { event in
            modifier.predicate(event.value)
        }
        return FilteredEvents(
            events: filtered,
            failed: filtered.count != events.count
        )
    }
}

// MARK: - Gesture + eventFilter

extension Gesture {
    package func eventFilter(
        _ predicate: @escaping (any EventType) -> Bool
    ) -> ModifierGesture<EventFilter<Value>, Self> {
        modifier(EventFilter(predicate: predicate))
    }

    package func eventFilter(
        allowedTypes: [any EventType.Type]
    ) -> ModifierGesture<EventFilter<Value>, Self> {
        eventFilter { event in
            allowedTypes.contains { allowedType in
                allowedType.init(event) != nil
            }
        }
    }

    package func eventFilter(
        allowedTypes: any EventType.Type...
    ) -> ModifierGesture<EventFilter<Value>, Self> {
        eventFilter(allowedTypes: allowedTypes)
    }

    package func eventFilter(
        allowedType: any EventType.Type
    ) -> ModifierGesture<EventFilter<Value>, Self> {
        eventFilter { event in
            allowedType.init(event) != nil
        }
    }

    package func eventFilter(
        excludedType: any EventType.Type
    ) -> ModifierGesture<EventFilter<Value>, Self> {
        eventFilter { event in
            excludedType.init(event) == nil
        }
    }

    private func eventFilter<FilteredEventType>(
        _ filteredType: FilteredEventType.Type,
        allowOtherTypes: Bool,
        _ predicate: @escaping (FilteredEventType) -> Bool
    ) -> ModifierGesture<EventFilter<Value>, Self> where FilteredEventType: EventType {
        eventFilter { event in
            guard let event = FilteredEventType(event) else {
                return allowOtherTypes
            }
            return predicate(event)
        }
    }

    package func eventFilter<FilteredEventType>(
        forType filteredType: FilteredEventType.Type,
        _ predicate: @escaping (FilteredEventType) -> Bool
    ) -> ModifierGesture<EventFilter<Value>, Self> where FilteredEventType: EventType {
        eventFilter(filteredType, allowOtherTypes: true, predicate)
    }

    package func eventFilter<FilteredEventType>(
        allowedType filteredType: FilteredEventType.Type,
        _ predicate: @escaping (FilteredEventType) -> Bool
    ) -> ModifierGesture<EventFilter<Value>, Self> where FilteredEventType: EventType {
        eventFilter(filteredType, allowOtherTypes: false, predicate)
    }
}
