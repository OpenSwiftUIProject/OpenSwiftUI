//
//  UniqueID.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/8.
//  Lastest Version: iOS 15.5
//  Status: Complete

#if OPENSWIFTUI_ATTRIBUTEGRAPH
internal import AttributeGraph
#else
internal import OpenGraph
#endif

struct UniqueID: Hashable {
    static let zero = UniqueID(value: 0)

    let value: Int

    @inline(__always)
    init() {
        #if OPENSWIFTUI_ATTRIBUTEGRAPH
        self.value = Int(AGMakeUniqueID())
        #else
        self.value = Int(OGMakeUniqueID())
        #endif
    }

    private init(value: Int) {
        self.value = value
    }
}
