//
//  AnyPreferenceKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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
