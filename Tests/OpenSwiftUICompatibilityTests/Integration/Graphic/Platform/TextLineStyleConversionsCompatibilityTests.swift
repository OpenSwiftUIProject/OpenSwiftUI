//
//  TextLineStyleConversionsCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import OpenSwiftUITestsSupport
import OpenSwiftUI_SPI

@MainActor
struct TextLineStyleConversionsCompatibilityTests {
    @Test(arguments: [
        (.single, Text.LineStyle(pattern: .solid)),
        (NSUnderlineStyle([.single, .patternDot]), Text.LineStyle(pattern: .dot)),
        (NSUnderlineStyle([.single, .patternDash]), Text.LineStyle(pattern: .dash)),
        (NSUnderlineStyle([.single, .patternDashDot]), Text.LineStyle(pattern: .dashDot)),
        (NSUnderlineStyle([.single, .patternDashDotDot]), Text.LineStyle(pattern: .dashDotDot)),
        (.thick, nil),
        (.double, nil),
        (.byWord, nil),
        (NSUnderlineStyle([]), nil),
        (NSUnderlineStyle([.single, .thick]), nil),
        (NSUnderlineStyle([.single, .byWord]), nil),
        (NSUnderlineStyle([.single, .patternDot, .thick]), nil),
    ] as [(NSUnderlineStyle, Text.LineStyle?)])
    func nsUnderlineStyleToLineStyle(
        _ nsUnderlineStyle: NSUnderlineStyle,
        _ expectedLineStyle: Text.LineStyle?
    ) throws {
        let lineStyle = Text.LineStyle(nsUnderlineStyle: nsUnderlineStyle)
        #expect(lineStyle == expectedLineStyle)
    }

    @Test(arguments: [
        (Text.LineStyle(pattern: .solid, color: .red), .single), // Add color to avoid issue with single
        (Text.LineStyle(pattern: .dot), NSUnderlineStyle([.single, .patternDot])),
        (Text.LineStyle(pattern: .dash), NSUnderlineStyle([.single, .patternDash])),
        (Text.LineStyle(pattern: .dashDot), NSUnderlineStyle([.single, .patternDashDot])),
        (Text.LineStyle(pattern: .dashDotDot), NSUnderlineStyle([.single, .patternDashDotDot])),
        (Text.LineStyle.single, .single),
    ] as [(Text.LineStyle, NSUnderlineStyle)])
    func lineStyleToNSUnderlineStyle(
        _ lineStyle: Text.LineStyle,
        _ expectedNSUnderlineStyle: NSUnderlineStyle
    ) throws {
        let nsUnderlineStyle = NSUnderlineStyle(lineStyle)
        #expect(nsUnderlineStyle == expectedNSUnderlineStyle)
    }
}
