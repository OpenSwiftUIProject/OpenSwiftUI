//
//  Text+AttributedString.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 9E031884FB9C9CDFD774AD0758E0F537 (SwiftUICore)

public import Foundation
#if canImport(CoreText)
public import CoreText
#endif
#if canImport(Accessibility)
public import Accessibility
#endif

// TODO: AttributedStringTextStorage

// MARK: - AttributeScopes.OpenSwiftUIAttributes

@available(OpenSwiftUI_v3_0, *)
extension AttributeScopes {

    /// A property for accessing the attribute scopes defined by OpenSwiftUI.
    public var openSwiftUI: OpenSwiftUIAttributes.Type {
        self
    }

    /// Attribute scopes defined by OpenSwiftUI.
    public struct OpenSwiftUIAttributes: AttributeScope {

        /// A property for accessing a font attribute.
        public let font: FontAttribute

        /// A property for accessing a foreground color attribute.
        public let foregroundColor: ForegroundColorAttribute

        /// A property for accessing a background color attribute.
        public let backgroundColor: BackgroundColorAttribute

        @_spi(_)
        @available(*, deprecated, message: "Use strikethroughStyle attribute")
        public let strikethroughColor: StrikethroughColorAttribute

        /// A property for accessing a strikethrough style attribute.
        public let strikethroughStyle: StrikethroughStyleAttribute

        /// A property for accessing an underline style attribute.
        public let underlineStyle: UnderlineStyleAttribute

        @_spi(_)
        @available(*, deprecated, message: "Use underlineStyle attribute")
        public let underlineColor: UnderlineColorAttribute

        @_spi(Private)
        @available(OpenSwiftUI_v4_0, *)
        public let encapsulation: EncapsulationAttribute

        /// A property for accessing a kerning attribute.
        public let kern: KerningAttribute

        /// A property for accessing a tracking attribute.
        public let tracking: TrackingAttribute

        /// A property for accessing a baseline offset attribute.
        public let baselineOffset: BaselineOffsetAttribute

        #if canImport(CoreText)
        @_spi(Private)
        @available(OpenSwiftUI_v4_0, *)
        public let glyphInfo: GlyphInfoAttribute
        #endif

        @_spi(Private)
        @available(OpenSwiftUI_v5_0, *)
        public let textScale: TextScaleAttribute

        package let superscript: SuperscriptAttribute

        @_spi(Private)
        @available(OpenSwiftUI_v5_0, *)
        public let customAttributes: CustomContainerAttribute

        package let fontModifiers: FontModifiersAttribute

        #if canImport(CoreText)
        @_spi(Private)
        @available(OpenSwiftUI_v6_0, *)
        public let adaptiveImageGlyph: AdaptiveImageGlyphAttribute
        #endif

        package let interpolationStrategy: InterpolationStrategy

        @_spi(_)
        @available(*, deprecated, message: "Use strikethroughColor attribute")
        public let privateStrikethroughColor: PrivateStrikethroughColorAttribute

        @_spi(_)
        @available(*, deprecated, message: "Use underlineColor attribute")
        public let privateUnderlineColor: PrivateUnderlineColorAttribute
        
        #if canImport(Accessibility)
        /// A property for accessing attributes defined by the Accessibility framework.
        public let accessibility: AccessibilityAttributes
        #endif

        /// A property for accessing attributes defined by the Foundation
        /// framework.
        ///
        /// - Note: Not all attributes defined in this scope have an effect when
        /// used in OpenSwiftUI views. For a description of supported Foundation
        /// attribtutes and their effects, see
        /// ``Text/init(_:)-(AttributedString)``.
        public let foundation: FoundationAttributes
    }
}

@available(*, unavailable)
extension AttributeScopes.OpenSwiftUIAttributes: Sendable {}

// MARK: - AttributeScopes.OpenSwiftUIAttributes + AttributedStringKey

@available(OpenSwiftUI_v3_0, *)
extension AttributeScopes.OpenSwiftUIAttributes {

    @frozen
    public enum FontAttribute: AttributedStringKey {
        public typealias Value = Font
        public static let name: String = "OpenSwiftUI.Font"
    }

    @frozen
    public enum ForegroundColorAttribute: AttributedStringKey {
        public typealias Value = Color
        public static let name: String = "OpenSwiftUI.ForegroundColor"
    }

    @frozen
    public enum BackgroundColorAttribute: AttributedStringKey {
        public typealias Value = Color
        public static let name: String = "OpenSwiftUI.BackgroundColor"
    }

