//
//  Text+StringDrawingContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 68D51D45BC7225E72FB030F887E5A492 (SwiftUICore)

public import Foundation
import UIFoundation_Private
#if canImport(CoreText)
import CoreText
#endif

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

    // TBA
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
        #if canImport(Darwin)
        return context.withStringDrawingContext(
            minScaleFactor: minScaleFactor,
            lineLimit: lineLimit,
            kitCache: kitCache,
            useNSLayoutManager: hasLinkAttributes
        ) { drawingContext in
            if wantsNumberOfLineFragments || bodyHeadOutdent > 0 {
                drawingContext.wantsNumberOfLineFragments = true
            }

            let limitedFontHeight: CGFloat
            if let lowerLineLimit, lowerLineLimit >= 1, length >= 1 {
                limitedFontHeight = self.limitedFontHeight(by: lowerLineLimit) ?? 0
            } else {
                limitedFontHeight = 0
            }

            let measuredWidth: CGFloat
            if requestedSize.width == .infinity {
                measuredWidth = .greatestFiniteMagnitude
            } else if requestedSize.width <= 0 {
                measuredWidth = 1
            } else {
                measuredWidth = requestedSize.width
            }

            let measuredHeight: CGFloat
            if requestedSize.height == .infinity {
                measuredHeight = max(.greatestFiniteMagnitude, limitedFontHeight)
            } else if requestedSize.height <= 0 {
                measuredHeight = max(1, limitedFontHeight)
            } else {
                measuredHeight = max(requestedSize.height, limitedFontHeight)
            }

            let rect = boundingRect(
                with: CGSize(width: measuredWidth, height: measuredHeight),
                options: NSString.DrawingOptions(rawValue: 0x10_0001),
                context: drawingContext
            )
            kitCache = drawingContext.layout as AnyObject?
            drawingContext.layout = nil

            let scaledLineHeight = drawingContext.scaledLineHeight
            let resultHeight = scaledLineHeight == 0 ? rect.height : scaledLineHeight
            var resultWidth = rect.width

            if bodyHeadOutdent > 0 {
                let lineFragmentCount = drawingContext.numberOfLineFragments
                var matchesSourceLineCount = lineFragmentCount == 1
                if !matchesSourceLineCount {
                    let components = string.components(separatedBy: .newlines)
                    let sourceLineCount: Int
                    if components.last?.isEmpty == true {
                        sourceLineCount = components.count - 1
                    } else {
                        sourceLineCount = components.count
                    }
                    let limitedSourceLineCount = lineLimit.map { min(sourceLineCount, $0) } ?? sourceLineCount
                    matchesSourceLineCount = limitedSourceLineCount == lineFragmentCount
                }
                if matchesSourceLineCount {
                    let outdentedWidth = rect.width + bodyHeadOutdent
                    if requestedSize.width > 0 {
                        resultWidth = min(outdentedWidth, measuredWidth)
                    } else {
                        resultWidth = max(outdentedWidth, 1)
                    }
                }
            }

            var size = CGSize(
                width: widthIsFlexible ? requestedSize.width : (resultWidth == 1 ? 0 : resultWidth),
                height: resultHeight == 1 ? 0 : resultHeight
            )
            if isCollapsible, size.height > requestedSize.height {
                size = .zero
            }
            size.height = max(size.height, limitedFontHeight)

            let reportsLineFragments = drawingContext.wantsNumberOfLineFragments
            let numberOfLines = reportsLineFragments ? UInt(drawingContext.numberOfLineFragments) : nil
            return Metrics(
                size: size,
                scale: drawingContext.actualScaleFactor,
                firstBaseline: drawingContext.firstBaselineOffset,
                lastBaseline: scaledLineHeight == 0
                    ? drawingContext.baselineOffset
                    : drawingContext.scaledBaselineOffset,
                baselineAdjustment: 0,
                requestedWidth: requestedSize.width,
                numberOfLines: numberOfLines,
                hasTruncatedRanges: drawingContext.hasTruncatedRanges
            )
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return Metrics(
            size: .zero,
            scale: 1,
            firstBaseline: 0,
            lastBaseline: 0,
            baselineAdjustment: 0,
            requestedWidth: requestedSize.width,
            numberOfLines: wantsNumberOfLineFragments ? 0 : nil,
            hasTruncatedRanges: false
        )
        #endif
    }

    // FIXME
    #if canImport(Darwin)
    private var hasLinkAttributes: Bool {
        var result = false
        enumerateAttribute(.kitLink, in: NSRange(location: 0, length: length)) { value, _, stop in
            let link: URL?
            if let value = value as? URL {
                link = value
            } else if let value = value as? String {
                link = URL(string: value)
            } else {
                link = nil
            }
            if link != nil {
                result = true
                stop.pointee = true
            }
        }
        return result
    }

    // FIXME
    private func limitedFontHeight(by lineLimit: Int) -> CGFloat? {
        #if canImport(CoreText)
        guard lineLimit >= 1, let font = kitFont(at: 0) else {
            return nil
        }
        let lineHeight = CTFontGetAscent(font) + CTFontGetDescent(font)
        return CGFloat(lineLimit) * lineHeight + CGFloat(lineLimit - 1) * CTFontGetLeading(font)
        #else
        return nil
        #endif
    }
    #endif
}

// TBA
#if canImport(Darwin)
@available(OpenSwiftUI_v6_0, *)
private extension TextDrawingContext {
    func withStringDrawingContext<Result>(
        minScaleFactor: CGFloat,
        lineLimit: Int?,
        kitCache: AnyObject?,
        useNSLayoutManager: Bool,
        `do` body: (NSStringDrawingContext) -> Result
    ) -> Result {
        $ctx.access { drawingContext in
            if minScaleFactor <= 0 {
                drawingContext.minimumScaleFactor = 1
            } else if minScaleFactor >= 1 {
                drawingContext.minimumScaleFactor = 0
            } else {
                drawingContext.minimumScaleFactor = minScaleFactor
            }
            drawingContext.scaledLineHeight = 0
            drawingContext.scaledBaselineOffset = 0
            drawingContext.maximumNumberOfLines = lineLimit.map { max($0, 1) } ?? 0
            drawingContext.cachesLayout = true
            drawingContext.layout = kitCache
            drawingContext.wantsNumberOfLineFragments = false
            drawingContext.activeRenderers = useNSLayoutManager ? 8 : 0
            drawingContext.linkTextAttributesProvider = { attributes, _ in
                var attributes = attributes ?? [:]
                attributes.removeValue(forKey: .kitForegroundColor)
                return attributes
            }
            return body(drawingContext)
        }
    }
}
#endif

@available(*, unavailable)
extension NSAttributedString.Metrics: Sendable {}

extension ResolvedStyledText {
    // FIXME
    package class StringDrawing: ResolvedStyledText {}

    // FIXME
    package class TextLayoutManager: ResolvedStyledText {}
}
