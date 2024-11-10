//
//  UniqueID.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

import OpenGraphShims

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