    @frozen
    public enum StrikethroughStyleAttribute: AttributedStringKey {
        public typealias Value = Text.LineStyle
        public static let name: String = "OpenSwiftUI.StrikethroughStyle"
    }

    @_spi(_)
    @available(*, deprecated, message: "Use StrikethroughStyleAttribute")
    @frozen
    public enum StrikethroughColorAttribute: AttributedStringKey {
        public typealias Value = Color
        public static let name: String = "OpenSwiftUI.StrikethroughColor"
    }

    @frozen
    public enum UnderlineStyleAttribute: AttributedStringKey {
        public typealias Value = Text.LineStyle
        public static let name: String = "OpenSwiftUI.UnderlineStyle"
    }

    @_spi(_)
    @available(*, deprecated, message: "Use UnderlineStyleAttribute")
    @frozen
    public enum UnderlineColorAttribute: AttributedStringKey {
        public typealias Value = Color
        public static let name: String = "OpenSwiftUI.UnderlineColor"
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    @frozen
    public enum EncapsulationAttribute: AttributedStringKey {
        public typealias Value = Text.Encapsulation
        public static let name: String = "OpenSwiftUI.Encapsulation"
    }

    @frozen
    public enum KerningAttribute: CodableAttributedStringKey {
        public typealias Value = CGFloat
        public static let name: String = "OpenSwiftUI.Kern"
    }

    @frozen
    public enum TrackingAttribute: CodableAttributedStringKey {
        public typealias Value = CGFloat
        public static let name: String = "OpenSwiftUI.Tracking"
    }

    @frozen
    public enum BaselineOffsetAttribute: CodableAttributedStringKey {
        public typealias Value = CGFloat
        public static let name: String = "OpenSwiftUI.BaselineOffset"
    }

    #if canImport(CoreText)
    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public enum GlyphInfoAttribute: AttributedStringKey {
        @_spi(Private)
        public typealias Value = CTGlyphInfo
        @_spi(Private)
        public static let name: String = "OpenSwiftUI.GlyphInfo"
    }
    #endif

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    @frozen
    public enum TextScaleAttribute: AttributedStringKey {
        public typealias Value = Text.Scale
        public static let name: String = "OpenSwiftUI.TextScale"
    }

    package enum SuperscriptAttribute: AttributedStringKey {
        package typealias Value = Text.Superscript
        package static let name: String = "OpenSwiftUI.Superscript"
    }

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    @frozen
    public enum CustomContainerAttribute: AttributedStringKey {
        public typealias Value = Text.CustomAttributes
        public static let name: String = "OpenSwiftUI.CustomAttributes"
    }

    package enum FontModifiersAttribute: AttributedStringKey {
        package typealias Value = [AnyFontModifier]
        package static let name: String = "OpenSwiftUI.FontModifiers"
    }

    #if canImport(CoreText)
    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    @frozen
    public enum AdaptiveImageGlyphAttribute: AttributedStringKey {
        public typealias Value = AttributedString.AdaptiveImageGlyph
        
        public static let name: String = "OpenSwiftUI.AdaptiveImageGlyph"

        public static var inheritedByAddedText: Bool = false

        public static var runBoundaries: AttributedString.AttributeRunBoundaries? {
            .character(.nsAttachment)
        }
    }
    #endif

    package enum InterpolationStrategy: CodableAttributedStringKey, Codable, Hashable {
        package typealias Value = InterpolationStrategy
        package static let name: String = "OpenSwiftUI.InterpolationStrategy"

        private enum CodingKeys: CodingKey {
            case animated
            case unanimated
        }

        private enum AnimatedCodingKeys: CodingKey {}

        private enum UnanimatedCodingKeys: CodingKey {}

        case animated
        case unanimated

        package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .animated:
                _ = container.nestedContainer(keyedBy: AnimatedCodingKeys.self, forKey: .animated)
            case .unanimated:
                _ = container.nestedContainer(keyedBy: UnanimatedCodingKeys.self, forKey: .unanimated)
            }
        }

        package init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let keys = container.allKeys
            guard keys.count == 1 else {
                throw DecodingError.typeMismatch(
                    Self.self,
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid number of keys found, expected one."
                    )
                )
            }
            switch keys[0] {
            case .animated:
                _ = try container.nestedContainer(keyedBy: AnimatedCodingKeys.self, forKey: .animated)
                self = .animated
            case .unanimated:
                _ = try container.nestedContainer(keyedBy: UnanimatedCodingKeys.self, forKey: .unanimated)
                self = .unanimated
            }
        }
    }

    @_spi(_)
    @available(*, deprecated, message: "Use UnderlineColorAttribute")
    @frozen
    public enum PrivateUnderlineColorAttribute: AttributedStringKey {
        public typealias Value = Color
        public static let name: String = "OpenSwiftUI.UnderlineColor"
    }


    @_spi(_)
    @available(*, deprecated, message: "Use StrikethroughColorAttribute")
    @frozen
    public enum PrivateStrikethroughColorAttribute: AttributedStringKey {
        public typealias Value = Color
        public static let name: String = "OpenSwiftUI.StrikethroughColor"
    }
}

