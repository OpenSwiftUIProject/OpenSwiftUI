//
//  UniqueID.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/8.
//  Lastest Version: iOS 15.5
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
