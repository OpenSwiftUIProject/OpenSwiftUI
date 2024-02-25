//
//  GraphDelegate.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/2/26.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol GraphDelegate: AnyObject {
    func updateGraph<V>(body: (GraphHost) -> V) -> V
    func graphDidChange()
    func preferencesDidChange()
}
