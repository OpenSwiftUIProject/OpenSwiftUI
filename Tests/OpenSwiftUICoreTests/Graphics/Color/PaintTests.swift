//
//  PaintTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing
import Foundation

struct PaintTests {
    @Test
    func anyResolvedPaintEquality() {
        let color1 = Color.Resolved(red: 1, green: 0, blue: 0, opacity: 1)
        let color2 = Color.Resolved(red: 1, green: 0, blue: 0, opacity: 1)
        let color3 = Color.Resolved(red: 0, green: 1, blue: 0, opacity: 1)
        
        let paint1 = _AnyResolvedPaint(color1)
        let paint2 = _AnyResolvedPaint(color2)
        let paint3 = _AnyResolvedPaint(color3)
        
        #expect(paint1 == paint2)
        #expect(paint1 != paint3)
    }
    
    @Test
    func resolvedPaintProperties() {
        // Test with a clear color
        let clearColor = Color.Resolved(red: 0, green: 0, blue: 0, opacity: 0)
        let clearPaint = _AnyResolvedPaint(clearColor)
        
        #expect(clearPaint.isClear == true)
        #expect(clearPaint.isOpaque == false)
        #expect(clearPaint.resolvedGradient == nil)
        #expect(clearPaint.isCALayerCompatible == true)
        
        // Test with an opaque color
        let opaqueColor = Color.Resolved(red: 1, green: 1, blue: 1, opacity: 1)
        let opaquePaint = _AnyResolvedPaint(opaqueColor)
        
        #expect(opaquePaint.isClear == false)
        #expect(opaquePaint.isOpaque == true)
        #expect(opaquePaint.resolvedGradient == nil)
        #expect(opaquePaint.isCALayerCompatible == true)
    }
    
    @Test
    func codableResolvedPaintEncoding() throws {
        let color = Color.Resolved(red: 1, green: 0, blue: 0, opacity: 1)
        let paint = _AnyResolvedPaint(color)
        let codablePaint = CodableResolvedPaint(paint)
        
        var encoder = ProtobufEncoder()
        try codablePaint.encode(to: &encoder)
        
        let data = try ProtobufEncoder.encoding { encoder in
            try codablePaint.encode(to: &encoder)
        }
        #expect(data.hexString == "0a0a0d0000803f250000803f")
    }
    
    @Test
    func codableResolvedPaintDecoding() throws {
        // Create encoded data for a red color
        let color = Color.Resolved(red: 1, green: 0, blue: 0, opacity: 1)
        let paint = _AnyResolvedPaint(color)
        let originalCodablePaint = CodableResolvedPaint(paint)
        
        let data = try #require(Data(hexString: "0a0a0d0000803f250000803f"))
        var decoder = ProtobufDecoder(data)
        let decodedPaint = try CodableResolvedPaint(from: &decoder)
        
        #expect(originalCodablePaint.base == decodedPaint.base)
    }
    
    @Test
    func resolvedPaintVisitor() {
        struct TestVisitor: ResolvedPaintVisitor {
            var visitedColor: Color.Resolved?
            
            mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
                if let colorPaint = paint as? Color.Resolved {
                    visitedColor = colorPaint
                }
            }
        }
        
        let color = Color.Resolved(red: 1, green: 0, blue: 0, opacity: 1)
        let paint = _AnyResolvedPaint(color)
        
        var visitor = TestVisitor()
        paint.visit(&visitor)
        
        #expect(visitor.visitedColor == color)
    }
}
