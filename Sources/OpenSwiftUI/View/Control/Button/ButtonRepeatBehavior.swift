//
//  ButtonRepeatBehavior.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - ButtonRepeatBehavior

/// The options for controlling the repeatability of button actions.
///
/// Use values of this type with the ``View/buttonRepeatBehavior(_:)``
/// modifier.
@available(OpenSwiftUI_v5_0, *)
public struct ButtonRepeatBehavior: Hashable, Sendable {
    enum Guts: Hashable, Sendable {
        case automatic
        case enabled
        case disabled
    }

    var guts: Guts

    /// The automatic repeat behavior.
    public static let automatic = ButtonRepeatBehavior(guts: .automatic)

    /// Repeating button actions will be enabled.
    public static let enabled = ButtonRepeatBehavior(guts: .enabled)

    /// Repeating button actions will be disabled.
    public static let disabled = ButtonRepeatBehavior(guts: .disabled)

    struct Key: EnvironmentKey {
        static var defaultValue: ButtonRepeatBehavior { .automatic }
    }

    struct HasCustomRepeatBehavior: ViewInputBoolFlag {}
}

// MARK: - View + ButtonRepeatBehavior

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Sets whether buttons in this view should repeatedly trigger their
    /// actions on prolonged interactions.
    ///
    /// Apply this to buttons that increment or decrement a value or perform
    /// some other inherently iterative operation. Interactions such as
    /// pressing-and-holding on the button, holding the button's keyboard
    /// shortcut, or holding down the space key while the button is focused will
    /// trigger this repeat behavior.
    ///
    ///     Button {
    ///         playbackSpeed.advance(by: 1)
    ///     } label: {
    ///         Label("Speed up", systemImage: "hare")
    ///     }
    ///     .buttonRepeatBehavior(.enabled)
    ///
    /// This affects all system button styles, as well as automatically
    /// affects custom `ButtonStyle` conforming types. This does not
    /// automatically apply to custom `PrimitiveButtonStyle` conforming types,
    /// and the ``EnvironmentValues.buttonRepeatBehavior`` value should be used
    /// to adjust their custom gestures as appropriate.
    ///
    /// - Parameter behavior: A value of `enabled` means that buttons should
    ///   enable repeating behavior and a value of `disabled` means that buttons
    ///   should disallow repeating behavior.
    nonisolated public func buttonRepeatBehavior(_ behavior: ButtonRepeatBehavior) -> some View {
        environment(\.buttonRepeatBehavior, behavior)
            .input(ButtonRepeatBehavior.HasCustomRepeatBehavior.self)
    }
}

// MARK: - EnvironmentValues + ButtonRepeatBehavior

@available(OpenSwiftUI_v5_0, *)
extension EnvironmentValues {
    /// Whether buttons with this associated environment should repeatedly
    /// trigger their actions on prolonged interactions.
    ///
    /// A value of `enabled` means that buttons will be able to repeatedly
    /// trigger their action, and `disabled` means they should not. A value of
    /// `automatic` means that buttons will defer to default behavior.
    public internal(set) var buttonRepeatBehavior: ButtonRepeatBehavior {
        get { self[ButtonRepeatBehavior.Key.self] }
        set { self[ButtonRepeatBehavior.Key.self] = newValue }
    }

    var effectiveButtonRepeatTiming: ButtonRepeatTiming? {
        buttonRepeatBehavior == .enabled ? buttonRepeatTiming : nil
    }
}

// MARK: - ButtonRepeatTiming

@_spi(DoNotImport)
@available(OpenSwiftUI_v5_0, *)
public struct ButtonRepeatTiming: Sendable {
    var entries: [TimingEntry]

    struct TimingEntry: Sendable {
        var step: Int
        var nextInterval: Double
    }

    func makeIterator() -> Iterator {
        Iterator(entries: entries, step: 0)
    }

    struct Iterator: IteratorProtocol {
        var entries: [TimingEntry]
        var step: Int

        mutating func next() -> Double? {
            if entries.count >= 2, step == entries[1].step {
                entries.removeFirst()
            }
            guard let entry = entries.first else { return nil }
            step += 1
            return entry.nextInterval
        }
    }

    struct Key: EnvironmentKey {
        static var defaultValue: ButtonRepeatTiming {
            #if os(iOS) || os(visionOS)
            ButtonRepeatTiming(entries: [
                TimingEntry(step: 0, nextInterval: 0.5),
                TimingEntry(step: 5, nextInterval: 0.1),
                TimingEntry(step: 20, nextInterval: 0.05),
            ])
            #elseif os(macOS)
            ButtonRepeatTiming(entries: [
                TimingEntry(step: 0, nextInterval: 0.4),
                TimingEntry(step: 1, nextInterval: 0.075),
            ])
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }
}

@_spi(DoNotImport)
@available(OpenSwiftUI_v5_0, *)
extension EnvironmentValues {
    public var buttonRepeatTiming: ButtonRepeatTiming {
        get { self[ButtonRepeatTiming.Key.self] }
        set { self[ButtonRepeatTiming.Key.self] = newValue }
    }
}
