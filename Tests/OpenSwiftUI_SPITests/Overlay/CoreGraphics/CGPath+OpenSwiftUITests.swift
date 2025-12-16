//
//  CGPath+OpenSwiftUITests.swift
//  OpenSwiftUI_SPITests

import OpenSwiftUI_SPI
import Testing

#if canImport(Darwin)
import CoreGraphics

@Suite
struct CGPath_OpenSwiftUITests {
    // MARK: - _CGPathCopyDescription

    struct CopyDescription {
        @Test(arguments: [
            (1.0, " 100 0 m 190 190 l 0 190 l h"),
            (2.0, " 100 0 m 190 190 l 0 190 l h"),
            (3.0, " 99 0 m 189 189 l 0 189 l h"),
            (4.0, " 100 0 m 188 188 l 0 188 l h"),
        ])
        func copyDescription(step: Double, expected: String) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 100, y: 0))
            path.addLine(to: CGPoint(x: 189.5, y: 189.5))
            path.addLine(to: CGPoint(x: 0, y: 189.5))
            path.closeSubpath()
            let description = _CGPathCopyDescription(path, step)
            #expect(description == expected)
        }

        @Test
        func copyDescriptionWithQuadCurve() {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: 100, y: 100), control: CGPoint(x: 50, y: 0))
            let description = _CGPathCopyDescription(path, 1)
            #expect(description == " 0 0 m 50 0 100 100 q")
        }

        @Test
        func copyDescriptionWithCubicCurve() {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addCurve(to: CGPoint(x: 100, y: 100), control1: CGPoint(x: 25, y: 0), control2: CGPoint(x: 75, y: 100))
            let description = _CGPathCopyDescription(path, 1)
            #expect(description == " 0 0 m 25 0 75 100 100 100 c")
        }
    }
}

#endif

