//
//  VariableBlurStyleTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

struct VariableBlurStyleTests {
    @Test
    func variableBlurStyleInit() {
        let style = VariableBlurStyle(radius: 10, isOpaque: true, dither: true, mask: .none)
        #expect(style.radius == 10)
        #expect(style.isOpaque == true)
        #expect(style.dither == true)
        #expect(style.mask == .none)
    }
    
    @Test
    func variableBlurStyleIsIdentity() {
        let style1 = VariableBlurStyle(radius: 0)
        #expect(style1.isIdentity == true)
        
        let style2 = VariableBlurStyle(radius: -5)
        #expect(style2.isIdentity == true)
        
        let style3 = VariableBlurStyle(radius: 10, mask: .none)
        #expect(style3.isIdentity == true)
        
        let style4 = VariableBlurStyle(radius: 10, mask: .image(GraphicsImage()))
        #expect(style4.isIdentity == false)
    }
    
    @Test
    func variableBlurStyleEquality() {
        let style1 = VariableBlurStyle(radius: 10, isOpaque: true, dither: false, mask: .none)
        let style2 = VariableBlurStyle(radius: 10, isOpaque: true, dither: false, mask: .none)
        let style3 = VariableBlurStyle(radius: 10, isOpaque: false, dither: false, mask: .none)
        
        #expect(style1 == style2)
        #expect(style1 != style3)
    }
    
    @Test
    func variableBlurStyleAnimatableData() {
        var style = VariableBlurStyle(radius: 10)
        #expect(style.animatableData.isApproximatelyEqual(to: 10))
        
        style.animatableData = 20
        #expect(style.radius.isApproximatelyEqual(to: 20))
    }
    
    @Test
    func variableBlurStyleCAFilterRadius() {
        var style = VariableBlurStyle(radius: 10)
        #expect(style.caFilterRadius.isApproximatelyEqual(to: 5))
        
        style.caFilterRadius = 10
        #expect(style.radius.isApproximatelyEqual(to: 20))
    }
    
    @Test
    func variableBlurStyleMaskEquality() {
        let mask1 = VariableBlurStyle.Mask.none
        let mask2 = VariableBlurStyle.Mask.none
        let mask3 = VariableBlurStyle.Mask.image(GraphicsImage())
        let mask4 = VariableBlurStyle.Mask.image(GraphicsImage())
        
        #expect(mask1 == mask2)
        #expect(mask3 == mask4)
        #expect(mask1 != mask3)
    }
    
    // MARK: - ProtobufMessage Tests
    
    @Test(
        arguments: [
            (VariableBlurStyle(), "2200"),
            (VariableBlurStyle(radius: 10.0), "0d000020412200"),
            (VariableBlurStyle(radius: 10.0, isOpaque: true), "0d0000204110012200"),
            (VariableBlurStyle(radius: 10.0, isOpaque: true, dither: true), "0d00002041100118012200"),
            (VariableBlurStyle(radius: 10.0, isOpaque: false, dither: true, mask: .none), "0d0000204118012200"),
            (VariableBlurStyle(radius: 10.0, mask: .image(GraphicsImage())), "0d0000204122020a00"),
        ]
    )
    func pbMessage(style: VariableBlurStyle, hexString: String) throws {
        try style.testPBEncoding(hexString: hexString)
        try style.testPBDecoding(hexString: hexString)
    }
    
    @Test(
        arguments: [
            (VariableBlurStyle.Mask.none, ""),
            (VariableBlurStyle.Mask.image(GraphicsImage()), "0a00"),
        ]
    )
    func maskPBMessage(mask: VariableBlurStyle.Mask, hexString: String) throws {
        try mask.testPBEncoding(hexString: hexString)
        try mask.testPBDecoding(hexString: hexString)
    }
}
