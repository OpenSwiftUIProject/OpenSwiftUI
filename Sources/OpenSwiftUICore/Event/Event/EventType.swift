//
//  EventType.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - EventType

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public protocol EventType {
    var phase: EventPhase { get }

    var timestamp: Time { get }

    var binding: EventBinding? { get set }

    init?(_ event: any EventType)
}

extension EventType {
    package init?(_ event: any EventType) {
        guard let event = event as? Self else {
            return nil
        }
        self = event
    }

    package var isFocusEvent: Bool {
        HitTestableEvent(self) == nil
    }
}
