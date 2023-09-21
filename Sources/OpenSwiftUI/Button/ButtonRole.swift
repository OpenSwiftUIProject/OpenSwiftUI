//
//  ButtonRole.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: Complete

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ButtonRole: Equatable, Sendable {
    public static let destructive: ButtonRole = .init(rawValue: 1)
    public static let cancel: ButtonRole = .init(rawValue: 4)
    
    public static func == (a: ButtonRole, b: ButtonRole) -> Bool {
        a.rawValue == b.rawValue
    }
    
    var rawValue: UInt8
}
