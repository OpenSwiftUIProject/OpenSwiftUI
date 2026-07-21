//
//  Text+NSAttributedString.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation
package import UIFoundation_Private
#if canImport(CoreText)
package import CoreText
#endif

package func makeParagraphStyle(environment: EnvironmentValues) -> NSMutableParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    #if canImport(Darwin)
    // TODO
    #endif
    return paragraphStyle
}

#if canImport(CoreText)
@_silgen_name("kCTUIFontTextStyleTitle0")
let kCTTextScaleRatioAttributeName: CFString
#endif

extension NSAttributedString.Key {
    static let resolvableAttributeConfiguration: NSAttributedString.Key = .init("OpenSwiftUI.resolvableAttributeConfiguration")

    static let _textScale: NSAttributedString.Key = .init("NSTextScale")

    #if canImport(CoreText)
    static let _textScaleRatio: NSAttributedString.Key = .init(kCTTextScaleRatioAttributeName as String)
    #endif

    static let _textScaleStaticWeightMatching: NSAttributedString.Key = .init("NSTextScaleStaticWeightMatching")
}

extension NSAttributedString {
    package func firstAttribute<T>(_ type: T.Type) -> T? where T: ResolvableStringAttribute {
        _openSwiftUIUnimplementedFailure()
    }
}

extension NSMutableAttributedString {
    package func addResolvableAttributes(with config: ResolvableAttributeConfiguration) {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolveAttributes(in context: ResolvableStringResolutionContext) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Text {
    package func resolveAttributedString(
        in environment: EnvironmentValues,
        includeDefaultAttributes: Bool = true,
        options: Text.ResolveOptions = [.includeSupportForRepeatedResolution],
        idiom: AnyInterfaceIdiom? = nil
    ) -> NSAttributedString? {
        // FIXME
        _openSwiftUIUnimplementedWarning()
        var container = Text.Resolved()
        container.includeDefaultAttributes = includeDefaultAttributes
        container.idiom = idiom
        // container.properties = options
        resolve(into: &container, in: environment, with: options)
        if let attributedString = container.attributedString {
            // attributedString.resolveUpdateSchedule(recalculate: true )
        }
        return container.attributedString
    }

    package func resolveAttributedStringAndProperties(
        in environment: EnvironmentValues,
        includeDefaultAttributes: Bool = true,
        options: Text.ResolveOptions = [.includeSupportForRepeatedResolution],
        idiom: AnyInterfaceIdiom? = nil
    ) -> (NSAttributedString?, Text.ResolvedProperties) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension EnvironmentValues {
    package func resolveNSAttributes(
        includeDefaultAttributes: Bool = true,
        options: Text.ResolveOptions = []
    ) -> [NSAttributedString.Key: Any] {
        _openSwiftUIUnimplementedFailure()
    }
}

extension NSAttributedString {
    package func scaled(by factor: CGFloat) -> NSAttributedString {
        guard factor != 1.0 else {
            return self
        }
        #if canImport(Darwin)
        return _ui_attributedSubstring(
            from: NSRange(location: 0, length: length),
            scaledBy: factor
        )
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return self
        #endif
    }

    package struct EncodedFontMetrics {
        package var capHeight: CGFloat, ascender: CGFloat, descender: CGFloat, leading: CGFloat
        package var outsets: EdgeInsets

        init(capHeight: CGFloat, ascender: CGFloat, descender: CGFloat, leading: CGFloat, outsets: EdgeInsets) {
            self.capHeight = capHeight
            self.ascender = ascender
            self.descender = descender
            self.leading = leading
            self.outsets = outsets
        }

        init() {
            self.capHeight = .zero
            self.ascender = .zero
            self.descender = .zero
            self.leading = .zero
            self.outsets = .zero
        }
    }

    package var maxFontMetrics: EncodedFontMetrics {
        #if canImport(CoreText)
        var capHeight: CGFloat = 0
        var ascender: CGFloat = 0
        var descender: CGFloat = 0
        var leading: CGFloat?
        var outsets = EdgeInsets.zero
        let hasOversizedScalars = string.rangeOfCharacter(from: Self.oversizedScalars) != nil
        let usesTextRenderingMetrics = Semantics.TextRenderingMetrics.isEnabled
        enumerateAttribute(
            .kitFont,
            in: NSRange(location: 0, length: length),
            options: .longestEffectiveRangeNotRequired
        ) { value, _, _ in
            guard let value else {
                return
            }
            let font = value as! CTFont
            let fontAscender = font.ascender
            let fontDescender = font.descender
            capHeight = max(capHeight, font.capHeight)
            ascender = max(ascender, fontAscender)
            descender = max(descender, fontDescender)
            leading = leading.map { max($0, font.leading) } ?? font.leading
            if hasOversizedScalars || font.mayRequireLanguageAwareOutsets {
                var left: CGFloat = 0
                var top: CGFloat = 0
                var right: CGFloat = 0
                var bottom: CGFloat = 0
                if CTFontGetLanguageAwareOutsets(font, &left, &top, &right, &bottom) {
                    outsets.top = max(outsets.top, top)
                    outsets.leading = max(outsets.leading, left)
                    outsets.bottom = max(outsets.bottom, bottom)
                    outsets.trailing = max(outsets.trailing, right)
                    return
                }
            }
            if usesTextRenderingMetrics, !font.isSystemUIFont {
                var clippingAscender = fontAscender
                var clippingDescender = fontDescender
                if CTFontGetClippingMetrics(font, &clippingAscender, &clippingDescender) {
                    outsets.top = max(outsets.top, max(0, clippingAscender - fontAscender))
                    outsets.bottom = max(outsets.bottom, max(0, clippingDescender - fontDescender))
                }
            }
        }
        return EncodedFontMetrics(
            capHeight: capHeight,
            ascender: ascender,
            descender: -descender,
            leading: leading ?? 0,
            outsets: outsets
        )
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return EncodedFontMetrics()
        #endif
    }
}

extension Text.Style {
    package func nsAttributes(
        content: (() -> String)?,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        with options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> [NSAttributedString.Key: Any] {
        _openSwiftUIUnimplementedWarning()
        return [:]
    }
}
