//
//  CoreAnimationPrivateTests.swift
//  OpenSwiftUI_SPITests

import OpenSwiftUI_SPI
import Testing

#if canImport(QuartzCore)
@MainActor
struct CoreAnimationPrivateTests {
    @Test
    func layer() {
        let layer = CALayer()
        #expect(layer.hasBeenCommitted == false)

        #expect(layer.allowsGroupBlending == true)
        layer.allowsGroupBlending = false
        #expect(layer.allowsGroupBlending == false)
        layer.allowsGroupBlending = true
        #expect(layer.allowsGroupBlending == true)

        #expect(layer.openSwiftUI_viewTestProperties == 0)
        layer.openSwiftUI_viewTestProperties = 42
        #expect(layer.openSwiftUI_viewTestProperties == 42)
    }
}
#endif
