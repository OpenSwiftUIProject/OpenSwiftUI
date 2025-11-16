//
//  KDebugPrivateTests.swift
//  OpenSwiftUI_SPITests

import kdebug_Private
import Testing

#if canImport(Darwin)
struct KDebugPrivateTests {
    @Test
    func enable() {
        #expect(kdebug_is_enabled(0) == false)
    }
}
#endif
