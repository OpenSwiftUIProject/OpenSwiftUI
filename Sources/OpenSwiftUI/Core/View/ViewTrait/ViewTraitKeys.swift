//
//  ViewTraitKeys.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

struct ViewTraitKeys {
    var types: Set<ObjectIdentifier>
    var isDataDependent: Bool
    
    mutating func insert<Key: _ViewTraitKey>(_ type: Key.Type) {
        types.insert(ObjectIdentifier(type))
    }
    
    func contains<Key: _ViewTraitKey>(_ type: Key.Type) -> Bool {
        types.contains(ObjectIdentifier(type))
    }
}
