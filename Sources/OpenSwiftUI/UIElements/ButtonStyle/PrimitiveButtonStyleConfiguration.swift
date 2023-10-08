//
//  PrimitiveButtonStyleConfiguration.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: Complete

public struct PrimitiveButtonStyleConfiguration {
    public struct Label: ViewAlias {
        public typealias Body = Never
    }

    // 0x0 - 2 Byte
    public let role: ButtonRole?

    // 0 Bit
    public let label: Label

    public func trigger() {
        action()
    }

    // 0x8
    @inline(__always)
    let action: () -> Void

    @inline(__always)
    init(role: ButtonRole?, action: @escaping () -> Void) {
        self.label = Label()
        self.action = action
        self.role = role
    }
}
