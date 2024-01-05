//
//  PreferenceKeyVisitor.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/1/5.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol PreferenceKeyVisitor {
    func visit<Key: PreferenceKey>(key: Key.Type)
}
