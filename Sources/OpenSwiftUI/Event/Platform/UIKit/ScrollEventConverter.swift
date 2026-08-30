//
//  ScrollEventConverter.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - ScrollEventConverter

struct ScrollEventConverter {
    private var scrollSeed: UInt32 = .zero

    private var accumulatedScrollDelta: CGSize = .zero

    mutating func convert(
        _ event: UIScrollEvent,
        in view: UIView?
    ) -> [EventID: PanEvent] {
        let rawPhase = Int(event.phase)
        guard rawPhase > 1 else {
            return [:]
        }
        let eventID = EventID(
            type: (UIScrollEvent, PanEvent).self,
            serial: Int(bitPattern: ObjectIdentifier(event)) ^ Int(scrollSeed)
        )
        let delta = event._adjustedAcceleratedDelta(in: view)
        accumulatedScrollDelta.width += delta.dx
        accumulatedScrollDelta.height += delta.dy
        let panEvent = PanEvent(
            event,
            accumulatedScrollDelta: accumulatedScrollDelta,
            in: view
        )
        if rawPhase == 4 || rawPhase == 5 {
            scrollSeed &+= 1
            accumulatedScrollDelta = .zero
        }
        return [eventID: panEvent]
    }

    mutating func reset() {
        scrollSeed &+= 1
        accumulatedScrollDelta = .zero
    }
}

// MARK: - PanEvent + UIScrollEvent

extension PanEvent {
    init(
        _ event: UIScrollEvent,
        accumulatedScrollDelta: CGSize,
        in view: UIView?
    ) {
        let globalLocation = event.location(in: view)
        let timestamp = Time(seconds: event.timestamp)
        let phase: EventPhase = switch Int(event.phase) {
        case 2: .began
        case 3: .active
        case 4: .ended
        default: .failed
        }
        self.init(
            globalLocation: globalLocation,
            phase: phase,
            timestamp: timestamp,
            globalTranslation: accumulatedScrollDelta,
            touchType: .indirectPointer
        )
        translation = globalTranslation
        binding = nil
    }
}
#endif
