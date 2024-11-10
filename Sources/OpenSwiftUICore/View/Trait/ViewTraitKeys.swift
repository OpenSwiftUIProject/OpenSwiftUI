//
//  ViewTraitKeys.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

package struct ViewTraitKeys {
    package var types: Set<ObjectIdentifier>
    package var isDataDependent: Bool
    
    package init() {
        types = []
        isDataDependent = false
    }
    
    package func contains<T>(_ type: T.Type) -> Bool where T: _ViewTraitKey{
        types.contains(ObjectIdentifier(type))
    }
    
    package mutating func insert<T>(_ type: T.Type) where T: _ViewTraitKey {
        types.insert(ObjectIdentifier(type))
    }
    
    package mutating func formUnion(_ other: ViewTraitKeys) {
        types.formUnion(other.types)
        isDataDependent = isDataDependent || other.isDataDependent
    }

    package func withDataDependent() -> ViewTraitKeys {
        var copy = self
        copy.isDataDependent = true
        return copy
    }
}
