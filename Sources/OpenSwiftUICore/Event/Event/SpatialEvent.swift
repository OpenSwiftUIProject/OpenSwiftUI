//
//  SpatialEvent.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - SpatialEventType [6.5.4]

package protocol SpatialEventType: EventType {
    var globalLocation: CGPoint { get set }
    var location: CGPoint { get set }
    var radius: CGFloat { get }
    var kind: SpatialEvent.Kind? { get }
}

extension SpatialEventType {
    package var kind: SpatialEvent.Kind? { nil }
}

// MARK: - SpatialEvent [6.5.4]

package struct SpatialEvent: SpatialEventType, Equatable {
    package enum Kind: Equatable {
        case touch
        case mouse
        case pan
    }

    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?
    package var kind: SpatialEvent.Kind?
    package var globalLocation: CGPoint
    package var location: CGPoint
    package var radius: CGFloat

    package init<T>(_ event: T) where T: SpatialEventType {
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
        kind = event.kind
        globalLocation = event.globalLocation
        location = event.location
        radius = event.radius
    }

    package init(_ event: any SpatialEventType) {
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
        kind = event.kind
        globalLocation = event.globalLocation
        location = event.location
        radius = event.radius
    }

    package init?(_ event: any EventType) {
        guard let event = event as? any SpatialEventType else {
            return nil
        }
        self.init(event)
    }
}

package func defaultConvertEventLocations<E>(
    _ events: inout [EventID: E],
    converter: (inout [CGPoint]) -> Void
) {
    var eventIDs: [EventID] = []
    var points: [CGPoint] = []
    for (eventID, event) in events {
        guard var spatialEvent = event as? SpatialEventType else {
            continue
        }
        eventIDs.append(eventID)
        points.append(spatialEvent.globalLocation)
    }
    guard !points.isEmpty else {
        return
    }
    converter(&points)
    for (index, eventID) in eventIDs.enumerated() {
        guard var spatialEvent = events[eventID] as? SpatialEventType else {
            continue
        }
        spatialEvent.location = points[index]
        events[eventID] = spatialEvent as? E
    }
}
