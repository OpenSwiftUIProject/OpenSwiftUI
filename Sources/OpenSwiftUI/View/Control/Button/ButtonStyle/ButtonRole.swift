//
//  ButtonRole.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

public struct ButtonRole: Equatable, Sendable {
    public static let destructive: ButtonRole = .init(rawValue: 1)
    public static let cancel: ButtonRole = .init(rawValue: 4)
    
    public static func == (a: ButtonRole, b: ButtonRole) -> Bool {
        a.rawValue == b.rawValue
    }
    
    var rawValue: UInt8
}
