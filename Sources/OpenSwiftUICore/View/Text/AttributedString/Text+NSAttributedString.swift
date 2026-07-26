//
//  Text+NSAttributedString.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation
package import UIFoundation_Private
#if canImport(CoreText)
import CoreText
#endif

package func makeParagraphStyle(environment: EnvironmentValues) -> NSMutableParagraphStyle {
    let layoutProperties = TextLayoutProperties(environment)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.horizontalAlignment = NSTextHorizontalAlignment(
        layoutProperties.multilineTextAlignment,
        layoutDirection: layoutProperties.layoutDirection,
        writingMode: layoutProperties.writingMode
    )
    let isBalanced = environment.paragraphTypesetting.storage == .balanced
    switch environment.textJustification.storage {
    case let .full(full):
        paragraphStyle.fullyJustified = true
        paragraphStyle.spansAllLines = full.allLines || isBalanced
    case .none:
        paragraphStyle.fullyJustified = false
        paragraphStyle.spansAllLines = isBalanced
    }
    paragraphStyle.lineBreakMode = switch layoutProperties.truncationMode {
    case .head: .byTruncatingHead
    case .tail: .byTruncatingTail
    case .middle: .byTruncatingMiddle
    }
    paragraphStyle.lineSpacing = layoutProperties.lineSpacing
    paragraphStyle.lineBreakStrategy = .standard
    if !environment.avoidsOrphans {
        paragraphStyle.lineBreakStrategy = paragraphStyle.lineBreakStrategy.subtracting(.pushOut)
    }
    paragraphStyle.lineHeightMultiple = layoutProperties.lineHeightMultiple
    paragraphStyle.maximumLineHeight = layoutProperties.maximumLineHeight
    paragraphStyle.minimumLineHeight = layoutProperties.minimumLineHeight
    let hyphenationDisabled = layoutProperties.hyphenationDisabled
    paragraphStyle.hyphenationFactor = hyphenationDisabled ? 0 : Float(layoutProperties.hyphenationFactor)
    paragraphStyle.secondaryLineBreakMode = hyphenationDisabled ? .byClipping : .byWordWrapping
    paragraphStyle.firstLineHeadIndent = layoutProperties.bodyHeadOutdent
    if environment.bodyHeadOutdent > 0 {
        paragraphStyle.baseWritingDirection = environment.writingMode == .verticalRightToLeft
            ? .leftToRight
            : NSWritingDirection(layoutProperties.layoutDirection)
    }
    paragraphStyle.allowsDefaultTighteningForTruncation = environment.allowsTightening
    return paragraphStyle
}

extension NSAttributedString.Key {
    package static let resolvableAttributeConfiguration: NSAttributedString.Key = .init("OpenSwiftUI.resolvableAttributeConfiguration")

    package static let _textScale: NSAttributedString.Key = .init("NSTextScale")

    #if canImport(CoreText)
    package static let _textScaleRatio: NSAttributedString.Key = .init(kCTTextScaleRatioAttributeName as String)
    #endif

