//
//  UIKitKeyEventConversions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: C0435D26A46CC4134885F98D04935E98

#if os(iOS) || os(visionOS)

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIPress + KeyEventProvider

extension UIPress: KeyEventProvider {
    func resolve(phase: EventPhase) -> KeyEvent? {
        guard let key else {
            return nil
        }
        func keyEquivalentString(_ input: String) -> String {
            guard let keyEquivalent = keyInputToKeyEquivalentMap[input] else {
                return input
            }
            return String(keyEquivalent)
        }
        return KeyEvent(
            phase: phase,
            timestamp: Time(seconds: timestamp),
            modifiers: EventModifiers(key.modifierFlags),
            keys: keyEquivalentString(key.charactersIgnoringModifiers),
            stringValue: keyEquivalentString(key.characters),
            keyID: AnyHashable(key.keyCode)
        )
    }
}

// MARK: - EventModifiers + UIKeyModifierFlags

extension EventModifiers {
    init(_ flags: UIKeyModifierFlags) {
        var modifiers: EventModifiers = []
        if flags.contains(.alphaShift) {
            modifiers.insert(.capsLock)
        }
        if flags.contains(.shift) {
            modifiers.insert(.shift)
        }
        if flags.contains(.control) {
            modifiers.insert(.control)
        }
        if flags.contains(.alternate) {
            modifiers.insert(.option)
        }
        if flags.contains(.command) {
            modifiers.insert(.command)
        }
        if flags.contains(.numericPad) {
            modifiers.insert(.numericPad)
        }
        self = modifiers
    }
}

// MARK: - KeyboardShortcut + UIKeyCommand

extension KeyboardShortcut {
    init?(_ command: UIKeyCommand) {
        guard let input = command.input, !input.isEmpty else {
            return nil
        }
        let key = KeyEquivalent(keyInputToKeyEquivalentMap[input] ?? Character(input))
        self.init(key, modifiers: .init(command.modifierFlags), localization: .automatic)
    }
}

// MARK: - KeyboardShortcut + UIKeyCommand [WIP]

extension UIKeyCommand {
    convenience init(_ binding: KeyboardShortcutBinding) {
        _ = keyEquivalentToKeyInputMap
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - Key Input Conversion

private let keyInputToKeyEquivalentMap: [String: Character] = [
    UIKeyCommand.inputUpArrow: "\u{F700}",
    UIKeyCommand.inputDownArrow: "\u{F701}",
    UIKeyCommand.inputLeftArrow: "\u{F702}",
    UIKeyCommand.inputRightArrow: "\u{F703}",
    UIKeyCommand.inputEscape: "\u{001B}",
    UIKeyCommand.inputDelete: "\u{0008}",
    UIKeyCommand.inputPageUp: "\u{F72C}",
    UIKeyCommand.inputPageDown: "\u{F72D}",
    UIKeyCommand.inputHome: "\u{F729}",
    UIKeyCommand.inputEnd: "\u{F72B}",
    UIKeyCommand.f1: "\u{F704}",
    UIKeyCommand.f2: "\u{F705}",
    UIKeyCommand.f3: "\u{F706}",
    UIKeyCommand.f4: "\u{F707}",
    UIKeyCommand.f5: "\u{F708}",
    UIKeyCommand.f6: "\u{F709}",
    UIKeyCommand.f7: "\u{F70A}",
    UIKeyCommand.f8: "\u{F70B}",
    UIKeyCommand.f9: "\u{F70C}",
    UIKeyCommand.f10: "\u{F70D}",
    UIKeyCommand.f11: "\u{F70E}",
    UIKeyCommand.f12: "\u{F70F}",
]

private let keyEquivalentToKeyInputMap: [Character: String] = keyInputToKeyEquivalentMap.reduce(into: [:]) { result, pair in
    result[pair.value] = pair.key
}
#endif
