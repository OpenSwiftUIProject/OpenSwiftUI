//
//  Text+StringDrawingContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 68D51D45BC7225E72FB030F887E5A492 (SwiftUICore)

public import Foundation
import OpenSwiftUI_SPI
#if canImport(UIFoundation_Private)
import UIFoundation_Private
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
        context.withStringDrawingContext(
            minScaleFactor: minScaleFactor,
            lineLimit: lineLimit,
            kitCache: kitCache,
            useNSLayoutManager: hasLinkAttributes
        ) { drawingContext in
            #if canImport(Darwin)
            if wantsNumberOfLineFragments || bodyHeadOutdent > 0 {
                drawingContext.wantsNumberOfLineFragments = true
            }
            let limitedFontHeight: CGFloat
            if let lowerLineLimit, lowerLineLimit >= 1, length >= 1 {
                limitedFontHeight = self.limitedFontHeight(by: lowerLineLimit) ?? 0
            } else {
                limitedFontHeight = 0
            }
            func normalized(_ value: CGFloat) -> CGFloat {
                switch value {
                case ...0: .leastNonzeroMagnitude
                case .infinity: .greatestFiniteMagnitude
                default: value
                }
            }
            let rect = boundingRect(
                with: CGSize(
                    width: normalized(requestedSize.width),
                    height: max(normalized(requestedSize.height), limitedFontHeight)
                ),
                options: [
                    .usesLineFragmentOrigin,
                    .requiresFullTextLayout,
                ],
                context: drawingContext
            )
            kitCache = drawingContext.layout as AnyObject?
            drawingContext.layout = nil
            var width = rect.width
            var height = rect.height
            if drawingContext.scaledLineHeight != 0 {
                height = drawingContext.scaledLineHeight
            }
            if bodyHeadOutdent > 0 {
                let matchesSourceLineCount: Bool
                if drawingContext.numberOfLineFragments != 1 {
                    let components = string.components(separatedBy: .newlines)
                    let sourceLineCount: Int
                    if components.last?.isEmpty == true {
                        sourceLineCount = components.count - 1
                    } else {
                        sourceLineCount = components.count
                    }
                    let limitedSourceLineCount = min(sourceLineCount, ifPresent: lineLimit)
                    matchesSourceLineCount = limitedSourceLineCount == drawingContext.numberOfLineFragments
                } else {
                    matchesSourceLineCount = true
                }
                if matchesSourceLineCount {
                    let outdentedWidth = rect.width + bodyHeadOutdent
                    width = min(outdentedWidth, normalized(requestedSize.width))
                }
            }

            if widthIsFlexible {
                width = requestedSize.width
            } else {
                if width == .leastNonzeroMagnitude {
                    width = .zero
                }
            }
            height = height.ensuringNonzeroValue()
            if isCollapsible && height > requestedSize.height {
                width = .zero
                height = .zero
            }
            return Metrics(
                size: CGSize(
                    width: width,
                    height: max(height, limitedFontHeight)
                ),
                scale: drawingContext.actualScaleFactor,
                firstBaseline: drawingContext.firstBaselineOffset,
                lastBaseline: drawingContext.scaledLineHeight == 0
                    ? drawingContext.baselineOffset
                    : drawingContext.scaledBaselineOffset,
                baselineAdjustment: 0,
                requestedWidth: requestedSize.width,
                numberOfLines: drawingContext.wantsNumberOfLineFragments ? UInt(drawingContext.numberOfLineFragments) : nil,
                hasTruncatedRanges: drawingContext.hasTruncatedRanges
            )
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
    }
}

#if canImport(Darwin)
extension NSString.DrawingOptions {
    /// Requires the normal text-layout path to produce the final result, while
    /// still allowing the ultra-fast line breaker to run as a preflight.
    @inline(__always)
    static var requiresFullTextLayout: Self {
        Self(rawValue: 1 << 20)
    }
}
#endif

extension TextDrawingContext {
    func withStringDrawingContext<Result>(
        minScaleFactor: CGFloat,
        lineLimit: Int?,
        kitCache: AnyObject?,
        useNSLayoutManager: Bool,
        `do` body: (NSStringDrawingContext) -> Result
    ) -> Result {
        $ctx.access { drawingContext in
            #if canImport(Darwin)
            drawingContext.minimumScaleFactor = switch minScaleFactor {
            case 1...: 0
            case ...0: .leastNonzeroMagnitude
            default: minScaleFactor
            }
            drawingContext.scaledLineHeight = 0
            drawingContext.scaledBaselineOffset = 0
            drawingContext.maximumNumberOfLines = lineLimit.map { max($0, 1) } ?? 0
            drawingContext.cachesLayout = true
            drawingContext.layout = kitCache
            drawingContext.wantsNumberOfLineFragments = false
            drawingContext.activeRenderers = useNSLayoutManager ? .nsLayoutManager : []
            drawingContext.linkTextAttributesProvider = { attributes, _ in
                var attributes = attributes ?? [:]
                attributes[.kitForegroundColor] = nil
                return attributes
            }
            #endif
            return body(drawingContext)
        }
    }
}

