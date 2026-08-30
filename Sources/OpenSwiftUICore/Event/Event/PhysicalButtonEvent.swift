//
//  PhysicalButtonEvent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - PhysicalButtonEvent

package struct PhysicalButtonEvent: EventType, Equatable {
    package enum ButtonType: Hashable {
        case upArrow
        case downArrow
        case leftArrow
        case rightArrow
        case select
        case menu
        case playPause
        case pageUp
        case pageDown
        case back
    }

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
