//
//  UniqueID.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import OpenGraphShims

struct UniqueID: Hashable {
    static let zero = UniqueID(value: 0)

    let value: Int

    @inline(__always)
    init() {
        value = Int(makeUniqueID())
    }

    private init(value: Int) {
        self.value = value
    }
}
