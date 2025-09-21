//
//  DebuggerTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct DebuggerTests {
    @Test
    func attached() {
        #expect(isDebuggerAttached == false)
    }
}
