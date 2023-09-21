//
//  ButtonStyle.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: Complete

public struct ButtonStyleConfiguration {
    public struct Label: ViewAlias {
        public typealias Body = Never
    }

    public let role: ButtonRole?

    public let label: ButtonStyleConfiguration.Label

    public let isPressed: Bool

    @inline(__always)
    init(isPressed: Bool, role: ButtonRole?) {
        self.label = Label()
        self.isPressed = isPressed
        self.role = role
    }
}
