//
//  TappableEvent.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - TappableEventType [6.5.4]

package protocol TappableEventType: EventType {}

package typealias PlatformTappableSpatialEvent = TappableSpatialEvent

// MARK: - TappableEvent [6.5.4]

package struct TappableEvent: TappableEventType, Equatable {
    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?

    package init<T>(_ event: T) where T: TappableEventType {
        self.phase = event.phase
        self.timestamp = event.timestamp
        self.binding = event.binding
    }

    package init(_ event: any TappableEventType) {
        self.phase = event.phase
        self.timestamp = event.timestamp
        self.binding = event.binding
    }

    package init?(_ event: any EventType) {
        guard let event = event as? any TappableEventType else {
            return nil
        }
        self.init(event)
    }
}

// MARK: - TappableSpatialEvent [6.5.4]

package struct TappableSpatialEvent: TappableEventType, SpatialEventType, Equatable {
    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?
    package var globalLocation: CGPoint
    package var location: CGPoint
    package var radius: CGFloat

    package init<T>(_ event: T) where T: SpatialEventType, T: TappableEventType {
        self.phase = event.phase
        self.timestamp = event.timestamp
        self.binding = event.binding
        self.globalLocation = event.globalLocation
        self.location = event.location
        self.radius = event.radius
    }

    package init(_ event: any SpatialEventType & TappableEventType) {
        self.phase = event.phase
        self.timestamp = event.timestamp
        self.binding = event.binding
        self.globalLocation = event.globalLocation
        self.location = event.location
        self.radius = event.radius
    }

    package init?(_ event: any EventType) {
        guard let event = event as? any SpatialEventType & TappableEventType else {
            return nil
        }
        self.init(event)
    }
}

// MARK: - TouchTypeProviding [6.5.4]

package protocol TouchTypeProviding {
    var touchType: TouchType { get }
}
