//
//  UniqueID.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete

internal import OpenGraphShims

package struct UniqueID: Hashable {
    @inlinable
    package init() {
        value = Int(makeUniqueID())
    }
    
    package static let invalid = UniqueID(value: 0)
    
    let value: Int
    
    private init(value: Int) {
        self.value = value
    }
}
