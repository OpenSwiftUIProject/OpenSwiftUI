//
//  HostPreferenceKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/1/5.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol HostPreferenceKey: PreferenceKey {}

extension HostPreferenceKey {
    static var _isReadableByHost: Bool { true }
}
