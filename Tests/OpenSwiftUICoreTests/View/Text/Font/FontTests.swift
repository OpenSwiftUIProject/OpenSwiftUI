//
//  FontTests.swift
//  OpenSwiftUICoreTests

#if canImport(Darwin)

import CoreText
import Numerics
@_spi(Private)
import OpenSwiftUICore
import Testing

struct FontTests {
    @Test
    func fontModifier() {
        let descriptor = Font.body.resolve(in: .large)
        let weight = CTFontDescriptorGetWeight(descriptor)
        #expect(weight.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.01))

        let boldDescriptor = Font.body.bold().resolve(in: .large)
        let boldWeight = CTFontDescriptorGetWeight(boldDescriptor)
        #expect(boldWeight.isApproximatelyEqual(to: 0.3, absoluteTolerance: 0.01))
    }
}

#endif
