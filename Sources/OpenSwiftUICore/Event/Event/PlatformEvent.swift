//
//  PlatformEvent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - NonGestureEventType [6.5.4]

package protocol NonGestureEventType: EventType {}

// MARK: - PanEventType [6.5.4]

package protocol PanEventType: EventType, TouchTypeProviding {
    var translation: CGSize { get }

    var globalTranslation: CGSize { get }
}

// MARK: - TouchEvent [6.5.4]

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
        CGSize(width: location.x, height: location.y)
    }

    package var globalTranslation: CGSize {
        CGSize(width: globalLocation.x, height: globalLocation.y)
    }

    package var kind: SpatialEvent.Kind? { .touch }
}

// MARK: - PanEvent [6.5.4]

package struct PanEvent:
    EventType,
    HitTestableEventType,
    PanEventType,
    SpatialEventType,
    Equatable
{
    package var location: CGPoint
    package var globalLocation: CGPoint
    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?
    package var translation: CGSize
    package var globalTranslation: CGSize
    package var touchType: TouchType

    package init(_ event: any PanEventType) {
        let spatialEvent = event as? any SpatialEventType
        location = spatialEvent?.location ?? .zero
        globalLocation = spatialEvent?.globalLocation ?? .zero
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
        translation = event.translation
        globalTranslation = event.globalTranslation
        touchType = event.touchType
    }

    package init(
        globalLocation: CGPoint,
        phase: EventPhase,
        timestamp: Time,
        globalTranslation: CGSize,
        touchType: TouchType
    ) {
        location = .zero
        self.globalLocation = globalLocation
        self.phase = phase
        self.timestamp = timestamp
        binding = nil
        translation = .zero
        self.globalTranslation = globalTranslation
        self.touchType = touchType
    }

    package init?(_ event: any EventType) {
        guard let event = event as? any PanEventType else {
            return nil
        }
        self.init(event)
    }

    package var radius: CGFloat { .zero }

    package var kind: SpatialEvent.Kind? { .pan }
}

// MARK: - PhysicalButtonEvent [6.5.4]

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

// MARK: - HoverEvent [6.5.4]

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
