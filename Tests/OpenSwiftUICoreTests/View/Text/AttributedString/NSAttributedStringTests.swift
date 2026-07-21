//
//  NSAttributedStringTests.swift
//  OpenSwiftUICoreTests
//

#if canImport(CoreText)

import CoreText
import Foundation
@testable import OpenSwiftUICore
import Testing

struct NSAttributedStringTests {
    @Test
    func maxFontMetricsWithoutFontAttributes() {
        let metrics = NSAttributedString(string: "OpenSwiftUI").maxFontMetrics

        #expect(metrics.capHeight == 0)
        #expect(metrics.ascender == 0)
        #expect(metrics.descender == 0)
        #expect(metrics.leading == 0)
        #expect(metrics.outsets == .zero)
    }

    @Test
    func maxFontMetricsAggregatesFontRuns() {
        let smallFont = CTFontCreateWithName("Helvetica" as CFString, 12, nil)
        let largeFont = CTFontCreateWithName("Helvetica" as CFString, 24, nil)
        let expectedCapHeight = max(CTFontGetCapHeight(smallFont), CTFontGetCapHeight(largeFont))
        let expectedAscender = max(CTFontGetAscent(smallFont), CTFontGetAscent(largeFont))
        let expectedDescender = -max(CTFontGetDescent(smallFont), CTFontGetDescent(largeFont))
        let expectedLeading = max(CTFontGetLeading(smallFont), CTFontGetLeading(largeFont))

        for (firstFont, secondFont) in [(smallFont, largeFont), (largeFont, smallFont)] {
            let attributedString = NSMutableAttributedString(string: "ab")
            attributedString.addAttribute(.kitFont, value: firstFont, range: NSRange(location: 0, length: 1))
            attributedString.addAttribute(.kitFont, value: secondFont, range: NSRange(location: 1, length: 1))

            let metrics = attributedString.maxFontMetrics

            #expect(metrics.capHeight == expectedCapHeight)
            #expect(metrics.ascender == expectedAscender)
            #expect(metrics.descender == expectedDescender)
            #expect(metrics.leading == expectedLeading)
        }
    }
}

#endif
