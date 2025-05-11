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
        layer.setAllowsEdgeAntialiasing(true)
        layer.setAllowsGroupOpacity(true)
        layer.setAllowsGroupBlending(true)
        
        layer.openSwiftUI_viewTestProperties = 42
        #expect(layer.openSwiftUI_viewTestProperties == 42)
    }
}
#endif
