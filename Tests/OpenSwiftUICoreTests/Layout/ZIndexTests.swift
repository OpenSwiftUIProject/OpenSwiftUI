//
//  ZIndexTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

@MainActor
struct ZIndexTests {
    @Test
    func traitCollectionZIndex() {
        var collection = ViewTraitCollection()
        #expect(collection.zIndex.isApproximatelyEqual(to: 0.0))
        collection.zIndex = 1.5
        #expect(collection.zIndex.isApproximatelyEqual(to: 1.5))
    }
}
