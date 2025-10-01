//
//  UniqueID.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

import OpenAttributeGraphShims

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
