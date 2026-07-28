//
//  EventModifiers.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

import OpenSwiftUICore

#if os(iOS) || os(visionOS) || os(tvOS)
import UIKit

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
#endif
