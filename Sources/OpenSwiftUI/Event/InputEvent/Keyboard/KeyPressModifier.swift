//
//  KeyPressModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C97FB0E5EC0789E5A42E597830BFC1D5 (SwiftUI)

public import Foundation
import OpenAttributeGraphShims
public import OpenSwiftUICore

// MARK: - View + onKeyPress

@available(OpenSwiftUI_v5_0, *)
@available(watchOS, unavailable)
extension View {
    /// Performs an action if the user presses a key on a hardware keyboard
    /// while the view has focus.
    ///
    /// OpenSwiftUI performs the action for key-down and key-repeat events.
    ///
    /// - Parameters:
    ///   - key: The key to match against incoming hardware keyboard events.
    ///   - action: The action to perform. Return `.handled` to consume the
    ///     event and prevent further dispatch, or `.ignored` to allow dispatch
    ///     to continue.
    /// - Returns: A modified view that binds hardware keyboard input
    ///   when focused.
    nonisolated public func onKeyPress(
        _ key: KeyEquivalent,
        action: @escaping () -> KeyPress.Result
    ) -> some View {
        onKeyPress(subject: .keys([key]), phases: [.down, .repeat]) { _ in
            action()
        }
    }

    /// Performs an action if the user presses a key on a hardware keyboard
    /// while the view has focus.
    ///
    /// OpenSwiftUI performs the action for the specified event phases.
    ///
    /// - Parameters:
    ///   - key: The key to match against incoming hardware keyboard events.
    ///   - phases: The key-press phases to match (`.down`, `.up`,
    ///     and `.repeat`).
    ///   - action: The action to perform. The action receives a value
    ///     describing the matched key event. Return `.handled` to consume the
    ///     event and prevent further dispatch, or `.ignored` to allow dispatch
    ///     to continue.
    /// - Returns: A modified view that binds hardware keyboard input
    ///   when focused.
    nonisolated public func onKeyPress(
        _ key: KeyEquivalent,
        phases: KeyPress.Phases,
        action: @escaping (KeyPress) -> KeyPress.Result
    ) -> some View {
        onKeyPress(subject: .keys([key]), phases: phases, action: action)
    }

    /// Performs an action if the user presses one or more keys on a hardware
    /// keyboard while the view has focus.
    ///
    /// - Parameters:
    ///   - keys: A set of keys to match against incoming hardware
    ///     keyboard events.
    ///   - phases: The key-press phases to match (`.down`, `.repeat`, and
    ///     `.up`). The default value is `[.down, .repeat]`.
    ///   - action: The action to perform. The action receives a value
    ///     describing the matched key event. Return `.handled` to consume the
    ///     event and prevent further dispatch, or `.ignored` to allow dispatch
    ///     to continue.
    /// - Returns: A modified view that binds keyboard input when focused.
    nonisolated public func onKeyPress(
        keys: Set<KeyEquivalent>,
        phases: KeyPress.Phases = [.down, .repeat],
        action: @escaping (KeyPress) -> KeyPress.Result
    ) -> some View {
        onKeyPress(subject: .keys(keys), phases: phases, action: action)
    }

    /// Performs an action if the user presses one or more keys on a hardware
    /// keyboard while the view has focus.
    ///
    /// - Parameters:
    ///   - characters: The set of characters to match against incoming
    ///     hardware keyboard events.
    ///   - phases: The key-press phases to match (`.down`, `.repeat`, and
    ///     `.up`). The default value is `[.down, .repeat]`.
    ///   - action: The action to perform. The action receives a value
    ///     describing the matched key event. Return `.handled` to consume the
    ///     event and prevent further dispatch, or `.ignored` to allow dispatch
    ///     to continue.
    /// - Returns: A modified view that binds hardware keyboard input
    ///   when focused.
    nonisolated public func onKeyPress(
        characters: CharacterSet,
        phases: KeyPress.Phases = [.down, .repeat],
        action: @escaping (KeyPress) -> KeyPress.Result
    ) -> some View {
        onKeyPress(subject: .characters(characters), phases: phases, action: action)
    }

    /// Performs an action if the user presses any key on a hardware keyboard
    /// while the view has focus.
    ///
    /// - Parameters:
    ///   - phases: The key-press phases to match (`.down`, `.repeat`, and
    ///     `.up`). The default value is `[.down, .repeat]`.
    ///   - action: The action to perform. The action receives a value
    ///     describing the matched key event. Return `.handled` to consume the
    ///     event and prevent further dispatch, or `.ignored` to allow dispatch
    ///     to continue.
    /// - Returns: A modified view that binds hardware keyboard input
    ///   when focused.
    nonisolated public func onKeyPress(
        phases: KeyPress.Phases = [.down, .repeat],
        action: @escaping (KeyPress) -> KeyPress.Result
    ) -> some View {
        onKeyPress(subject: .all, phases: phases, action: action)
    }

