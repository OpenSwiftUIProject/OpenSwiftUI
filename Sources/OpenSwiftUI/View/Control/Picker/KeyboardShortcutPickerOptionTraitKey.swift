//
//  KeyboardShortcutPickerContent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import OpenSwiftUICore

// TODO: _KeyboardShortcutPickerContent

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    @inlinable
    nonisolated public func pickerKeyboardShortcut(
        _ shortcut: KeyboardShortcut?
    ) -> some View {
        _trait(KeyboardShortcutPickerOptionTraitKey.self, shortcut)
    }

    nonisolated public func pickerKeyboardShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command
    ) -> some View {
        _trait(KeyboardShortcutPickerOptionTraitKey.self, .init(key, modifiers: modifiers))
    }

    nonisolated public func pickerKeyboardShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command,
        localization: KeyboardShortcut.Localization
    ) -> some View {
        _trait(KeyboardShortcutPickerOptionTraitKey.self, .init(key, modifiers: modifiers, localization: localization))
    }
}

// MARK: - KeyboardShortcutPickerOptionTraitKey

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@usableFromInline
struct KeyboardShortcutPickerOptionTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: KeyboardShortcut? { nil }
}

@available(*, unavailable)
extension KeyboardShortcutPickerOptionTraitKey: Sendable {}
