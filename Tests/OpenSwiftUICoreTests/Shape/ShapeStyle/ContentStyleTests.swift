//
//  ContentStyleTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct ContentStyleTests {
    @Test(arguments: [
        (0, ContentStyle.ID.primary),
        (1, .secondary),
        (2, .tertiary),
        (3, .quaternary),
        (4, .quinary),
    ])
    func levelSelectsStyle(level: Int, expected: ContentStyle.ID) {
        #expect(ContentStyle.ID(level: level) == expected)
    }

    @Test(arguments: [Int.min, -256, -1, 5, 127, 128, 255, 256, 260, Int.max])
    func invalidLevelReturnsNil(level: Int) {
        #expect(ContentStyle.ID(level: level) == nil)
    }

    @Test(arguments: [
        (0, ContentStyle.ID.primary),
        (1, .secondary),
        (2, .tertiary),
        (3, .quaternary),
        (4, .quinary),
        (5, .quinary),
        (256, .quinary),
        (Int.max, .quinary),
        (-256, .primary),
        (-255, .secondary),
        (-252, .quinary),
    ])
    func truncatingLevelSelectsStyle(level: Int, expected: ContentStyle.ID) {
        #expect(ContentStyle.ID(truncatingLevel: level) == expected)
    }
}
