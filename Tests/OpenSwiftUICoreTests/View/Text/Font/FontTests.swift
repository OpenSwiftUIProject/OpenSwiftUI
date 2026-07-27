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

    @Test
    func customFontIdentity() {
        let body = Font.custom("Helvetica", size: 17.0)

        #expect(body == Font.custom("Helvetica", size: 17.0))
        #expect(body == Font.custom("Helvetica", size: 17.0, relativeTo: .body))
        #expect(body != Font.custom("Helvetica", size: 17.0, relativeTo: .headline))
        #expect(body != Font.custom("Helvetica", fixedSize: 17.0))
        #expect(body != Font.custom("Helvetica Neue", size: 17.0))
    }

    @MainActor
    @Test
    func customFontSizing() throws {
        try Semantics.v2.test(as: \.sdk) {
            let size = 17.0
            let dynamicTypeSize = DynamicTypeSize.accessibility5

            let scalableDescriptor = Font.custom(
                "Helvetica",
                size: size
            ).resolve(in: dynamicTypeSize)
            let fixedDescriptor = Font.custom(
                "Helvetica",
                fixedSize: size
            ).resolve(in: dynamicTypeSize)

            let scalableSize = try #require(
                CTFontDescriptorCopyAttribute(
                    scalableDescriptor,
                    kCTFontSizeAttribute
                ) as? CGFloat
            )
            let fixedSize = try #require(
                CTFontDescriptorCopyAttribute(
                    fixedDescriptor,
                    kCTFontSizeAttribute
                ) as? CGFloat
            )
            let expectedScalableSize = (
                Font.scaleFactor(
                    textStyle: .body,
                    in: dynamicTypeSize
                ) * size
            ).rounded()

            #expect(
                scalableSize.isApproximatelyEqual(
                    to: expectedScalableSize,
                    absoluteTolerance: 0.01
                )
            )
            #expect(
                fixedSize.isApproximatelyEqual(
                    to: size,
                    absoluteTolerance: 0.01
                )
            )
        }
    }

    @Test
    func platformFont() {
        let platformFont = CTFontCreateWithName(
            "Helvetica" as CFString,
            23.0,
            nil
        )
        let font = Font(platformFont)
        let descriptor = font.resolve(in: .large)

        #expect(CFEqual(descriptor, CTFontCopyFontDescriptor(platformFont)))
        #expect(Set([font, Font(platformFont)]).count == 1)
    }
}

#endif
