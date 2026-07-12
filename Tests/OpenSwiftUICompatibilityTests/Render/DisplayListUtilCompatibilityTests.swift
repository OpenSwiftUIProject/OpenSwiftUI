//
//  DisplayListUtilCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

@MainActor
struct DisplayListUtilCompatibilityTests {
    @Test
    func rendersColor() {
        let displayList = DisplayListUtil.renderDisplayList(Color.red)
        #expect(DisplayListUtil.containsAnyColor(displayList))
    }
}
