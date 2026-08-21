//
//  HoverEvent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
package import OpenSwiftUICore

// MARK: - HoverEvent

package struct HoverEvent:
    EventType,
    HitTestableEventType,
    NonGestureEventType,
    Equatable
{
    package var timestamp: Time
    package var phase: EventPhase
    package var binding: EventBinding?
    package var globalLocation: CGPoint

    package init(
        timestamp: Time,
        phase: EventPhase,
        binding: EventBinding? = nil,
        globalLocation: CGPoint
    ) {
        self.timestamp = timestamp
        self.phase = phase
        self.binding = binding
        self.globalLocation = globalLocation
    }

    package var hitTestLocation: CGPoint { globalLocation }

    package var hitTestRadius: CGFloat { .zero }
}
