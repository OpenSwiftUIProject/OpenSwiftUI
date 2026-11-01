//
//  FontTests.swift
//  OpenSwiftUICoreTests

#if canImport(CoreText)
import CoreText
import Numerics
#endif
import Foundation
@_spi(Private)
import OpenSwiftUICore
import Testing

struct FontTests {
    #if canImport(CoreText)
    @Test(arguments: [
        (nil, 0.0),
        (.ultraLight, -0.8),
        (.thin, -0.6),
        (.light, -0.4),
        (.regular, 0.0),
        (.medium, 0.23),
        (.semibold, 0.3),
        (.bold, 0.4),
        (.heavy, 0.56),
        (.black, 0.62),
    ] as [(Font.Weight?, CGFloat)])
    func systemFontWeight(weight: Font.Weight?, expected: CGFloat) {
        let descriptor = Font.system(
            size: 32,
            weight: weight
        ).resolve(in: .large)
        let resolvedWeight = CTFontDescriptorGetWeight(descriptor)

        #expect(
            resolvedWeight.isApproximatelyEqual(
                to: expected,
                absoluteTolerance: 0.01
            )
        )
    }

    @Test(arguments: [
        (32.0, Font.Weight.bold, 0.4),
        (17.0, Font.Weight.medium, 0.23),
    ] as [(CGFloat, Font.Weight, CGFloat)], [
        nil, .default, .serif, .rounded, .monospaced,
    ] as [Font.Design?])
    func systemFontPlatformWeight(
        request: (size: CGFloat, weight: Font.Weight, expected: CGFloat),
        design: Font.Design?
    ) {
        let font = Font.system(
            size: request.size,
            weight: request.weight,
            design: design
        ).platformFont(in: EnvironmentValues())

        #expect(font.pointSize == request.size)
        #expect(font.weight.isApproximatelyEqual(to: request.expected, absoluteTolerance: 0.01))
    }

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
