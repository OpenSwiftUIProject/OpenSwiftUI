//
//  PreferenceKeyVisitor.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol PreferenceKeyVisitor {
    mutating func visit<Key: PreferenceKey>(key: Key.Type)
}
