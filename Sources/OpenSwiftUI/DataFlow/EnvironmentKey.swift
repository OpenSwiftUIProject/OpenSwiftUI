//
//  EnvironmentKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/25.
//  Lastest Version: iOS 15.5
//  Status: Complete

public protocol EnvironmentKey {
    associatedtype Value

    static var defaultValue: Value { get }
}
