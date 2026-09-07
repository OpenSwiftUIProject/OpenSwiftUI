//
//  HitTestableEvent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - HitTestableEventType

package protocol HitTestableEventType: EventType {
    var hitTestLocation: CGPoint { get }
    var hitTestRadius: CGFloat { get }
}

// MARK: - HitTestableEvent

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
