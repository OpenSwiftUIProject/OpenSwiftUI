//
//  Event.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - MouseEvent [6.5.4]

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

// MARK: - EventModifiers [6.5.4]

/// A set of key modifiers that you can add to a gesture.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct EventModifiers: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The Caps Lock key.
    public static let capsLock: EventModifiers = .init(rawValue: 1 << 0)

    /// The Shift key.
    public static let shift: EventModifiers = .init(rawValue: 1 << 1)

    /// The Control key.
    public static let control: EventModifiers = .init(rawValue: 1 << 2)

    /// The Option key.
    public static let option: EventModifiers = .init(rawValue: 1 << 3)

    /// The Command key.
    public static let command: EventModifiers = .init(rawValue: 1 << 4)

    /// Any key on the numeric keypad.
    public static let numericPad: EventModifiers = .init(rawValue: 1 << 5)

    /// The Function key.
    @available(*, deprecated, message: "Function modifier is reserved for system applications")
    public static let function: EventModifiers = .init(rawValue: 1 << 6)

    package static let _function: EventModifiers = .init(rawValue: 1 << 6)

    /// All possible modifier keys.
    public static let all: EventModifiers = [.capsLock, .shift, .control, .option, .command, .numericPad]

    package static let _all: EventModifiers = [.capsLock, .shift, .control, .option, .command, .numericPad, ._function]
}

// MARK: - ModifiersEventType [6.5.4]

package protocol ModifiersEventType: EventType {
    var modifiers: EventModifiers { get set }
}

// MARK: - EventPhase [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public enum EventPhase: Hashable {
    case began
    case active
    case ended
    case failed
}

@available(*, unavailable)
extension EventPhase: Sendable {}

extension EventPhase {
    package var isTerminal: Bool {
        switch self {
        case .began, .active: false
        case .ended, .failed: true
        }
    }
}

// MARK: - EventType [6.5.4]

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

// MARK: - Event [6.5.4]

package struct Event: EventType {
    package var phase: EventPhase
    package var timestamp: Time
    package var binding: EventBinding?

    package init<T>(_ event: T) where T: EventType {
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
    }

    package init?(_ event: any EventType) {
        phase = event.phase
        timestamp = event.timestamp
        binding = event.binding
    }
}

// MARK: - EventID [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public struct EventID: Hashable {
    package var type: any Any.Type

    package var serial: Int

    package init(type: any Any.Type, serial: Int) {
        self.type = type
        self.serial = serial
    }

    public static func == (lhs: EventID, rhs: EventID) -> Bool {
        lhs.type == rhs.type && lhs.serial == rhs.serial
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type))
        hasher.combine(serial)
    }
}

@available(*, unavailable)
extension EventID: Sendable {}

extension EventID {
    package init<T, S>(_ obj: T, subtype: S.Type) where T: NSObject {
        type = (T, S).self
        serial = unsafeBitCast(obj, to: Int.self)
    }
}

extension EventID: CustomStringConvertible {
    public var description: String {
        "\(type)#\(serial)"
    }
}
