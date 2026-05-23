//
//  ViewRendererVendorTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct ViewRendererVendorTests {
    @Test
    func cases() {
        #expect(ViewRendererVendor.osui.rawValue == "org.OpenSwiftUIProject.OpenSwiftUI")
        #expect(ViewRendererVendor.sui.rawValue == "com.apple.SwiftUI")
        #expect(ViewRendererVendor.allCases == [.osui, .sui])
    }

    @Test
    func activeVendor() {
        #if canImport(SwiftUI, _underlyingVersion: 6.5.4) && OPENSWIFTUI_SWIFTUI_RENDER
        #expect(viewRendererVendor == .sui)
        #else
        #expect(viewRendererVendor == .osui)
        #endif
    }
}
