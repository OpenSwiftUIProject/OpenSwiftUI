//
//  CoreSystemUtilsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUI_SPI
import Testing

struct CoreSystemUtilsTests {
    @Test
    func frameworkConditionCheck() {
        #if targetEnvironment(macCatalyst)
        #expect(isCatalyst() == true)
        #expect(isUIKitBased() == true)
        #expect(isAppKitBased() == false)
        #expect(CoreSystem.default == .uiKit)
        #elseif os(macOS)
        #expect(isCatalyst() == false)
        #expect(isUIKitBased() == false)
        #expect(isAppKitBased() == true)
        #expect(CoreSystem.default == .appKit)
        #elseif os(iOS) || os(visionOS)
        #expect(isCatalyst() == false)
        #expect(isUIKitBased() == true)
        #expect(isAppKitBased() == false)
        #expect(CoreSystem.default == .uiKit)
        #else
        #expect(isCatalyst() == false)
        #expect(isUIKitBased() == false)
        #expect(isAppKitBased() == false)
        #expect(CoreSystem.default == .unknown)
        #endif
    }
}
