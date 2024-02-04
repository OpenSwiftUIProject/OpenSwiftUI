//
//  HostPreferencesKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/1/6.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: 7429200566949B8FB892A77E01A988C8

struct HostPreferencesKey: PreferenceKey {
    private static var nodeId: UInt32 = .zero
    
    @inline(__always)
    static func makeNodeID() -> UInt32 {
        defer { nodeId &+= 1 }
        return nodeId
    }
}
