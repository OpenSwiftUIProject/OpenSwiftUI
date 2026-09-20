//
//  PhysicalButtonEvent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - PhysicalButtonEvent

package struct PhysicalButtonEvent: EventType, Equatable {
    package typealias ButtonType = PhysicalButton

    package var timestamp: Time
    package var phase: EventPhase
    package var binding: EventBinding?
    package var type: ButtonType

    package init(
        timestamp: Time,
        phase: EventPhase,
        binding: EventBinding?,
        type: ButtonType
    ) {
        self.timestamp = timestamp
        self.phase = phase
        self.binding = binding
        self.type = type
    }
}
