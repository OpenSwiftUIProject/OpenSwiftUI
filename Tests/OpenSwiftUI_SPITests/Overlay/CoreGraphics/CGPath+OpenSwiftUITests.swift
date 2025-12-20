//
//  CGPath+OpenSwiftUITests.swift
//  OpenSwiftUI_SPITests

import OpenSwiftUI_SPI
import Testing

#if canImport(Darwin)
import CoreGraphics

@Suite
struct CGPath_OpenSwiftUITests {
    // MARK: - _CGPathParseString

    struct ParseString {
        @Test(arguments: [
            // m - move to
            ("100 0 m 200 100 l h", true, " 100 0 m 200 100 l h"),
            // l - line to (multiple)
            ("0 0 m 100 0 l 100 100 l 0 100 l h", true, " 0 0 m 100 0 l 100 100 l 0 100 l h"),
            // q - quad curve
            ("0 0 m 50 0 100 100 q", true, " 0 0 m 50 0 100 100 q"),
            // c - cubic curve
            ("0 0 m 25 0 75 100 100 100 c", true, " 0 0 m 25 0 75 100 100 100 c"),
            // v - smooth cubic (cp1 = last point)
            ("0 0 m 50 50 100 100 v", true, " 0 0 m 0 0 50 50 100 100 c"),
            // y - shorthand cubic (cp2 = endpoint)
            ("0 0 m 25 0 100 100 y", true, " 0 0 m 25 0 100 100 100 100 c"),
            // re - rectangle
            ("10 20 30 40 re", true, " 10 20 m 40 20 l 40 60 l 10 60 l h"),
            // Negative numbers
            ("-10 -20 m 30 40 l", true, " -10 -20 m 30 40 l"),
            // Decimal numbers
            ("0.5 1.5 m 2.5 3.5 l", true, " 0.5 1.5 m 2.5 3.5 l"),
            // Whitespace variants (tab, newline)
            ("0\t0\nm\n100\t100\tl", true, " 0 0 m 100 100 l"),
            // Invalid: unknown command
            ("0 0 z", false, ""),
            // Invalid: wrong number of parameters
            ("0 m", false, ""),
            // Invalid: too many numbers
            ("1 2 3 4 5 6 7 m", false, ""),
        ])
        func parseString(input: String, expectedResult: Bool, expectedString: String) {
            let path = CGMutablePath()
            let result = _CGPathParseString(path, input)
            #expect(result == expectedResult)
            if expectedResult {
                let description = _CGPathCopyDescription(path, 0)
                #expect(description == expectedString)
            }
        }
    }

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

    // MARK: - _CGPathCreateRoundedRect

    struct CreateRoundedRect {
        @Test
        func zeroCornerWidth() {
            let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
            let path = _CGPathCreateRoundedRect(rect, 0, 10, false)
            // Should return a plain rectangle
            #expect(_CGPathCopyDescription(path, 0) == " 0 0 m 100 0 l 100 50 l 0 50 l h")
        }

        @Test
        func zeroCornerHeight() {
            let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
            let path = _CGPathCreateRoundedRect(rect, 10, 0, false)
            // Should return a plain rectangle
            #expect(_CGPathCopyDescription(path, 0) == " 0 0 m 100 0 l 100 50 l 0 50 l h")
        }

        @Test
        func negativeCornerValues() {
            let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
            let path = _CGPathCreateRoundedRect(rect, -5, -5, false)
            // Negative values are clamped to 0, so should return a plain rectangle
            #expect(_CGPathCopyDescription(path, 0) == " 0 0 m 100 0 l 100 50 l 0 50 l h")
        }

        @Test
        func emptyRect() {
            // A rect with zero width or height is considered empty by CGRectIsEmpty
            let rect = CGRect(x: 0, y: 0, width: 0, height: 50)
            let path = _CGPathCreateRoundedRect(rect, 10, 10, false)
            // Empty rect returns a plain rectangle path
            #expect(_CGPathCopyDescription(path, 0) == " 0 0 m 0 0 l 0 50 l 0 50 l h")
        }
    }
}

#endif

