//
//  AnyPreferenceKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/1/5.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol AnyPreferenceKey {
    static var valueType: Any.Type { get }
    static func visitKey<Visitor: PreferenceKeyVisitor>(_ visitor: inout Visitor)
}

struct _AnyPreferenceKey<Key: PreferenceKey>: AnyPreferenceKey {
    static var valueType: Any.Type { Key.self }
    
    static func visitKey<Visitor>(_ visitor: inout Visitor) where Visitor : PreferenceKeyVisitor {
        visitor.visit(key: Key.self)
    }
}
