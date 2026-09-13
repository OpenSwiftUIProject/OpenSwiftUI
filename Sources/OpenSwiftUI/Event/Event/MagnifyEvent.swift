//
//  MagnifyEvent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - MagnifyEvent

struct MagnifyEvent: SpatialEventType, Equatable {
    var timestamp: Time
    var phase: EventPhase
    var binding: EventBinding?
    var globalLocation: CGPoint
    var scaleDelta: CGFloat
    var initialScale: CGFloat

    var location: CGPoint {
        get { globalLocation }
        set { globalLocation = newValue }
    }

    var radius: CGFloat { .zero }
}

extension MagnifyEvent: HitTestableEventType {}
