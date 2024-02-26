//
//  GraphDelegate.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol GraphDelegate: AnyObject {
    func updateGraph<V>(body: (GraphHost) -> V) -> V
    func graphDidChange()
    func preferencesDidChange()
}
