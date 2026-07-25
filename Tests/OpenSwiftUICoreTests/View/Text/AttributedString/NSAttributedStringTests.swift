//
//  NSAttributedStringTests.swift
//  OpenSwiftUICoreTests

#if canImport(CoreText)

import CoreText
import Foundation
import Numerics
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
@testable import OpenSwiftUICore
import Testing

/// A font with stable metrics, so measurement results do not depend on the
/// current system font or on the environment's content size category.
private let fixedFont = CTFontCreateWithName("Helvetica" as CFString, 16, nil)

/// A fixed font with a non-zero leading, used to exercise uniform line height.
private let fixedLeadingFont = CTFontCreateWithName("Times New Roman" as CFString, 20, nil)

private func attributedString(_ string: String, font: CTFont = fixedFont) -> NSAttributedString {
    NSAttributedString(string: string, attributes: [.kitFont: font])
}

/// The metrics of ``fixedFont``, whose 16 point line height and 12 point
/// baseline are already whole pixels.
private enum FixedFontMetrics {
    static let ascender: CGFloat = 12.3203125
    static let descender: CGFloat = -3.6796875
    static let lineHeight: CGFloat = 16
    static let baseline: CGFloat = 12
}

private func metrics(
    of string: NSAttributedString,
    requestedSize: CGSize = .infinity,
    layoutMargins: EdgeInsets = .zero,
    lineLimit: Int? = nil,
    wantsNumberOfLineFragments: Bool = true
) -> NSAttributedString.Metrics {
    var cache = NSAttributedString.MetricsCache(
        string,
        scaleFactorOverride: nil,
        lineLimit: lineLimit,
        lowerLineLimit: nil,
        minScaleFactor: 1,
        bodyHeadOutdent: 0,
        pixelLength: 1,
        widthIsFlexible: false,
        drawWithRequestedWidth: false,
        isCollapsible: false
    )
    return cache.metrics(
        requestedSize: requestedSize,
        layoutMargins: layoutMargins,
        wantsNumberOfLineFragments: wantsNumberOfLineFragments,
        context: .shared
    )
}

private func expectApproximatelyEqual(
    _ metrics: Spacing.TextMetrics,
    _ expected: Spacing.TextMetrics,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(metrics.ascend.isApproximatelyEqual(to: expected.ascend), sourceLocation: sourceLocation)
    #expect(metrics.descend.isApproximatelyEqual(to: expected.descend), sourceLocation: sourceLocation)
    #expect(metrics.leading.isApproximatelyEqual(to: expected.leading), sourceLocation: sourceLocation)
    #expect(metrics.pixelLength.isApproximatelyEqual(to: expected.pixelLength), sourceLocation: sourceLocation)
}

private func expectApproximatelyEqual(
    _ value: Spacing.Value?,
    _ expected: Spacing.Value,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    switch (value, expected) {
    case let (.distance(value), .distance(expected)):
        #expect(value.isApproximatelyEqual(to: expected), sourceLocation: sourceLocation)
    case let (.topTextMetrics(value), .topTextMetrics(expected)),
         let (.bottomTextMetrics(value), .bottomTextMetrics(expected)):
        expectApproximatelyEqual(value, expected, sourceLocation: sourceLocation)
    default:
        Issue.record("\(String(describing: value)) is not approximately \(expected)", sourceLocation: sourceLocation)
    }
}

// Semantic version overrides are process wide, so the tests below must not run
// concurrently with each other.
@Suite(.serialized)
struct NSAttributedStringTests {
    // MARK: - Max font metrics

    // `.serialized` is a recursive trait, so this suite inherits the serial
    // execution of the enclosing suite.
    @Suite
    struct MaxFontMetricsTests {
        @Test
        func maxFontMetricsWithoutFontAttributes() {
            let metrics = NSAttributedString(string: "OpenSwiftUI").maxFontMetrics

            #expect(metrics.capHeight == 0)
            #expect(metrics.ascender == 0)
            #expect(metrics.descender == 0)
            #expect(metrics.leading == 0)
            #expect(metrics.outsets == .zero)
        }

        @Test(arguments: [true, false])
        func maxFontMetricsOutsetsFollowTextRenderingMetrics(isTextRenderingMetricsEnabled: Bool) {
            let semantics = isTextRenderingMetricsEnabled
                ? Semantics.TextRenderingMetrics.introduced
                : Semantics.TextRenderingMetrics.prior
            semantics.test(as: \.sdk) {
                #expect(Semantics.TextRenderingMetrics.isEnabled == isTextRenderingMetricsEnabled)

                let outsets = attributedString("Hello").maxFontMetrics.outsets

                // The clipping ascender of Helvetica extends past the font's own
                // ascender, while its clipping descender does not.
                #expect(outsets.top.isApproximatelyEqual(to: isTextRenderingMetricsEnabled ? 2.8828125 : 0))
                #expect(outsets.bottom.isApproximatelyEqual(to: 0))
                #expect(outsets.leading.isApproximatelyEqual(to: 0))
                #expect(outsets.trailing.isApproximatelyEqual(to: 0))
            }
        }

