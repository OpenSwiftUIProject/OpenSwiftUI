//
//  HitTestableEvent.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - HitTestableEventType [6.5.4]

package protocol HitTestableEventType: EventType {
    var hitTestLocation: CGPoint { get }
    var hitTestRadius: CGFloat { get }
}

// MARK: - HitTestableEvent [6.5.4]

package struct HitTestableEvent: HitTestableEventType, Equatable {
    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?
    package var hitTestLocation: CGPoint
    package var hitTestRadius: CGFloat

    package init<T>(_ event: T) where T: HitTestableEventType {
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
        hitTestLocation = event.hitTestLocation
        hitTestRadius = event.hitTestRadius
    }

    package init(_ event: any HitTestableEventType) {
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
        hitTestLocation = event.hitTestLocation
        hitTestRadius = event.hitTestRadius
    }

    package init?(_ event: any EventType) {
        guard let event = event as? any HitTestableEventType else {
            return nil
        }
        self.init(event)
    }
}

extension HitTestableEventType where Self: SpatialEventType {
    package var hitTestLocation: CGPoint { globalLocation }

    package var hitTestRadius: CGFloat { radius }
}