    package static let _textScaleStaticWeightMatching: NSAttributedString.Key = .init("NSTextScaleStaticWeightMatching")
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
        var container = Text.Resolved()
        container.includeDefaultAttributes = includeDefaultAttributes
        container.idiom = idiom
        var configuration = environment.typesettingConfiguration
        if !storage.allowsTypesettingLanguage() {
            configuration.language = .automatic
        }
        container.style.typesettingConfiguration = configuration
        resolve(into: &container, in: environment, with: options)
        let attributedString = container.attributedString
        if let attributedString {
            _ = attributedString.resolveUpdateSchedule(recalculate: true)
        }
        return attributedString
    }

    package func resolveAttributedStringAndProperties(
        in environment: EnvironmentValues,
        includeDefaultAttributes: Bool = true,
        options: Text.ResolveOptions = [.includeSupportForRepeatedResolution],
        idiom: AnyInterfaceIdiom? = nil
    ) -> (NSAttributedString?, Text.ResolvedProperties) {
        var container = Text.Resolved()
        container.includeDefaultAttributes = includeDefaultAttributes
        container.idiom = idiom
        var configuration = environment.typesettingConfiguration
        if !storage.allowsTypesettingLanguage() {
            configuration.language = .automatic
        }
        container.style.typesettingConfiguration = configuration
        if options.contains([.allowsKeyColors, .allowsTextSuffix]) {
            let styles = environment.textSuffix.styles
            if !styles.isEmpty {
                container.properties.styles = styles
                container.properties.features = .keyColor
            }
        }
        resolve(into: &container, in: environment, with: options)
        let attributedString = container.attributedString
        container.properties.suffix = .none
        if options.contains(.allowsTextSuffix) {
            let suffix = environment.textSuffix
            switch suffix {
            case .none:
                break
            case .truncated:
                container.properties.suffix = suffix
            case let .alwaysVisible(line, _):
                let offset = attributedString?.length ?? 0
                // TODO: append ConcreteCustomTextAttachment(LineAttachment(line:bounds:))
                _openSwiftUIUnimplementedWarning()
                container.properties.registerCustomAttachment(at: offset)
                container.properties.suffix = suffix
            }
        }
        if let attributedString {
            _ = attributedString.resolveUpdateSchedule(recalculate: true)
        }
        return (attributedString, container.properties)
    }
}

extension EnvironmentValues {
    package func resolveNSAttributes(
        includeDefaultAttributes: Bool = true,
        options: Text.ResolveOptions = []
    ) -> [NSAttributedString.Key: Any] {
        var properties = Text.ResolvedProperties()
        let style = Text.Style()
        return style.nsAttributes(
            content: nil,
            environment: self,
            includeDefaultAttributes: includeDefaultAttributes,
            with: options,
            properties: &properties
        )
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
        var attributes: [NSAttributedString.Key: Any] = [:]
        let isRedacted = environment.shouldRedactContent
        var modifiers = environment.fontModifiers
        if !clearedFontModifiers.isEmpty {
            modifiers = modifiers.filter { !clearedFontModifiers.contains($0.typeID) }
        }
        modifiers.append(contentsOf: fontModifiers)
        properties.paragraph.compositionLanguage = .unset
        typesettingConfiguration.language.apply(
            content: content,
            locale: environment.locale,
            to: &attributes,
            modifiers: &modifiers,
            properties: &properties
        )
        typesettingConfiguration.languageAwareLineHeightRatio.apply(to: &modifiers)
        if let font = baseFont.resolve(in: environment, includeDefaultAttributes: includeDefaultAttributes) {
            attributes[.kitFont] = font.platformFont(in: environment, modifiers: modifiers)
        } else {
            attributes[.kitFont] = nil
        }
        if let color = color.resolve(
            in: environment,
            with: options,
            properties: &properties,
            includeDefaultAttributes: includeDefaultAttributes && !options.contains(.writeAuxiliaryMetadata)
        ) {
            attributes[.kitForegroundColor] = color.kitColor
            properties.addColor(color)
        }
        if let backgroundColor {
            let resolved = backgroundColor.resolve(in: environment)
            attributes[.kitBackgroundColor] = resolved.kitColor
            properties.addColor(resolved)
        }
        let baselineOffsetValue = baselineOffset ?? environment.defaultBaselineOffset
        if baselineOffsetValue != 0 {
            attributes[.kitBaselineOffset] = baselineOffsetValue
        }
        let kerningValue = kerning ?? environment.defaultKerning
        if kerningValue != 0 {
            attributes[.kitKern] = kerningValue
        }
        let trackingValue = tracking ?? environment.defaultTracking
        if trackingValue != 0 {
            attributes[.kitTracking] = trackingValue
        }
        return attributes
    }
}
