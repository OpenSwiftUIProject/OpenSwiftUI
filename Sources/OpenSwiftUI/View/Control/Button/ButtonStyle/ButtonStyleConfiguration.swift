//
//  ButtonStyleConfiguration.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

public struct ButtonStyleConfiguration {
    public struct Label: ViewAlias {
        public typealias Body = Never
    }

    // 0x0 - 2 Byte
    public let role: ButtonRole?

    // 0 Bit
    public let label: Label

    // 0x2 - 1 Bit
    public let isPressed: Bool

    @inline(__always)
    init(isPressed: Bool, role: ButtonRole?) {
        self.label = Label()
        self.isPressed = isPressed
        self.role = role
    }
}
