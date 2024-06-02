//
//  SemanticsTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import Testing

struct SemanticsTests {
    @Test
    func forced() {
        #if canImport(Darwin)
        if #available(iOS 13, macOS 10.15, *) {
            #expect(Semantics.forced == nil)
        } else {
            #expect(Semantics.forced != nil)
        }
        #else
        #expect(Semantics.forced == nil)
        #endif
    }
    
    @Test
    func compare() {
        #expect(Semantics.v1 < Semantics.v2)
    }
}
