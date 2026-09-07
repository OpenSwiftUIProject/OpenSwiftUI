//
//  MouseEvent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - MouseEvent

package struct MouseEvent: SpatialEventType, TappableEventType, ModifiersEventType, Equatable {
    package struct Button: RawRepresentable, Equatable {
        package let rawValue: Int

        package init(rawValue: Int) {
            self.rawValue = rawValue
        }

        package static let primary: MouseEvent.Button = .init(rawValue: 1 << 0)

        package static let secondary: MouseEvent.Button = .init(rawValue: 1 << 1)

        package static func other(_ index: Int) -> MouseEvent.Button {
            .init(rawValue: index)
        }
    }

    package var timestamp: Time
    package var binding: EventBinding?
    package var button: MouseEvent.Button
    package var phase: EventPhase
    package var location: CGPoint
    package var globalLocation: CGPoint
    package var modifiers: EventModifiers

    package init(
        timestamp: Time,
        binding: EventBinding? = nil,
        button: MouseEvent.Button,
        phase: EventPhase,
        location: CGPoint,
        globalLocation: CGPoint,
        modifiers: EventModifiers
    ) {
        self.timestamp = timestamp
        self.binding = binding
        self.button = button
        self.phase = phase
        self.location = location
        self.globalLocation = globalLocation
        self.modifiers = modifiers
    }

    package var radius: CGFloat { .zero }

    package var kind: SpatialEvent.Kind? { .mouse }
}

extension MouseEvent: HitTestableEventType {}
