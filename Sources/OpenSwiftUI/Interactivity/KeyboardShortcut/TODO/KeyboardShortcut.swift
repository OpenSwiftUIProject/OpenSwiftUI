//
//  KeyboardShortcut.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: Blocked by EnvironmentValues

@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct KeyboardShortcut {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public struct Localization {
        public static let automatic = Localization(style: .automatic)
        public static let withoutMirroring = Localization(style: .withoutMirroring)
        public static let custom = Localization(style: .custom)

        enum Style: Hashable {
            case automatic
            case withoutMirroring
            case custom
        }

        let style: Style
    }

    public static let defaultAction = KeyboardShortcut(.return, modifiers: [])
    public static let cancelAction = KeyboardShortcut(.escape, modifiers: [])
    public var key: KeyEquivalent
    public var modifiers: EventModifiers
    public var localization: Localization
    public init(_ key: KeyEquivalent, modifiers: EventModifiers = .command) {
        self.key = key
        self.modifiers = modifiers
        self.localization = .automatic
    }

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ key: KeyEquivalent, modifiers: EventModifiers = .command, localization: Localization) {
        self.key = key
        self.modifiers = modifiers
        self.localization = localization
    }
}

#if canImport(UIKit)
import UIKit

extension KeyboardShortcut {
    init?(_ command: UIKeyCommand) {
        guard let input = command.input else {
            return nil
        }
        // FIXME:
        let key: KeyEquivalent = switch input {
        default: .escape
        }
        self.init(key, modifiers: .init(command.modifierFlags), localization: .automatic)
    }
}
#endif

// @available(tvOS, unavailable)
// @available(watchOS, unavailable)
// extension View {
//    public func keyboardShortcut(_: KeyEquivalent, modifiers _: EventModifiers = .command) -> some View {}
//
//    public func keyboardShortcut(_: KeyEquivalent, modifiers _: EventModifiers = .command, localization _: KeyboardShortcut.Localization) -> some View {}
//
//    public func keyboardShortcut(_: KeyboardShortcut) -> some View {}
//
//    public func keyboardShortcut(_: KeyboardShortcut?) -> some View {}
// }

// @available(tvOS, unavailable)
// @available(watchOS, unavailable)
// extension EnvironmentValues {
//  public var keyboardShortcut: KeyboardShortcut? {
//    get
//  }
// }

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyboardShortcut: Hashable {
    public static func == (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        lhs.key.character == rhs.key.character &&
            lhs.modifiers == rhs.modifiers &&
            lhs.localization.style == rhs.localization.style
    }

    public func hash(into hasher: inout Hasher) {
        key.character.hash(into: &hasher)
        hasher.combine(modifiers.rawValue)
        hasher.combine(localization.style)
    }
}
