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
    func stringRepresentations() {
        let vendor: ViewRendererVendor = "org.example.Renderer"

        #expect(vendor.rawValue == "org.example.Renderer")
        #expect(vendor.description == "org.example.Renderer")
        #expect("\(ViewRendererVendor.osui)" == "org.OpenSwiftUIProject.OpenSwiftUI")
    }

    @Test
    func activeVendor() {
        #if OPENSWIFTUI_SWIFTUI_RENDERER
        #expect(viewRendererVendor == .sui)
        #else
        #expect(viewRendererVendor == .osui)
        #endif
    }
}
