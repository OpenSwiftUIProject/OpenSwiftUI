//
//  Text+StringDrawingContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 68D51D45BC7225E72FB030F887E5A492 (SwiftUICore)

public import Foundation

@available(OpenSwiftUI_v6_0, *)
extension NSAttributedString {
    @usableFromInline
    package struct Metrics: Equatable {
        package var size: CGSize
        package let scale: CGFloat
        package var firstBaseline: CGFloat
        package var lastBaseline: CGFloat
        package var baselineAdjustment: CGFloat
        package var requestedWidth: CGFloat
        package var numberOfLines: UInt?
        package var hasTruncatedRanges: Bool

        package init(
            size: CGSize,
            scale: CGFloat,
            firstBaseline: CGFloat,
            lastBaseline: CGFloat,
            baselineAdjustment: CGFloat,
            requestedWidth: CGFloat,
            numberOfLines: UInt?,
            hasTruncatedRanges: Bool
        ) {
            self.size = size
            self.scale = scale
            self.firstBaseline = firstBaseline
            self.lastBaseline = lastBaseline
            self.baselineAdjustment = baselineAdjustment
            self.requestedWidth = requestedWidth
            self.numberOfLines = numberOfLines
            self.hasTruncatedRanges = hasTruncatedRanges
        }

        package mutating func update(
            layoutMargins: EdgeInsets,
            pixelLength: CGFloat
        ) {
            size.width += layoutMargins.horizontal
            size.height += layoutMargins.vertical
            firstBaseline += layoutMargins.top
            lastBaseline += layoutMargins.top
            let unroundedFirstBaseline = firstBaseline
            firstBaseline.round(.toNearestOrAwayFromZero, toMultipleOf: pixelLength)
            baselineAdjustment = firstBaseline - unroundedFirstBaseline
            lastBaseline += baselineAdjustment
            lastBaseline.round(.up, toMultipleOf: pixelLength)
        }
    }

    struct MetricsCache {
        var kitCache: AnyObject?
        let string: NSAttributedString
        let lineLimit: Int?
        let lowerLineLimit: Int?
        let minScaleFactor: CGFloat
        let bodyHeadOutdent: CGFloat
        let pixelLength: CGFloat
        let widthIsFlexible: Bool
        let drawWithRequestedWidth: Bool
        let isCollapsible: Bool
        var entries: [(CGSize, Metrics)]

        init(
            _ string: NSAttributedString?,
            scaleFactorOverride: CGFloat?,
            lineLimit: Int?,
            lowerLineLimit: Int?,
            minScaleFactor: CGFloat,
            bodyHeadOutdent: CGFloat,
            pixelLength: CGFloat,
            widthIsFlexible: Bool,
            drawWithRequestedWidth: Bool,
            isCollapsible: Bool
        ) {
            self.kitCache = nil
            self.string = string?.scaled(by: scaleFactorOverride ?? 1) ?? .emptyString
            self.lineLimit = lineLimit
            self.lowerLineLimit = lowerLineLimit
            // A scale override has already been baked into `string`, so the drawing
            // context must not apply the original minimum scale factor a second time.
            self.minScaleFactor = scaleFactorOverride == nil ? minScaleFactor : 1
            self.bodyHeadOutdent = bodyHeadOutdent
            self.pixelLength = pixelLength
            self.widthIsFlexible = widthIsFlexible
            self.drawWithRequestedWidth = drawWithRequestedWidth
            self.isCollapsible = isCollapsible
            self.entries = []
        }

        mutating func metrics(
            requestedSize: CGSize,
            layoutMargins: EdgeInsets,
            wantsNumberOfLineFragments: Bool,
            context: TextDrawingContext
        ) -> Metrics {
            for (cachedSize, cachedMetrics) in entries {
                // One layout is reusable for every proposal between the proposal
                // that produced it and its measured size. This matters when text
                // snaps to the same line breaks across a range of widths/heights.
                let minimumWidth = min(cachedSize.width, cachedMetrics.size.width)
                let maximumWidth = max(cachedSize.width, cachedMetrics.size.width)
                let minimumHeight = min(cachedSize.height, cachedMetrics.size.height)
                let maximumHeight = max(cachedSize.height, cachedMetrics.size.height)
                guard !wantsNumberOfLineFragments || cachedMetrics.numberOfLines != nil,
                      minimumWidth <= requestedSize.width,
                      maximumWidth >= requestedSize.width,
                      minimumHeight <= requestedSize.height,
                      maximumHeight >= requestedSize.height else {
                    continue
                }
                LayoutTrace.traceCacheLookup(requestedSize, true)
                return cachedMetrics
            }
            LayoutTrace.traceCacheLookup(requestedSize, false)
            let measurementSize = CGSize(
                width: max(0, requestedSize.width - layoutMargins.horizontal) + bodyHeadOutdent,
                height: max(0, requestedSize.height - layoutMargins.vertical)
            )
            var result = string.measured(
                requestedSize: measurementSize,
                lineLimit: lineLimit,
                lowerLineLimit: lowerLineLimit,
                minScaleFactor: minScaleFactor,
                bodyHeadOutdent: bodyHeadOutdent,
                widthIsFlexible: widthIsFlexible,
                kitCache: &kitCache,
                isCollapsible: isCollapsible,
                wantsNumberOfLineFragments: wantsNumberOfLineFragments,
                context: context
            )
            result.size.round(.up, toMultipleOf: pixelLength)
            result.size.width -= bodyHeadOutdent
            result.update(layoutMargins: layoutMargins, pixelLength: pixelLength)
            entries.append((requestedSize, result))
            return result
        }
    }

    private static let emptyString = NSAttributedString()

    private func measured(
        requestedSize: CGSize,
        lineLimit: Int?,
        lowerLineLimit: Int?,
        minScaleFactor: CGFloat,
        bodyHeadOutdent: CGFloat,
        widthIsFlexible: Bool,
        kitCache: inout AnyObject?,
        isCollapsible: Bool,
        wantsNumberOfLineFragments: Bool,
        context: TextDrawingContext
    ) -> NSAttributedString.Metrics {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(*, unavailable)
extension NSAttributedString.Metrics: Sendable {}

extension ResolvedStyledText {
    // FIXME
    package class StringDrawing: ResolvedStyledText {}

    // FIXME
    package class TextLayoutManager: ResolvedStyledText {}
}
