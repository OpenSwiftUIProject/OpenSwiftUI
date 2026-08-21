//
//  PanEvent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - PanEventType

package protocol PanEventType: EventType, TouchTypeProviding {
    var translation: CGSize { get }

    var globalTranslation: CGSize { get }
}

// MARK: - PanEvent

package struct PanEvent:
    PanEventType,
    HitTestableEventType,
    SpatialEventType,
    Equatable
{
    package var location: CGPoint {
        didSet {
            translation = .init(location)
        }
    }

    package var globalLocation: CGPoint
    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?
    package var translation: CGSize
    package var globalTranslation: CGSize
    package var touchType: TouchType

    package init(_ event: any PanEventType) {
        let phase = event.phase
        let timestamp = event.timestamp
        let binding = event.binding
        let translation = event.translation
        let globalTranslation = event.globalTranslation
        let touchType = event.touchType

        location = .init(translation)
        globalLocation = .init(globalTranslation)
        self.phase = phase
        self.timestamp = timestamp
        self.binding = binding
        self.translation = translation
        self.globalTranslation = globalTranslation
        self.touchType = touchType
    }

    package init(
        globalLocation: CGPoint,
        phase: EventPhase,
        timestamp: Time,
        globalTranslation: CGSize,
        touchType: TouchType
    ) {
        location = globalLocation
        self.globalLocation = globalLocation
        self.phase = phase
        self.timestamp = timestamp
        binding = nil
        translation = globalTranslation
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
