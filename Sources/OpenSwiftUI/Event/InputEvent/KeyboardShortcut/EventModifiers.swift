//
//  EventModifiers.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

@frozen public struct EventModifiers: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let capsLock = EventModifiers(rawValue: 1) // 0x1
    public static let shift = EventModifiers(rawValue: 1 << 1) // 0x2
    public static let control = EventModifiers(rawValue: 1 << 2) // 0x4
    public static let option = EventModifiers(rawValue: 1 << 3) // 0x8
    public static let command = EventModifiers(rawValue: 1 << 4) // 0x10
    public static let numericPad = EventModifiers(rawValue: 1 << 5) // 0x20
    @available(*, deprecated, message: "Function modifier is reserved for system applications")
    public static let function = EventModifiers(rawValue: 1 << 6) // 0x40
    public static let all = [capsLock, shift, control, option, command, numericPad] // 0x3F
}

extension EventModifiers: Sendable {}

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
