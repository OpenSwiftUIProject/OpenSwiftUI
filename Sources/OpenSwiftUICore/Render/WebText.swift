//
//  WebText.swift
//  OpenSwiftUICore
//

#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
public import Foundation
public import OpenCoreGraphicsShims
#else
package import Foundation
package import OpenCoreGraphicsShims
#endif

// MARK: - Static text measurement

package struct StaticTextStyle: Hashable {
    package var pointSize: CGFloat
    package var weight: CGFloat

    package init(pointSize: CGFloat, weight: CGFloat) {
        self.pointSize = pointSize
        self.weight = weight
    }
}

package struct StaticTextMeasurementRequest: Equatable {
    package var text: String
    package var style: StaticTextStyle
    package var proposedSize: CGSize
    package var lineLimit: Int?

    package init(
        text: String,
        style: StaticTextStyle,
        proposedSize: CGSize,
        lineLimit: Int?
    ) {
        self.text = text
        self.style = style
        self.proposedSize = proposedSize
        self.lineLimit = lineLimit
    }
}

package struct StaticTextMetrics: Equatable {
    package var size: CGSize
    package var firstBaseline: CGFloat
    package var lastBaseline: CGFloat
    package var numberOfLines: UInt
    package var hasTruncatedRanges: Bool

    package init(
        size: CGSize,
        firstBaseline: CGFloat,
        lastBaseline: CGFloat,
        numberOfLines: UInt,
        hasTruncatedRanges: Bool = false
    ) {
        self.size = size
        self.firstBaseline = firstBaseline
        self.lastBaseline = lastBaseline
        self.numberOfLines = numberOfLines
        self.hasTruncatedRanges = hasTruncatedRanges
    }
}

package final class StaticTextMeasurementProvider {
    package let measure: (StaticTextMeasurementRequest) -> StaticTextMetrics

    package init(
        measure: @escaping (StaticTextMeasurementRequest) -> StaticTextMetrics
    ) {
        self.measure = measure
    }
}

private struct StaticTextMeasurementProviderKey: EnvironmentKey {
    static var defaultValue: StaticTextMeasurementProvider? { nil }
}

extension EnvironmentValues {
    package var staticTextMeasurementProvider: StaticTextMeasurementProvider? {
        get { self[StaticTextMeasurementProviderKey.self] }
        set { self[StaticTextMeasurementProviderKey.self] = newValue }
    }
}

extension NSAttributedString.Key {
    package static let openSwiftUIStaticTextStyle = NSAttributedString.Key(
        "OpenSwiftUI.StaticTextStyle"
    )

    package static let openSwiftUIStaticTextForegroundColor = NSAttributedString.Key(
        "OpenSwiftUI.StaticTextForegroundColor"
    )
}

package struct StaticResolvedTextRun {
    package var text: String
    package var style: StaticTextStyle
    package var color: Color.Resolved
}

extension NSAttributedString {
    package var staticSingleLineTextStyle: StaticTextStyle? {
        guard length > 0,
              !string.contains(where: { $0.isNewline })
        else {
            return nil
        }
        let fullRange = NSRange(location: 0, length: length)
        var effectiveRange = NSRange()
        guard let style = attribute(
            .openSwiftUIStaticTextStyle,
            at: 0,
            effectiveRange: &effectiveRange
        ) as? StaticTextStyle,
              effectiveRange == fullRange,
              !hasUnsupportedStaticTextAttributes(in: fullRange)
        else {
            return nil
        }
        return style
    }

    package var staticSingleLineRun: StaticResolvedTextRun? {
        guard let style = staticSingleLineTextStyle else {
            return nil
        }
        let fullRange = NSRange(location: 0, length: length)
        var effectiveRange = NSRange()
        guard let color = attribute(
            .openSwiftUIStaticTextForegroundColor,
            at: 0,
            effectiveRange: &effectiveRange
        ) as? Color.Resolved,
              effectiveRange == fullRange
        else {
            return nil
        }
        return StaticResolvedTextRun(text: string, style: style, color: color)
    }

    private func hasUnsupportedStaticTextAttributes(in range: NSRange) -> Bool {
        var foundUnsupportedAttribute = false
        enumerateAttributes(in: range) { attributes, _, stop in
            if attributes[.kitAttachment] != nil ||
                attributes[.kitBaselineOffset] != nil ||
                attributes[.kitKern] != nil ||
                attributes[.kitTracking] != nil ||
                attributes[.kitShadow] != nil ||
                attributes[.kitUnderlineStyle] != nil ||
                attributes[.kitStrikethroughStyle] != nil
            {
                foundUnsupportedAttribute = true
                stop.pointee = true
            }
        }
        return foundUnsupportedAttribute
    }
}

#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
// MARK: - Web renderer SPI

/// A platform-neutral font description understood by the web renderer.
@_spi(WebRenderer)
public struct _WebTextStyle: Equatable {
    public var pointSize: CGFloat
    public var weight: CGFloat

    public init(pointSize: CGFloat, weight: CGFloat) {
        self.pointSize = pointSize
        self.weight = weight
    }

    package init(_ style: StaticTextStyle) {
        self.init(pointSize: style.pointSize, weight: style.weight)
    }

    package var staticStyle: StaticTextStyle {
        StaticTextStyle(pointSize: pointSize, weight: weight)
    }
}

/// The input to the web renderer's synchronous text measurement callback.
@_spi(WebRenderer)
public struct _WebTextMeasurementRequest: Equatable {
    public var text: String
    public var style: _WebTextStyle
    public var proposedSize: CGSize
    public var lineLimit: Int?

    public init(
        text: String,
        style: _WebTextStyle,
        proposedSize: CGSize,
        lineLimit: Int?
    ) {
        self.text = text
        self.style = style
        self.proposedSize = proposedSize
        self.lineLimit = lineLimit
    }

    package init(_ request: StaticTextMeasurementRequest) {
        self.init(
            text: request.text,
            style: _WebTextStyle(request.style),
            proposedSize: request.proposedSize,
            lineLimit: request.lineLimit
        )
    }
}

/// Text metrics returned synchronously by the web renderer.
@_spi(WebRenderer)
public struct _WebTextMetrics: Equatable {
    public var size: CGSize
    public var firstBaseline: CGFloat
    public var lastBaseline: CGFloat
    public var numberOfLines: UInt
    public var hasTruncatedRanges: Bool

    public init(
        size: CGSize,
        firstBaseline: CGFloat,
        lastBaseline: CGFloat,
        numberOfLines: UInt,
        hasTruncatedRanges: Bool = false
    ) {
        self.size = size
        self.firstBaseline = firstBaseline
        self.lastBaseline = lastBaseline
        self.numberOfLines = numberOfLines
        self.hasTruncatedRanges = hasTruncatedRanges
    }

    package var staticMetrics: StaticTextMetrics {
        StaticTextMetrics(
            size: size,
            firstBaseline: firstBaseline,
            lastBaseline: lastBaseline,
            numberOfLines: numberOfLines,
            hasTruncatedRanges: hasTruncatedRanges
        )
    }
}

@available(*, unavailable)
extension _WebTextStyle: Sendable {}

@available(*, unavailable)
extension _WebTextMeasurementRequest: Sendable {}

@available(*, unavailable)
extension _WebTextMetrics: Sendable {}
#endif
