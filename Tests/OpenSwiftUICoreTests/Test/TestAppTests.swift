//
//  TestAppTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenAttributeGraphShims
import Testing

@MainActor
struct TestAppTests {
    @Test
    func Intents() {
        _TestApp.setIntents([.ignoreDisabled, .ignoreTinting])
        #expect(_TestApp.isIntending(to: []) == false)
        #expect(_TestApp.isIntending(to: [.ignoreGeometry]) == false)
        #expect(_TestApp.isIntending(to: [.ignoreDisabled]) == true)
        #expect(_TestApp.isIntending(to: [.ignoreTinting]) == true)
        #expect(_TestApp.isIntending(to: [.ignoreDisabled, .ignoreTinting]) == true)
        #expect(_TestApp.isIntending(to: [.ignoreDisabled, .ignoreTinting, .ignoreHoverEffects]) == true)
    }
}