#if canImport(CoreText)
@_spi(Private)
@available(*, unavailable)
extension AttributeScopes.OpenSwiftUIAttributes.GlyphInfoAttribute: Sendable {}
#endif

@available(OpenSwiftUI_v3_0, *)
extension AttributeDynamicLookup {
    public subscript<T>(
        dynamicMember keyPath: KeyPath<AttributeScopes.OpenSwiftUIAttributes, T>
    ) -> T where T: AttributedStringKey {
        self[T.self]
    }
}

package typealias NSAttributedStringAttributes = [NSAttributedString.Key: Any]

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension AttributedString {
    public func nsAttributedString(in environment: EnvironmentValues = .init()) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(self)
        var properties = Text.ResolvedProperties()
        attributedString.convertToPlatformStyled(
            style: .init(),
            environment: environment,
            includeDefaultAttributes: false,
            options: Text.ResolveOptions(for: environment),
            properties: &properties
        )
        if environment.sensitiveContent {
            properties.addSensitive()
        }
        return attributedString
    }
}

extension NSMutableAttributedString {
    func convertToPlatformStyled(
        style: Text.Style,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) {
        enumerateAttributes(
            in: NSRange(location: 0, length: length),
            options: []
        ) { attributes, range, _ in
            var attributes = attributes
            var style = style
            attributes.transferAttributedStringStyles(to: &style)
            let originalString = attributedSubstring(from: range).string
            let platformAttributes = style.nsAttributes(
                content: { originalString },
                environment: environment,
                includeDefaultAttributes: includeDefaultAttributes,
                with: options,
                properties: &properties
            )
            var mergedAttributes = attributes
            mergedAttributes.merge(platformAttributes) { _, new in new }
            setAttributes(mergedAttributes, range: range)
            var resolvedString = originalString.caseConvertedIfNeeded(environment)
            if environment.shouldRedactContent {
                resolvedString = String(repeating: "􀮷", count: resolvedString.count)
            }
            replaceCharacters(in: range, with: resolvedString)
        }
    }
}

@available(OpenSwiftUI_v6_0, *)
extension Dictionary where Key == NSAttributedString.Key, Value == Any {
    fileprivate mutating func transferAttributedStringStyles(to style: inout Text.Style) {
        let fontKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.FontAttribute.name)
        if let font = self[fontKey] as? Font {
            style.baseFont = .explicit(font)
            self[fontKey] = nil
        }

