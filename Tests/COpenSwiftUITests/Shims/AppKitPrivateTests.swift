//
//  AppKitPrivateTests.swift
//  OpenSwiftUI_SPITests

#if canImport(AppKit)
import AppKit
import COpenSwiftUI
import Testing

@MainActor
struct AppKitPrivateTests {
    @Test
    func application() {
        let app = NSApplication.shared
        let name = "ATest"
        app.startedTest(name)
        app.finishedTest(name, extraResults: nil)
        app.failedTest(name, withFailure: nil)
    }
}
#endif
