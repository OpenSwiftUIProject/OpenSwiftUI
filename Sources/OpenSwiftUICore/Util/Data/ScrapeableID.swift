//
//  ScrapeableID.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

import OpenGraphShims

package struct ScrapeableID: Hashable {

    @inlinable
    package init() {
        value = numericCast(makeUniqueID())
    }

    package static let none = ScrapeableID(value: 0)

    let value: UInt32

    private init(value: UInt32) {
        self.value = value
    }
}
