//
//  EventModifiers.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - EventModifiers

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

// MARK: - ModifiersEventType

package protocol ModifiersEventType: EventType {
    var modifiers: EventModifiers { get set }
}
