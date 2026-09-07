//
//  Event.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - Event

package struct Event: EventType {
    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?

    package init<T>(_ event: T) where T: EventType {
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
    }

    package init?(_ event: any EventType) {
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
    }
}