@available(*, unavailable)
extension NSAttributedString.Metrics: Sendable {}

extension ResolvedStyledText {
    final package class StringDrawing: ResolvedStyledText {
        var cache: NSAttributedString.MetricsCache

        override package var drawingMargins: EdgeInsets {
            let fontMetrics = maxFontMetrics
            var margins = fontMetrics.outsets
            margins.top += lineHeightScalingAdjustment(
                lineHeightMultiple: layoutProperties.lineHeightMultiple,
                maximumLineHeight: layoutProperties.maximumLineHeight,
                minimumLineHeight: layoutProperties.minimumLineHeight
            )
            margins = margins.adding(stylePadding)
            margins.round(.up, toMultipleOf: layoutProperties.pixelLength)
            return margins
        }

        override package init(
            storage: NSAttributedString?,
            layoutProperties: TextLayoutProperties,
            layoutMargins: EdgeInsets?,
            stylePadding: EdgeInsets,
            archiveOptions: ArchivedViewInput.Value,
            isCollapsible: Bool,
            features: Text.ResolvedProperties.Features,
            suffix: ResolvedTextSuffix,
            attachments: Text.ResolvedProperties.CustomAttachments,
            styles: [_ShapeStyle_Pack.Style],
            transitions: [Text.ResolvedProperties.Transition],
            scaleFactorOverride: CGFloat?
        ) {
            let widthIsFlexible = layoutProperties.widthIsFlexible || (storage?.isDynamic == true && archiveOptions.isArchived)
            cache = NSAttributedString.MetricsCache(
                storage,
                scaleFactorOverride: scaleFactorOverride,
                lineLimit: layoutProperties.lineLimit,
                lowerLineLimit: layoutProperties.lowerLineLimit,
                minScaleFactor: layoutProperties.minScaleFactor,
                bodyHeadOutdent: layoutProperties.bodyHeadOutdent,
                pixelLength: layoutProperties.pixelLength,
                widthIsFlexible: widthIsFlexible,
                drawWithRequestedWidth: layoutProperties.hyphenationFactor != 0,
                isCollapsible: isCollapsible
            )
            super.init(
                storage: storage,
                layoutProperties: layoutProperties,
                layoutMargins: layoutMargins,
                stylePadding: stylePadding,
                archiveOptions: archiveOptions,
                isCollapsible: isCollapsible,
                features: features,
                suffix: suffix,
                attachments: attachments,
                styles: styles,
                transitions: transitions,
                scaleFactorOverride: scaleFactorOverride
            )
        }

        override package func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            cache.metrics(
                requestedSize: proposedSize.fixingUnspecifiedDimensions(at: .infinity),
                layoutMargins: layoutMargins,
                wantsNumberOfLineFragments: false,
                context: .shared
            ).size
        }

        override package func resetCache() {
            cache = NSAttributedString.MetricsCache(
                storage,
                scaleFactorOverride: scaleFactorOverride,
                lineLimit: layoutProperties.lineLimit,
                lowerLineLimit: layoutProperties.lowerLineLimit,
                minScaleFactor: layoutProperties.minScaleFactor,
                bodyHeadOutdent: layoutProperties.bodyHeadOutdent,
                pixelLength: layoutProperties.pixelLength,
                widthIsFlexible: cache.widthIsFlexible,
                drawWithRequestedWidth: layoutProperties.hyphenationFactor != 0,
                isCollapsible: cache.isCollapsible
            )
        }

        override package var majorAxis: Axis {
            .vertical
        }

        override package func drawingScale(size: CGSize) -> CGFloat {
            if let scaleFactorOverride {
                return scaleFactorOverride
            }
            guard layoutProperties.minScaleFactor != 1 else {
                return 1
            }
            return cache.metrics(
                requestedSize: size,
                layoutMargins: layoutMargins,
                wantsNumberOfLineFragments: false,
                context: .shared
            ).scale
        }

        override package func spacing() -> Spacing {
            let idealMetrics = cache.metrics(
                requestedSize: CGSize.infinity,
                layoutMargins: layoutMargins,
                wantsNumberOfLineFragments: false,
                context: .shared
            )
            return Spacing.textSpacing(
                maxFontMetrics: maxFontMetrics,
                idealMetrics: idealMetrics,
                layoutProperties: layoutProperties
            )
        }

        override package func size(in request: CGSize) -> CGSize {
            cache.metrics(
                requestedSize: request,
                layoutMargins: layoutMargins,
                wantsNumberOfLineFragments: false,
                context: .shared
            ).size
        }

