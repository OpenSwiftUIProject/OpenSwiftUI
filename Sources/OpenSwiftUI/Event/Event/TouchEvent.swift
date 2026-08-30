//
//  TouchEvent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation
@_spi(ForOpenSwiftUIOnly)
package import OpenSwiftUICore

// MARK: - TouchEvent

package struct TouchEvent:
    EventType,
    HitTestableEventType,
    ModifiersEventType,
    PanEventType,
    SpatialEventType,
    TappableEventType,
    Equatable
{
    package var timestamp: Time
    package var phase: EventPhase
    package var binding: EventBinding?
    package var location: CGPoint
    package var globalLocation: CGPoint
    package var radius: CGFloat
    package var force: Double
    package var maximumPossibleForce: Double
    package var modifiers: EventModifiers
    package var altitude: Angle
    package var azimuth: Angle
    package var touchType: TouchType

    package init(
        timestamp: Time,
        phase: EventPhase,
        binding: EventBinding? = nil,
        location: CGPoint,
        globalLocation: CGPoint,
        radius: CGFloat,
        force: Double,
        maximumPossibleForce: Double,
        modifiers: EventModifiers,
        altitude: Angle,
        azimuth: Angle,
        touchType: TouchType
    ) {
        self.timestamp = timestamp
        self.phase = phase
        self.binding = binding
        self.location = location
        self.globalLocation = globalLocation
        self.radius = radius
        self.force = force
        self.maximumPossibleForce = maximumPossibleForce
        self.modifiers = modifiers
        self.altitude = altitude
        self.azimuth = azimuth
        self.touchType = touchType
    }

    package var translation: CGSize {
        CGSize(location)
    }

    package var globalTranslation: CGSize {
        CGSize(globalLocation)
    }

    package var kind: SpatialEvent.Kind? { .touch }
}
