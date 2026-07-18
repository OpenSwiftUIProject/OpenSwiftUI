//
//  Text+AttributedString.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9E031884FB9C9CDFD774AD0758E0F537 (SwiftUICore)

public import Foundation
#if canImport(CoreText)
public import CoreText
#endif
#if canImport(Accessibility)
public import Accessibility
#endif
import UIFoundation_Private

// MARK: - Text + AttributedString

@available(OpenSwiftUI_v3_0, *)
extension Text {

    /// Creates a text view that displays styled attributed content.
    ///
    /// ### Format text by combining attributes and view modifiers
    ///
    /// Use this initializer to style text according to attributes found in the
    /// specified
    /// [AttributedString](https://developer.apple.com/documentation/Foundation/AttributedString).
    /// Attributes in the attributed string take precedence over styles added by
    /// view modifiers. For example, the attributed text in the following
    /// example appears in blue, despite the use of the
    /// ``View/foregroundColor(_:)`` modifier to use red throughout the enclosing
    /// ``VStack``:
    ///
    ///     var content: AttributedString {
    ///         var attributedString = AttributedString("Blue text")
    ///         attributedString.foregroundColor = .blue
    ///         return attributedString
    ///     }
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Text(content)
    ///             Text("Red text")
    ///         }
    ///         .foregroundColor(.red)
    ///     }
    ///
    /// ![A vertical stack of two text views, the top labeled Blue Text with a
    /// blue font color, and the bottom labeled Red Text with a red font
    /// color.](SwiftUI-Text-init-attributed.png)
    ///
    /// OpenSwiftUI combines text attributes with OpenSwiftUI modifiers whenever
    /// possible. For example, the following listing creates text that is both
    /// bold and red:
    ///
    ///     var content: AttributedString {
    ///         var content = AttributedString("Some text")
    ///         content.inlinePresentationIntent = .stronglyEmphasized
    ///         return content
    ///     }
    ///
    ///     var body: some View {
    ///         Text(content).foregroundColor(Color.red)
    ///     }
    ///
    /// ### Supported Foundation attributes
    ///
    /// An OpenSwiftUI ``Text`` view renders most of the styles defined by the
    /// Foundation attribute
    /// [inlinePresentationIntent](https://developer.apple.com/documentation/Foundation/AttributeScopes/FoundationAttributes/3796123-inlinePresentationIntent),
    /// like the
    /// [stronglyEmphasized](https://developer.apple.com/documentation/Foundation/InlinePresentationIntent/3746899-stronglyEmphasized)
    /// value, which OpenSwiftUI presents as bold text.
    ///
    /// > Important: ``Text`` uses only a subset of the attributes defined in
    /// [FoundationAttributes](https://developer.apple.com/documentation/Foundation/AttributeScopes/FoundationAttributes).
    /// `Text` renders all
    /// [InlinePresentationIntent](https://developer.apple.com/documentation/Foundation/InlinePresentationIntent)
    /// attributes except for
    /// [lineBreak](https://developer.apple.com/documentation/Foundation/InlinePresentationIntent/3787563-lineBreak)
    /// and
    /// [softBreak](https://developer.apple.com/documentation/Foundation/InlinePresentationIntent/3787564-softBreak).
    /// It also respects
    /// [writingDirection](https://developer.apple.com/documentation/Foundation/AttributeScopes/FoundationAttributes/writingDirection)
    /// and renders the
    /// [link](https://developer.apple.com/documentation/Foundation/AttributeScopes/FoundationAttributes/3764633-link)
    /// attribute as a clickable link. `Text` ignores any other
    /// Foundation-defined attributes in an attributed string.
    ///
    /// ### OpenSwiftUI attributes
    ///
    /// OpenSwiftUI also defines additional attributes in the attribute scope
    /// ``AttributeScopes/OpenSwiftUIAttributes`` which you can access from an
    /// attributed string's ``AttributeScopes/openSwiftUI`` property.
    /// OpenSwiftUI attributes take precedence over equivalent attributes from
    /// other frameworks, such as
    /// [UIKitAttributes](https://developer.apple.com/documentation/Foundation/AttributeScopes/UIKitAttributes)
    /// and
    /// [AppKitAttributes](https://developer.apple.com/documentation/Foundation/AttributeScopes/AppKitAttributes).
    ///
    /// ### Markdown support
    ///
    /// You can create an `AttributedString` with Markdown syntax, which allows
    /// you to style distinct runs within a `Text` view:
    ///
    ///     let content = try! AttributedString(
    ///         markdown: "**Thank You!** Please visit our [website](http://example.com).")
    ///
    ///     var body: some View {
    ///         Text(content)
    ///     }
    ///
    /// The `**` syntax around "Thank You!" applies an
    /// [inlinePresentationIntent](https://developer.apple.com/documentation/Foundation/AttributeScopes/FoundationAttributes/3796123-inlinePresentationIntent)
    /// attribute with the value
    /// [stronglyEmphasized](https://developer.apple.com/documentation/Foundation/InlinePresentationIntent/3746899-stronglyEmphasized).
    /// OpenSwiftUI renders this as bold text, as described earlier. The link
    /// syntax around "website" creates a
    /// [link](https://developer.apple.com/documentation/Foundation/AttributeScopes/FoundationAttributes/3764633-link)
    /// attribute, which `Text` styles to indicate it's a link.
    ///
    /// ![A text view that says Thank you. Please visit our website. The text
    /// The view displays the words Thank you in a bold font, and the word
    /// website styled to indicate it is a
    /// link.](SwiftUI-Text-init-markdown.png)
    ///
    /// You can also use Markdown syntax in localized string keys, which means
    /// you can write the above example without needing to explicitly create an
    /// `AttributedString`:
    ///
    ///     var body: some View {
    ///         Text("**Thank You!** Please visit our [website](https://example.com).")
    ///     }
    ///
    /// In your app's strings files, use Markdown syntax to apply styling to the
    /// app's localized strings. You also use this approach when you want to
    /// perform automatic grammar agreement on localized strings, with the
    /// `^[text](inflect:true)` syntax.
    ///
    /// For details about Markdown syntax support in OpenSwiftUI, see
    /// ``Text/init(_:tableName:bundle:comment:)``.
    ///
    /// - Parameters:
    ///   - attributedContent: An attributed string to style and display, in
    ///     accordance with its attributes.
    @_disfavoredOverload
    public init(_ attributedContent: AttributedString) {
        self.init(anyTextStorage: AttributedStringTextStorage(str: attributedContent))
    }
}

