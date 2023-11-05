//
//  EnvironmentValues+controlSize.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/5.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: 50E368DED9ACE8B6BEC08FF7781AF4B1

private struct ControlSizeKey: EnvironmentKey {
    static let defaultValue: ControlSize = .regular
}

extension EnvironmentValues {
    @inline(__always)
    public var controlSize: ControlSize {
        get { self[ControlSizeKey.self] }
        set { self[ControlSizeKey.self] = newValue }
    }
}
