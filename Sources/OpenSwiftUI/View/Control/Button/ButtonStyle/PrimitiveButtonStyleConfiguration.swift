//
//  PrimitiveButtonStyleConfiguration.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

public struct PrimitiveButtonStyleConfiguration {
    public struct Label: ViewAlias {
        public typealias Body = Never
        
        package init() {}
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
