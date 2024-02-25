//
//  DynamicPropertyBehaviors.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/1/6.
//  Lastest Version: iOS 15.5
//  Status: Complete

struct DynamicPropertyBehaviors: OptionSet {
    let rawValue: UInt32
    static var asyncThread: DynamicPropertyBehaviors { .init(rawValue: 1 << 0) }
}
