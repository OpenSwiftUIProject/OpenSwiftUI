//
//  TextScaleTests.swift
//  OpenSwiftUITests

import OpenSwiftUICore
import Testing

struct TextScaleTests {
    @Test
    func stringInitializerRecognizesCoreTextSecondaryScaleName() {
        #expect(Text.Scale("NSTextScaleSecondary") == .secondary)
        #expect(Text.Scale("default") == nil)
        #expect(Text.Scale("secondary") == nil)
    }

    @Test
    func textScaleModifierIsEquatableAndConditionallyApplied() {
        let text = Text("Hello")
        #expect(text.textScale(.secondary) == text.textScale(.secondary))
        #expect(text.textScale(.secondary) != text)
        #expect(text.textScale(.secondary, isEnabled: false) != text)
        #expect(text.textScale(.secondary, isEnabled: false) == text.textScale(.secondary))
    }
}
