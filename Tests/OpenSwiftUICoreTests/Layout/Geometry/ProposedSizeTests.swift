//
//  ProposedSizeTests.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

@testable import OpenSwiftUICore
import Testing

@Suite
struct ProposedSizeTests {
    @Test
    func unspecified() {
        let size = _ProposedSize.unspecified
        #expect(size.width == nil)
        #expect(size.height == nil)
    }

    @Test
    func hashable() {
        let size1 = _ProposedSize(width: 20, height: 30)
        let size2 = _ProposedSize(width: 30, height: 20)
        #expect(size1 != size2)
        #expect(size1.hashValue != size2.hashValue)
    }
}
