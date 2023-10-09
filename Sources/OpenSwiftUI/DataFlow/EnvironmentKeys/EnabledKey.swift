//
//  EnabledKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/9.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: 6C7FC77DDFF6AC5E011A44B5658DAD66

private struct EnabledKey: EnvironmentKey {
    static var defaultValue: Bool { true }
}

extension EnvironmentValues {
    @inline(__always)
    public var isEnabled: Bool {
        get { self[EnabledKey.self] }
        set { self[EnabledKey.self] = newValue }
    }
}