        let foregroundColorKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.ForegroundColorAttribute.name)
        if let foregroundColor = self[foregroundColorKey] as? Color {
            style.color = .explicit(AnyShapeStyle(foregroundColor))
            self[foregroundColorKey] = nil
        }

        let backgroundColorKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.BackgroundColorAttribute.name)
        if let backgroundColor = self[backgroundColorKey] as? Color {
            style.backgroundColor = backgroundColor
            self[backgroundColorKey] = nil
        }

        let strikethroughStyleKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.StrikethroughStyleAttribute.name)
        if let strikethroughStyle = self[strikethroughStyleKey] as? Text.LineStyle {
            style.strikethrough = .explicit(strikethroughStyle)
            self[strikethroughStyleKey] = nil
        }

        let strikethroughColorKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.StrikethroughColorAttribute.name)
        if let strikethroughColor = self[strikethroughColorKey] as? Color {
            switch style.strikethrough {
            case .implicit, .default:
                style.strikethrough = .explicit(.init(color: strikethroughColor))
            case .explicit:
                break
            }
            self[strikethroughColorKey] = nil
        }

        let underlineStyleKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.UnderlineStyleAttribute.name)
        if let underlineStyle = self[underlineStyleKey] as? Text.LineStyle {
            style.underline = .explicit(underlineStyle)
            self[underlineStyleKey] = nil
        }

        let underlineColorKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.UnderlineColorAttribute.name)
        if let underlineColor = self[underlineColorKey] as? Color {
            switch style.underline {
            case .implicit, .default:
                style.underline = .explicit(.init(color: underlineColor))
            case .explicit:
                break
            }
            self[underlineColorKey] = nil
        }

        let encapsulationKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.EncapsulationAttribute.name)
        if let encapsulation = self[encapsulationKey] as? Text.Encapsulation {
            style.encapsulation = encapsulation
            self[encapsulationKey] = nil
        }

        let kerningKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.KerningAttribute.name)
        if let kern = self[kerningKey] as? CGFloat {
            style.kerning = kern
            self[kerningKey] = nil
        }

        let trackingKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.TrackingAttribute.name)
        if let tracking = self[trackingKey] as? CGFloat {
            style.tracking = tracking
            self[trackingKey] = nil
        }

        let baselineOffsetKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.BaselineOffsetAttribute.name)
        if let baselineOffset = self[baselineOffsetKey] as? CGFloat {
            style.baselineOffset = baselineOffset
            self[baselineOffsetKey] = nil
        }

        #if canImport(CoreText)
        let glyphInfoKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.GlyphInfoAttribute.name)
        if let glyphInfo = self[glyphInfoKey],
           CFGetTypeID(glyphInfo as AnyObject) == CTGlyphInfoGetTypeID() {
            let glyphInfo: CTGlyphInfo = glyphInfo as! CTGlyphInfo
            style.glyphInfo = glyphInfo
            self[glyphInfoKey] = nil
        }
        #endif

        let textScaleKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.TextScaleAttribute.name)
        if let textScale = self[textScaleKey] as? Text.Scale {
            style.scale = textScale
            self[textScaleKey] = nil
        }

        let superscriptKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.SuperscriptAttribute.name)
        if self[superscriptKey] is Text.Superscript {
            style.superscript = .default
            self[superscriptKey] = nil
        }

        let customAttributesKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.CustomContainerAttribute.name)
        if let customAttributes = self[customAttributesKey] as? Text.CustomAttributes {
            style.customAttributes = customAttributes.attributes
            self[customAttributesKey] = nil
        }

        let fontModifiersKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.FontModifiersAttribute.name)
        if let fontModifiers = self[fontModifiersKey] as? [AnyFontModifier] {
            style.fontModifiers.append(contentsOf: fontModifiers)
            self[fontModifiersKey] = nil
        }

        let inlinePresentationIntentKey = NSAttributedString.Key.inlinePresentationIntent
        if let inlinePresentationIntent = self[inlinePresentationIntentKey] as? UInt {
            if (inlinePresentationIntent & (1 << 0)) != 0 {
                style.fontModifiers.append(.static(Font.ItalicModifier.self))
            }
            if (inlinePresentationIntent & (1 << 1)) != 0 {
                style.fontModifiers.append(.static(Font.BoldModifier.self))
            }
            if (inlinePresentationIntent & (1 << 2)) != 0 {
                style.fontModifiers.append(.static(Font.MonospacedModifier.self))
            }
            if (inlinePresentationIntent & (1 << 5)) != 0 {
                style.strikethrough = .explicit(.single)
            }
            self[inlinePresentationIntentKey] = nil
        }

        if style.typesettingConfiguration.language == .automatic {
            let languageIdentifierKey = NSAttributedString.Key.languageIdentifier
            if let languageIdentifier = self[languageIdentifierKey] as? String {
                style.typesettingConfiguration.language = .explicit(Locale.Language(identifier: languageIdentifier))
            }
        }

        #if canImport(CoreText)
        let adaptiveImageGlyphKey = NSAttributedString.Key(AttributeScopes.OpenSwiftUIAttributes.AdaptiveImageGlyphAttribute.name)
        if let adaptiveImageGlyph = self[adaptiveImageGlyphKey] as? AttributedString.AdaptiveImageGlyph {
            style.adaptiveImageGlyph = adaptiveImageGlyph
            self[adaptiveImageGlyphKey] = nil
        }
        #endif
    }
}

// FIXME
@available(OpenSwiftUI_v1_0, *)
extension Text {
    package struct Superscript: Hashable, Sendable {
        package static let `default`: Text.Superscript = .init(0)

        package var value: Int

        package init(_ value: Int) {
            self.value = value
        }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public struct CustomAttributes: @unchecked Sendable, Hashable {
        public init() {}

        package var attributes: [TextAttributeModifierBase] = []
    }
}

package class TextAttributeModifierBase: AnyTextModifier, Hashable {
    package static func == (lhs: TextAttributeModifierBase, rhs: TextAttributeModifierBase) -> Bool {
        lhs === rhs
    }

    package func hash(into hasher: inout Hasher) {
        _openSwiftUIUnimplementedWarning()
    }
}
