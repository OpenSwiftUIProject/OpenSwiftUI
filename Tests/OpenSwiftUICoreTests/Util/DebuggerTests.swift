//
//  DebuggerTests.swift
//  OpenSwiftUICoreTests
//
//  Audited for 6.5.4
//  Status: Complete
//

import Testing
@testable import OpenSwiftUICore

struct DebuggerTests {
    @Test
    func attached() {
        #expect(isDebuggerAttached == false)
    }
}
