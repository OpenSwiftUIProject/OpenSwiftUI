//
//  AppKitKeyEventConversions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS)
import AppKit
import OpenSwiftUICore

// MARK: - EventModifiers + NSEvent.ModifierFlags

extension EventModifiers {
    init(_ flags: NSEvent.ModifierFlags) {
        var modifiers: EventModifiers = []
        if flags.contains(.capsLock) {
            modifiers.insert(.capsLock)
        }
        if flags.contains(.shift) {
            modifiers.insert(.shift)
        }
        if flags.contains(.control) {
            modifiers.insert(.control)
        }
        if flags.contains(.option) {
            modifiers.insert(.option)
        }
        if flags.contains(.command) {
            modifiers.insert(.command)
        }
        if flags.contains(.numericPad) {
            modifiers.insert(.numericPad)
        }
        if flags.contains(.function) {
            modifiers.insert(._function)
        }
        self = modifiers
    }
}

// MARK: - NSEvent.ModifierFlags + EventModifiers

extension NSEvent.ModifierFlags {
    init(_ modifiers: EventModifiers) {
        self = []
        if modifiers.contains(.capsLock) {
            insert(.capsLock)
        }
        if modifiers.contains(.shift) {
            insert(.shift)
        }
        if modifiers.contains(.control) {
            insert(.control)
        }
        if modifiers.contains(.option) {
            insert(.option)
        }
        if modifiers.contains(.command) {
            insert(.command)
        }
        if modifiers.contains(.numericPad) {
            insert(.numericPad)
        }
        if modifiers.contains(._function) {
            insert(.function)
        }
    }
}
#endif