        @Test
        func maxFontMetricsAggregatesFontRuns() {
            let smallFont = CTFontCreateWithName("Helvetica" as CFString, 12, nil)
            let largeFont = CTFontCreateWithName("Helvetica" as CFString, 24, nil)

            // Every metric comes from the larger font, whichever run it is in.
            for (firstFont, secondFont) in [(smallFont, largeFont), (largeFont, smallFont)] {
                let attributedString = NSMutableAttributedString(string: "ab")
                attributedString.addAttribute(.kitFont, value: firstFont, range: NSRange(location: 0, length: 1))
                attributedString.addAttribute(.kitFont, value: secondFont, range: NSRange(location: 1, length: 1))

                let metrics = attributedString.maxFontMetrics

                #expect(metrics.capHeight.isApproximatelyEqual(to: 17.21484375))
                #expect(metrics.ascender.isApproximatelyEqual(to: 18.48046875))
                #expect(metrics.descender.isApproximatelyEqual(to: -5.51953125))
                #expect(metrics.leading.isApproximatelyEqual(to: 0))
            }
        }
    }

    // MARK: - Metrics

    @Suite
    struct MetricsTests {
        @Test
        func metricsOfSingleLine() {
            let result = metrics(of: attributedString("Hello"))

            #expect(result.numberOfLines == 1)
            #expect(result.scale.isApproximatelyEqual(to: 1))
            #expect(!result.hasTruncatedRanges)
            #expect(result.requestedWidth == .infinity)
            #expect(result.size.width > 0)
            // The line height and the baseline are rounded to the pixel length.
            #expect(result.size.height.isApproximatelyEqual(to: FixedFontMetrics.lineHeight))
            #expect(result.firstBaseline.isApproximatelyEqual(to: FixedFontMetrics.baseline))
            #expect(result.lastBaseline.isApproximatelyEqual(to: FixedFontMetrics.baseline))
            #expect(result.baselineAdjustment.isApproximatelyEqual(to: 0))
        }

        @Test
        func metricsOfWrappedLines() {
            let string = attributedString("Hello OpenSwiftUI World")
            let result = metrics(of: string, requestedSize: CGSize(width: 60, height: CGFloat.infinity))

            #expect(result.requestedWidth == 60)
            #expect(result.size.width <= 60)
            #expect(result.numberOfLines == 4)
            #expect(result.size.height.isApproximatelyEqual(to: FixedFontMetrics.lineHeight * 4))
            #expect(result.firstBaseline.isApproximatelyEqual(to: FixedFontMetrics.baseline))
            #expect(result.lastBaseline.isApproximatelyEqual(to: FixedFontMetrics.baseline + 48))
        }

        @Test
        func metricsRespectsLineLimit() {
            let string = attributedString("Hello OpenSwiftUI World")
            let requestedSize = CGSize(width: 60, height: CGFloat.infinity)
            let unlimited = metrics(of: string, requestedSize: requestedSize)
            let limited = metrics(of: string, requestedSize: requestedSize, lineLimit: 2)

            #expect(unlimited.numberOfLines == 4)
            #expect(limited.numberOfLines == 2)
            #expect(limited.size.height.isApproximatelyEqual(to: FixedFontMetrics.lineHeight * 2))
            #expect(limited.firstBaseline.isApproximatelyEqual(to: FixedFontMetrics.baseline))
            #expect(limited.lastBaseline.isApproximatelyEqual(to: FixedFontMetrics.baseline + 16))
        }

        @Test
        func metricsIncludesLayoutMargins() {
            let insets = EdgeInsets(top: 3, leading: 5, bottom: 7, trailing: 11)
            let unmargined = metrics(of: attributedString("Hello"))
            let margined = metrics(of: attributedString("Hello"), layoutMargins: insets)

            #expect(margined.size.width.isApproximatelyEqual(to: unmargined.size.width + 16))
            #expect(margined.size.height.isApproximatelyEqual(to: FixedFontMetrics.lineHeight + 10))
            #expect(margined.firstBaseline.isApproximatelyEqual(to: FixedFontMetrics.baseline + 3))
            #expect(margined.lastBaseline.isApproximatelyEqual(to: FixedFontMetrics.baseline + 3))
        }

        @Test
        func metricsUpdateRoundsBaselinesToPixelLength() {
            var result = NSAttributedString.Metrics(
                size: CGSize(width: 10, height: 20),
                scale: 1,
                firstBaseline: 11.4,
                lastBaseline: 15.6,
                baselineAdjustment: 0,
                requestedWidth: 100,
                numberOfLines: 2,
                hasTruncatedRanges: false
            )
            result.update(
                layoutMargins: EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4),
                pixelLength: 1
            )

