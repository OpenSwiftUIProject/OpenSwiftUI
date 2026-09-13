//
//  RotateEvent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - RotateEvent

struct RotateEvent: SpatialEventType, Equatable {
    var timestamp: Time
    var phase: EventPhase
    var binding: EventBinding?
    var globalLocation: CGPoint
    var angleDelta: Angle
    var initialAngle: Angle

    var location: CGPoint {
        get { globalLocation }
        set { globalLocation = newValue }
    }

    var radius: CGFloat { .zero }
}

extension RotateEvent: HitTestableEventType {}
