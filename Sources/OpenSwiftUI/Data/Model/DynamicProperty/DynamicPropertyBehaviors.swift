//
//  DynamicPropertyBehaviors.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

struct DynamicPropertyBehaviors: OptionSet {
    let rawValue: UInt32
    static var asyncThread: DynamicPropertyBehaviors { .init(rawValue: 1 << 0) }
}
