//
//  BlurStyleTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

struct BlurStyleTests {
    @Test
    func blurStyleInit() {
        let style = BlurStyle(radius: 10, isOpaque: true, dither: true)
        #expect(style.radius == 10)
        #expect(style.isOpaque == true)
        #expect(style.dither == true)
    }
    
    @Test
    func blurStyleIsIdentity() {
        let style1 = BlurStyle(radius: 0)
        #expect(style1.isIdentity == true)
        
        let style2 = BlurStyle(radius: -5)
        #expect(style2.isIdentity == true)
        
        let style3 = BlurStyle(radius: 10)
        #expect(style3.isIdentity == false)
    }
    
    @Test
    func blurStyleEquality() {
        let style1 = BlurStyle(radius: 10, isOpaque: true, dither: false)
        let style2 = BlurStyle(radius: 10, isOpaque: true, dither: false)
        let style3 = BlurStyle(radius: 10, isOpaque: false, dither: false)
        
        #expect(style1 == style2)
        #expect(style1 != style3)
    }
    
    @Test
    func blurStyleAnimatableData() {
        var style = BlurStyle(radius: 10)
        #expect(style.animatableData.isApproximatelyEqual(to: 10))
        
        style.animatableData = 20
        #expect(style.radius.isApproximatelyEqual(to: 20))
    }
    
    // MARK: - ProtobufMessage Tests
    
    @Test(
        arguments: [
            (BlurStyle(), ""),
            (BlurStyle(radius: 10.0), "0d00002041"),
            (BlurStyle(radius: 10.0, isOpaque: true), "0d000020411001"),
            (BlurStyle(radius: 10.0, isOpaque: true, dither: true), "0d0000204110011801"),
            (BlurStyle(radius: 10.0, isOpaque: false, dither: true), "0d000020411801"),
        ]
    )
    func pbMessage(style: BlurStyle, hexString: String) throws {
        try style.testPBEncoding(hexString: hexString)
        try style.testPBDecoding(hexString: hexString)
    }
}
