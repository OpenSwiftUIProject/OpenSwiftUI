//
//  CoreFoundationPrivateTests.swift
//  COpenSwiftUICoreTests

import COpenSwiftUICore
import Testing

struct CoreFoundationPrivateTests {
    @Test
    func CFMZEnabled() {
        let result = _CFMZEnabled()
#if canImport(Darwin)
        #if targetEnvironment(macCatalyst)
            #expect(result == true)
        #elseif targetEnvironment(simulator)
            #expect(result == false)
        #else
            #if os(iOS)
            #expect(result == true)
            #else
            #expect(result == false)
            #endif
        #endif
#else
        #expect(result == false)
#endif
    }
}
