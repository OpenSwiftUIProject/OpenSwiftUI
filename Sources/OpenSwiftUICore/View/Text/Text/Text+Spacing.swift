//
//  Text+Spacing.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation

// MARK: - Spacing + Text

extension Spacing {
    static func textSpacing(
        maxFontMetrics: NSAttributedString.EncodedFontMetrics,
        idealMetrics: NSAttributedString.Metrics,
        layoutProperties: TextLayoutProperties
    ) -> Spacing {
        let (
            firstEdge,
            secondEdge,
            firstEdgeCategory,
            secondEdgeCategory,
            firstBaselineCategory,
            secondBaselineCategory
        ): (AbsoluteEdge, AbsoluteEdge, Category, Category, Category, Category) = {
            switch layoutProperties.writingMode.storage {
            case .horizontalTopToBottom:
                (.top, .bottom, .edgeAboveText, .edgeBelowText, .textBaseline, .textBaseline)
            case .verticalRightToLeft:
                (.right, .left, .edgeRightText, .edgeLeftText, .rightTextBaseline, .leftTextBaseline)
            }
        }()

        let fontLineHeight = maxFontMetrics.ascender - maxFontMetrics.descender
        var defaultTextSpacing = fontLineHeight * 0.1
        defaultTextSpacing.round(
            .up,
            toMultipleOf: Semantics.TextSpacingUIKit0059v2.isEnabled ? layoutProperties.pixelLength : 4.0
        )

        // Uniform line height moves the font leading into equal half-leading
        // contributions above and below the baseline.
        let uniformLeading = layoutProperties.textSizing == .uniformLineHeight
            ? maxFontMetrics.leading
            : 0
        let halfUniformLeading = uniformLeading * 0.5
        let textMetrics = TextMetrics(
            ascend: maxFontMetrics.ascender + halfUniformLeading,
            descend: halfUniformLeading - maxFontMetrics.descender,
            leading: maxFontMetrics.leading - uniformLeading,
            pixelLength: layoutProperties.pixelLength
        )
        let defaultLineSpacing = fontLineHeight + defaultTextSpacing

        return Spacing(minima: [
            Key(category: .textToText, edge: firstEdge): .bottomTextMetrics(textMetrics),
            Key(category: .textToText, edge: secondEdge): .topTextMetrics(textMetrics),
            Key(category: secondBaselineCategory, edge: secondEdge): .distance(
                idealMetrics.lastBaseline - idealMetrics.size.height
            ),
            Key(category: firstBaselineCategory, edge: firstEdge): .distance(
                -idealMetrics.firstBaseline
            ),
            Key(category: firstEdgeCategory, edge: firstEdge): .distance(
                defaultLineSpacing - textMetrics.ascend
            ),
            Key(category: secondEdgeCategory, edge: secondEdge): .distance(
                max(
                    defaultLineSpacing - maxFontMetrics.capHeight,
                    defaultTextSpacing + textMetrics.descend
                )
            ),
        ])
    }
}