// MARK: - AttributedStringTextStorage

final class AttributedStringTextStorage: AnyTextStorage, @unchecked Sendable {
    let str: AttributedString

    init(str: AttributedString) {
        self.str = str
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        result.append(
            NSAttributedString(openSwiftUIAttributedString: str),
            in: environment,
            with: options
        )
    }

    override func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) -> Bool {
        str.characters.isEmpty
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? AttributedStringTextStorage else {
            return false
        }
        return str == other.str
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        str.isStyled
    }

    override func allowsTypesettingLanguage() -> Bool {
        true
    }
}

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

extension AttributedString {
    package var isStyled: Bool {
        runs.contains { run in
            #if canImport(CoreText)
            let hasAdaptiveImageGlyph = run.adaptiveImageGlyph != nil
            #endif
            if run.font != nil {
                return true
            }
            if run.foregroundColor != nil {
                return true
            }
            if run.backgroundColor != nil {
                return true
            }
            if run.strikethroughStyle != nil {
                return true
            }
            if run.underlineStyle != nil {
                return true
            }
            if run.kern != nil {
                return true
            }
            if run.tracking != nil {
                return true
            }
            if run.baselineOffset != nil {
                return true
            }
            if run.textScale != nil {
                return true
            }
            if run.superscript != nil {
                return true
            }
            if run.privateStrikethroughColor != nil {
                return true
            }
            if run.privateUnderlineColor != nil {
                return true
            }
            if let inlinePresentationIntent = run.inlinePresentationIntent,
               !inlinePresentationIntent.intersection([
                   .emphasized,
                   .stronglyEmphasized,
                   .strikethrough,
                   .code,
               ]).isEmpty {
                return true
            }
            if run.link != nil {
                return true
            }
            #if canImport(CoreText)
            if hasAdaptiveImageGlyph {
                return true
            }
            #endif
            return false
        }
    }
}

extension NSAttributedString {
    convenience init(openSwiftUIAttributedString attributedString: AttributedString) {
        #if canImport(Darwin)
        let transformedAttributedString = CoreGlue2.shared.transformingEquivalentAttributes(attributedString)
        do {
            let nsAttributedString = try NSAttributedString(
                transformedAttributedString,
                including: \.openSwiftUI
            )
            self.init(attributedString: nsAttributedString)
        } catch {
            Log.runtimeIssues(
                "AttributedString %@ has invalid attributes. A plain string will be used instead.",
                [attributedString.description]
            )
            self.init(string: String(attributedString.characters))
        }
        #else
        self.init(string: String(attributedString.characters))
        #endif
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
            let intent = InlinePresentationIntent(rawValue: inlinePresentationIntent)
            if intent.contains(.emphasized) {
                style.fontModifiers.append(.static(Font.ItalicModifier.self))
            }
            if intent.contains(.stronglyEmphasized) {
                style.fontModifiers.append(.static(Font.BoldModifier.self))
            }
            if intent.contains(.code) {
                style.fontModifiers.append(.static(Font.MonospacedModifier.self))
            }
            if intent.contains(.strikethrough) {
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
