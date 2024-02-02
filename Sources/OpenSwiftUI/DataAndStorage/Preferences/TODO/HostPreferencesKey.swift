//
//  HostPreferencesKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/1/6.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 7429200566949B8FB892A77E01A988C8

struct HostPreferencesKey: PreferenceKey {
    static var defaultValue: PreferenceList {
        PreferenceList()
    }
    
    static func reduce(value: inout PreferenceList, nextValue: () -> PreferenceList) {
        // TODO:
    }
    
    private static var nodeId: UInt32 = .zero
}
