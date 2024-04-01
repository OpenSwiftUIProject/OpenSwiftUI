//
//  HostPreferencesKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 7429200566949B8FB892A77E01A988C8

struct HostPreferencesKey: PreferenceKey {
    static var defaultValue: PreferenceList {
        PreferenceList()
    }
    
    static func reduce(value: inout PreferenceList, nextValue: () -> PreferenceList) {
        value.merge(nextValue())
    }
}

extension HostPreferencesKey {
    private static var nodeId: UInt32 = .zero

    @inline(__always)
    static func makeNodeID() -> UInt32 {
        defer { nodeId &+= 1 }
        return nodeId
    }
}
