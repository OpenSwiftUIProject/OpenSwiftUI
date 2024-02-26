//
//  HostPreferenceKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol HostPreferenceKey: PreferenceKey {}

extension HostPreferenceKey {
    static var _isReadableByHost: Bool { true }
}
