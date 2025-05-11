//
//  AppKitPrivateTests.swift
//  OpenSwiftUI_SPITests

import OpenSwiftUI_SPI
import Testing

#if canImport(AppKit)
@MainActor
struct AppKitPrivateTests {
    @Test
    func application() {
        let app = NSApplication.shared
        let name = "ATest"
        app.startedTest(name)
        app.finishedTest(name)
        app.failedTest(name, withFailure: nil)
    }
}
#endif