        override package func metrics(
            in size: CGSize,
            layoutMargins: EdgeInsets?
        ) -> NSAttributedString.Metrics {
            cache.metrics(
                requestedSize: size,
                layoutMargins: layoutMargins ?? self.layoutMargins,
                wantsNumberOfLineFragments: true,
                context: .shared
            )
        }

        override package func size(
            in request: CGSize,
            context: TextDrawingContext
        ) -> CGSize {
            cache.metrics(
                requestedSize: request,
                layoutMargins: layoutMargins,
                wantsNumberOfLineFragments: false,
                context: context
            ).size
        }

        override package func explicitAlignment(
            _ k: AlignmentKey,
            at size: CGSize
        ) -> CGFloat? {
            if k == VerticalAlignment.lastTextBaseline.key {
                return cache.metrics(
                    requestedSize: size,
                    layoutMargins: layoutMargins,
                    wantsNumberOfLineFragments: false,
                    context: .shared
                ).lastBaseline
            } else if k == VerticalAlignment.firstTextBaseline.key {
                return cache.metrics(
                    requestedSize: size,
                    layoutMargins: layoutMargins,
                    wantsNumberOfLineFragments: false,
                    context: .shared
                ).firstBaseline
            } else if k == VerticalAlignment._firstTextLineCenter.key {
                let firstBaseline = cache.metrics(
                    requestedSize: size,
                    layoutMargins: layoutMargins,
                    wantsNumberOfLineFragments: false,
                    context: .shared
                ).firstBaseline
                return firstBaseline - maxFontMetrics.capHeight * 0.5
            } else if k == HorizontalAlignment.leadingText.key {
                return layoutMargins.leading
            } else {
                return nil
            }
        }

        override package func draw(
            in drawingArea: CGRect,
            with measuredSize: CGSize,
            applyingMarginOffsets: Bool,
            containsResolvable: Bool,
            context: TextDrawingContext,
            renderer: TextRendererBoxBase?
        ) {
            guard let storage else {
                return
            }
            let metrics = cache.metrics(
                requestedSize: measuredSize,
                layoutMargins: layoutMargins,
                wantsNumberOfLineFragments: false,
                context: .shared
            )
            let scale: CGFloat
            if let scaleFactorOverride {
                scale = scaleFactorOverride
            } else if layoutProperties.minScaleFactor == 1 {
                scale = 1
            } else {
                scale = metrics.scale
            }
            let reusableKitCache = scale == 1 && !containsResolvable
                ? cache.kitCache
                : nil
            var rect = CGRect(
                x: drawingArea.origin.x,
                y: drawingArea.origin.y + metrics.baselineAdjustment,
                width: metrics.size.width + layoutProperties.bodyHeadOutdent,
                height: metrics.size.height
            )
            if applyingMarginOffsets {
                rect = rect.inset(by: layoutMargins)
                rect.origin.x += drawingMargins.leading - layoutMargins.leading
                rect.origin.y += drawingMargins.top - layoutMargins.top
            }
            if cache.drawWithRequestedWidth, metrics.requestedWidth != .infinity {
                let availableWidth = rect.width
                let requestedWidth = metrics.requestedWidth
                let alignmentFactor: CGFloat
                switch layoutProperties.multilineTextAlignment {
                case .leading:
                    alignmentFactor = layoutProperties.layoutDirection == .rightToLeft ? 1 : 0
                case .center:
                    alignmentFactor = 0.5
                case .trailing:
                    alignmentFactor = layoutProperties.layoutDirection == .leftToRight ? 1 : 0
                }
                rect.origin.x += (availableWidth - requestedWidth) * alignmentFactor
                rect.size.width = requestedWidth
            }
            // TODO: CoreGraphicsContext.current + RB with cgStyleHandler
            #if canImport(Darwin)
            context.withStringDrawingContext(
                minScaleFactor: 1,
                lineLimit: layoutProperties.lineLimit,
                kitCache: reusableKitCache,
                useNSLayoutManager: storage.hasLinkAttributes
            ) { drawingContext in
                let drawingString = storage.scaled(by: scale)
                drawingString.draw(
                    with: rect,
                    options: [
                        .usesLineFragmentOrigin,
                        .requiresFullTextLayout,
                    ],
                    context: drawingContext
                )
            }
            #else
            _openSwiftUIPlatformUnimplementedWarning()
            #endif
        }

        override package func linkURL(
            at point: CGPoint,
            in size: CGSize
        ) -> URL? {
            CoreGlue2.shared.linkURL(at: point, in: size, stringDrawing: self)
        }
    }

    // FIXME
    package class TextLayoutManager: ResolvedStyledText {}
}

// FIXME
extension NSAttributedString {
    var hasLinkAttributes: Bool {
        var result = false
        enumerateAttribute(.kitLink, in: NSRange(location: 0, length: length)) { value, _, stop in
            // FIXME: URL.init()
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
}