            #expect(result.size == CGSize(width: 16, height: 24))
            // 11.4 + 1 rounds to 12, so every baseline shifts by the same
            // -0.4 adjustment before the last baseline is rounded up.
            #expect(result.firstBaseline == 12)
            #expect(result.baselineAdjustment.isApproximatelyEqual(to: -0.4))
            #expect(result.lastBaseline == 17)
        }
    }

    // MARK: - Spacing

    @Suite
    struct TextSpacingTests {
        /// The text metrics of ``fixedFont``, which has no leading.
        static let fixedTextMetrics = Spacing.TextMetrics(
            ascend: FixedFontMetrics.ascender,
            descend: -FixedFontMetrics.descender,
            leading: 0,
            pixelLength: 1
        )

        private static func spacing(
            of string: NSAttributedString,
            textSizing: Text.Sizing = .standard,
            writingMode: Text.WritingMode = .horizontalTopToBottom
        ) -> Spacing {
            var layoutProperties = TextLayoutProperties()
            layoutProperties.pixelLength = 1
            layoutProperties.textSizing = textSizing
            layoutProperties.writingMode = writingMode
            return Spacing.textSpacing(
                maxFontMetrics: string.maxFontMetrics,
                idealMetrics: metrics(of: string),
                layoutProperties: layoutProperties
            )
        }

        @Test(arguments: [true, false])
        func textSpacingWithStandardSizing(isTextSpacingV2Enabled: Bool) {
            let semantics = isTextSpacingV2Enabled
                ? Semantics.TextSpacingUIKit0059v2.introduced
                : Semantics.TextSpacingUIKit0059v2.prior
            semantics.test(as: \.sdk) {
                #expect(Semantics.TextSpacingUIKit0059v2.isEnabled == isTextSpacingV2Enabled)

                let spacing = Self.spacing(of: attributedString("Hello"))

                #expect(spacing.minima.count == 6)
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .textToText, edge: .top)],
                    .bottomTextMetrics(Self.fixedTextMetrics)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .textToText, edge: .bottom)],
                    .topTextMetrics(Self.fixedTextMetrics)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .textBaseline, edge: .top)],
                    .distance(-FixedFontMetrics.baseline)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .textBaseline, edge: .bottom)],
                    .distance(FixedFontMetrics.baseline - FixedFontMetrics.lineHeight)
                )
                // The 16 point line height gives a 1.6 point default text spacing,
                // which rounds up to the pixel length only once TextSpacingUIKit0059v2
                // is enabled, and to 4 points before that.
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .edgeAboveText, edge: .top)],
                    .distance(isTextSpacingV2Enabled ? 5.6796875 : 7.6796875)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .edgeBelowText, edge: .bottom)],
                    .distance(isTextSpacingV2Enabled ? 6.5234375 : 8.5234375)
                )
            }
        }

        @Test
        func textSpacingWithUniformLineHeightSplitsLeading() {
            let spacing = Self.spacing(
                of: attributedString("Hello", font: fixedLeadingFont),
                textSizing: .uniformLineHeight
            )

            // Uniform line height moves the 0.849609375 point font leading into
            // equal half-leading contributions above and below the baseline.
            let textMetrics = Spacing.TextMetrics(
                ascend: 18.2470703125,
                descend: 4.7509765625,
                leading: 0,
                pixelLength: 1
            )

            expectApproximatelyEqual(
                spacing.minima[.init(category: .textToText, edge: .top)],
                .bottomTextMetrics(textMetrics)
            )
            expectApproximatelyEqual(
                spacing.minima[.init(category: .textToText, edge: .bottom)],
                .topTextMetrics(textMetrics)
            )
        }

        @Test
        func textSpacingWithVerticalWritingModeUsesSideEdges() {
            Semantics.TextSpacingUIKit0059v2.introduced.test(as: \.sdk) {
                let spacing = Self.spacing(
                    of: attributedString("Hello"),
                    writingMode: .verticalRightToLeft
                )

                // A vertical writing mode maps the leading edge to the right and the
                // trailing edge to the left, leaving the horizontal edges unset.
                #expect(spacing.minima.count == 6)
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .textToText, edge: .right)],
                    .bottomTextMetrics(Self.fixedTextMetrics)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .textToText, edge: .left)],
                    .topTextMetrics(Self.fixedTextMetrics)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .rightTextBaseline, edge: .right)],
                    .distance(-FixedFontMetrics.baseline)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .leftTextBaseline, edge: .left)],
                    .distance(FixedFontMetrics.baseline - FixedFontMetrics.lineHeight)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .edgeRightText, edge: .right)],
                    .distance(5.6796875)
                )
                expectApproximatelyEqual(
                    spacing.minima[.init(category: .edgeLeftText, edge: .left)],
                    .distance(6.5234375)
                )
                #expect(spacing.minima[.init(category: .textToText, edge: .top)] == nil)
                #expect(spacing.minima[.init(category: .textToText, edge: .bottom)] == nil)
            }
        }
    }
}

#endif
