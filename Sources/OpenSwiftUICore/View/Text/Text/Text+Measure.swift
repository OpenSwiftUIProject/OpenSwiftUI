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
    }

    // TODO
    struct CacheMetrics {}

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
}