    nonisolated func onKeyPress(
        subject: KeyPress.Handler.Subject,
        phases: KeyPress.Phases,
        action: @escaping (KeyPress) -> KeyPress.Result
    ) -> some View {
        modifier(KeyPressModifier(handler: .init(subject: subject, phases: phases, action: action)))
    }
}

// MARK: - KeyPress

@available(OpenSwiftUI_v5_0, *)
@available(watchOS, unavailable)
public struct KeyPress: Sendable {
    /// The phase of the key-press event (`.down`, `.repeat`, or `.up`).
    public let phase: Phases

    /// The key equivalent value for the pressed key.
    public let key: KeyEquivalent

    /// The characters generated by the pressed key as if no modifier
    /// key applies.
    public let characters: String

    /// The set of modifier keys the user held in addition to the
    /// pressed key.
    public let modifiers: EventModifiers
}

@available(OpenSwiftUI_v5_0, *)
@available(watchOS, unavailable)
extension KeyPress: CustomDebugStringConvertible {
    /// Options for matching different phases of a key-press event.
    public struct Phases: OptionSet, Sendable, CustomDebugStringConvertible {
        /// The user pressed down on a key.
        public static let down: Phases = .init(rawValue: 1 << 0)

        /// The user held a key down to issue a sequence of repeating events.
        public static let `repeat`: Phases = .init(rawValue: 1 << 1)

        /// The user released a key.
        public static let up: Phases = .init(rawValue: 1 << 2)

        /// A value that matches all key press phases.
        public static let all: Phases = .init(rawValue: .max)

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public var debugDescription: String {
            var names: [String] = []
            if self == .all {
                names.append(".all")
            } else {
                if contains(.down) { names.append(".down") }
                if contains(.repeat) { names.append(".repeat") }
                if contains(.up) { names.append(".up") }
            }
            return names.count == 1 ? names[0] : "[\(names.joined(separator: ", "))]"
        }
    }

    /// A result value returned from a key-press action that indicates whether
    /// the action consumed the event.
    public enum Result: Sendable {
        /// The action consumed the event, preventing dispatch from continuing.
        case handled

        /// The action ignored the event, allowing dispatch to continue.
        case ignored
    }

    public var debugDescription: String {
        "KeyPress(\(phase), \"\(characters)\")"
    }
}

// MARK: - Deprecated API

@_spi(_)
extension View {
    @available(OpenSwiftUI_v5_0, *)
    @available(*, deprecated, renamed: "onKeyPress(keys:phases:action:)")
    @available(watchOS, unavailable)
    nonisolated public func onKeyPress(
        keysIn keys: Set<KeyEquivalent>,
        phases: KeyPress.Phases = [.down, .repeat],
        action: @escaping (KeyPress) -> KeyPress.Result
    ) -> some View {
        onKeyPress(keys: keys, phases: phases, action: action)
    }

    @available(OpenSwiftUI_v5_0, *)
    @available(*, deprecated, renamed: "onKeyPress(keys:phases:action:)")
    @available(watchOS, unavailable)
    nonisolated public func onKeyPress(
        charactersIn characters: CharacterSet,
        phases: KeyPress.Phases = [.down, .repeat],
        action: @escaping (KeyPress) -> KeyPress.Result
    ) -> some View {
        onKeyPress(characters: characters, phases: phases, action: action)
    }
}

// MARK: - KeyPressModifier

private struct KeyPressModifier: EnvironmentModifier, PrimitiveViewModifier {
    var handler: KeyPress.Handler

    static func makeEnvironment(modifier: Attribute<Self>, environment: inout EnvironmentValues) {
        let handler = modifier.value.handler
        environment.keyPressHandlers.append(handler)
    }
}

extension KeyPress {
    struct Handler {
        enum Subject {
            case keys(Set<KeyEquivalent>)
            case characters(CharacterSet)
            case all
        }

        var subject: Subject
        var phases: Phases
        var action: (KeyPress) -> Result
    }
}

extension EnvironmentValues {
    var keyPressHandlers: [KeyPress.Handler] {
        get { self[KeyPressHandlersKey.self] }
        set { self[KeyPressHandlersKey.self] = newValue }
    }

    private struct KeyPressHandlersKey: EnvironmentKey {
        static var defaultValue: [KeyPress.Handler] { [] }
    }
}

extension CachedEnvironment.ID {
    static let keyPressHandlers: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var keyPressHandlers: Attribute<[KeyPress.Handler]> {
        mapEnvironment(id: .keyPressHandlers) { $0.keyPressHandlers }
    }
}
