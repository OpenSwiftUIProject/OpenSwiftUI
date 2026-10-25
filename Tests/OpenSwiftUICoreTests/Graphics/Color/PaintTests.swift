//
//  PaintTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import Testing

struct PaintTests {
    @Test
    @MainActor
    func prepareTextDoesNotRequireAFallbackColor() {
        let paint = LinearGradient(colors: [], startPoint: .top, endPoint: .bottom)
        var shape = _ShapeStyle_Shape(operation: .prepareText(level: 2))

        paint._apply(to: &shape)

        guard case .preparedText(.foregroundKeyColor) = shape.result else {
            Issue.record("Expected the foreground key color for an empty paint")
            return
        }
    }

    @Test(arguments: [0, 1, 2, 3])
    @MainActor
    func fallbackColorDoesNotApplyLevelOpacity(level: Int) {
        let paint = LinearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
        var shape = _ShapeStyle_Shape(operation: .fallbackColor(level: level))

        paint._apply(to: &shape)

        guard case let .color(color) = shape.result else {
            Issue.record("Expected the original fallback color")
            return
        }
        #expect(color == .red)
    }

    @Test
    @MainActor
    func multiLevelPreservesTheExistingResult() {
        let paint = LinearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
        var shape = _ShapeStyle_Shape(operation: .multiLevel, result: .bool(true))

        paint._apply(to: &shape)

        guard case let .bool(value) = shape.result else {
            Issue.record("Expected the existing result")
            return
        }
        #expect(value)
    }

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
    func anchorFieldsWrapTheCurrentPaintInOrder() throws {
        let color = Color.Resolved(red: 1, green: 0, blue: 0, opacity: 1)
        let data = try ProtobufEncoder.encoding { encoder in
            try encoder.messageField(1, color)
            try encoder.messageField(7, CGRect(x: 2, y: 3, width: -4, height: 5))
            try encoder.messageField(7, CGRect(x: 10, y: 20, width: 30, height: 40))
        }
        var decoder = ProtobufDecoder(data)
        let decoded = try CodableResolvedPaint(from: &decoder)
        let outer = try #require(decoded.base.as(
            type: AnchoredResolvedPaint<AnchoredResolvedPaint<Color.Resolved>>.self
        ))

        #expect(outer.bounds.origin == CGPoint(x: 10, y: 20))
        #expect(outer.bounds.size == CGSize(width: 30, height: 40))
        #expect(outer.paint.bounds.origin == CGPoint(x: 2, y: 3))
        #expect(outer.paint.bounds.size == CGSize(width: -4, height: 5))
        #expect(outer.paint.paint == color)
    }

    @Test
    func aLaterLeafReplacesTheAnchoredPaint() throws {
        let red = Color.Resolved(red: 1, green: 0, blue: 0, opacity: 1)
        let blue = Color.Resolved(red: 0, green: 0, blue: 1, opacity: 1)
        let data = try ProtobufEncoder.encoding { encoder in
            try encoder.messageField(1, red)
            try encoder.messageField(7, CGRect(x: 2, y: 3, width: 4, height: 5))
            try encoder.messageField(1, blue)
        }
        var decoder = ProtobufDecoder(data)
        let decoded = try CodableResolvedPaint(from: &decoder)

        #expect(decoded.base.as(type: Color.Resolved.self) == blue)
        #expect(decoded.base.as(type: AnchoredResolvedPaint<Color.Resolved>.self) == nil)
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
