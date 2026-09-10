//
//  TransformEvent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation
@_spi(ForOpenSwiftUIOnly)
package import OpenSwiftUICore

// MARK: - TransformEvent

package struct TransformEvent: HitTestableEventType, SpatialEventType, Equatable {
    package var timestamp: Time
    package var phase: EventPhase
    package var binding: EventBinding?
    package var globalLocation: CGPoint
    package var location: CGPoint
    package var initialScale: CGFloat
    package var scaleDelta: CGFloat
    package var initialAngle: Angle
    package var angleDelta: Angle

    package init(
        timestamp: Time,
        phase: EventPhase,
        binding: EventBinding? = nil,
        globalLocation: CGPoint,
        location: CGPoint,
        initialScale: CGFloat,
        scaleDelta: CGFloat,
        initialAngle: Angle,
        angleDelta: Angle
    ) {
        self.timestamp = timestamp
        self.phase = phase
        self.binding = binding
        self.globalLocation = globalLocation
        self.location = location
        self.initialScale = initialScale
        self.scaleDelta = scaleDelta
        self.initialAngle = initialAngle
        self.angleDelta = angleDelta
    }

    package var radius: CGFloat { .zero }
}
