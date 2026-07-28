//
//  FontTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(Private)
import OpenSwiftUICore
import Testing

#if canImport(CoreText)
import CoreText
import Numerics
#endif

struct FontTests {
    #if canImport(CoreText)
    @Test
    func fontModifier() {
        let descriptor = Font.body.resolve(in: .large)
        let weight = CTFontDescriptorGetWeight(descriptor)
        #expect(weight.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.01))

        let boldDescriptor = Font.body.bold().resolve(in: .large)
        let boldWeight = CTFontDescriptorGetWeight(boldDescriptor)
        #expect(boldWeight.isApproximatelyEqual(to: 0.3, absoluteTolerance: 0.01))
    }
    #endif

    @Test
    func customFontIdentity() {
        let body = Font.custom("Helvetica", size: 17.0)

        #expect(body == Font.custom("Helvetica", size: 17.0))
        #expect(body == Font.custom("Helvetica", size: 17.0, relativeTo: .body))
        #expect(body != Font.custom("Helvetica", size: 17.0, relativeTo: .headline))
        #expect(body != Font.custom("Helvetica", fixedSize: 17.0))
        #expect(body != Font.custom("Helvetica Neue", size: 17.0))
    }

    @Test
    @available(*, deprecated)
    func deprecatedCustomFontFactories() {
        #expect(
            Font._custom(
                "Helvetica",
                size: 17.0,
                textStyle: .headline
            ) == Font.custom(
                "Helvetica",
                size: 17.0,
                relativeTo: .headline
            )
        )
        #expect(
            Font._custom(
                "Helvetica",
                verbatimSize: 17.0
            ) == Font.custom(
                "Helvetica",
                fixedSize: 17.0
            )
        )
    }

    #if canImport(CoreText)
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
            let relativeDescriptor = Font.custom(
                "Helvetica",
                size: size,
                relativeTo: .headline
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
            let relativeSize = try #require(
                CTFontDescriptorCopyAttribute(
                    relativeDescriptor,
                    kCTFontSizeAttribute
                ) as? CGFloat
            )
            let expectedScalableSize = (
                Font.scaleFactor(
                    textStyle: .body,
                    in: dynamicTypeSize
                ) * size
            ).rounded()
            let expectedRelativeSize = (
                Font.scaleFactor(
                    textStyle: .headline,
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
            #expect(
                relativeSize.isApproximatelyEqual(
                    to: expectedRelativeSize,
                    absoluteTolerance: 0.01
                )
            )
        }
    }
    #endif

    @Test
    func platformFont() {
        #if canImport(CoreText)
        let platformFont = CTFontCreateWithName(
            "Helvetica" as CFString,
            23.0,
            nil
        )
        #else
        let platformFont = CTFont()
        #endif

        let font = Font(platformFont)
        #expect(Set([font, Font(platformFont)]).count == 1)

        #if canImport(CoreText)
        let descriptor = font.resolve(in: .large)
        #expect(CFEqual(descriptor, CTFontCopyFontDescriptor(platformFont)))
        #else
        #expect(font != Font(CTFont()))
        #endif
    }
}
