//
//  OpenSwiftUIGlueTests.swift
//  OpenSwiftUITests

import Testing
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - OpenSwiftUIGlue

struct OpenSwiftUIGlueTests {
    @Test
    func sharedInstance() {
        #expect(CoreGlue.shared is OpenSwiftUIGlue)
    }
}

// MARK: - OpenSwiftUIGlue2

struct OpenSwiftUIGlue2Tests {
    @Test
    func sharedInstance() {
        #expect(CoreGlue2.shared is OpenSwiftUIGlue2)
    }
}
