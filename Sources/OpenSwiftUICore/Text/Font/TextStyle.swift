//
//  TextStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 6C3CB9FA926D33389A872165D2448E11 (SwiftUICore)

#if canImport(CoreText)
import CoreText
package import CoreFoundation
#else
import CoreFoundation
#endif

@available(OpenSwiftUI_v1_0, *)
extension Font {
    /// A font with the large title text style.
    public static let largeTitle: Font = .system(.largeTitle)

    /// A font with the title text style.
    public static let title: Font = .system(.title)

    /// Create a font for second level hierarchical headings.
    @available(OpenSwiftUI_v2_0, *)
    public static let title2: Font = .system(.title2)

    /// Create a font for third level hierarchical headings.
    @available(OpenSwiftUI_v2_0, *)
    public static let title3: Font = .system(.title3)

    /// A font with the headline text style.
    public static let headline: Font = .system(.headline)

    /// A font with the subheadline text style.
    public static let subheadline: Font = .system(.subheadline)

    /// A font with the body text style.
    public static let body: Font = .system(.body)

    /// A font with the callout text style.
    public static let callout: Font = .system(.callout)

    /// A font with the footnote text style.
    public static let footnote: Font = .system(.footnote)

    /// A font with the caption text style.
    public static let caption: Font = .system(.caption)

    /// Create a font with the alternate caption text style.
    @available(OpenSwiftUI_v2_0, *)
    public static let caption2: Font = .system(.caption2)

    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public static let caption3: Font = .system(.caption3)

    /// Create a font with the extra large title text style.
    @available(visionOS 1.0, *)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static let extraLargeTitle: Font = .system(.extraLargeTitle)

    /// Create a font with the second level extra large title text style.
    @available(visionOS 1.0, *)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static let extraLargeTitle2: Font = .system(.extraLargeTitle2)

    /// Gets a system font that uses the specified style, design, and weight.
    ///
    /// Use this method to create a system font that has the specified
    /// properties. The following example creates a system font with the
    /// ``TextStyle/body`` text style, a ``Design/serif`` design, and
    /// a ``Weight/bold`` weight, and applies the font to a ``Text`` view
    /// using the ``View/font(_:)`` view modifier:
    ///
    ///     Text("Hello").font(.system(.body, design: .serif, weight: .bold))
    ///
    /// The `design` and `weight` parameters are both optional. If you omit
    /// either, the system uses a default value for that parameter. The
    /// default values are typically ``Design/default`` and ``Weight/regular``,
    /// respectively, but might vary depending on the context.
    @available(OpenSwiftUI_v4_0, *)
    public static func system(
        _ style: Font.TextStyle,
        design: Font.Design? = nil,
        weight: Font.Weight? = nil
    ) -> Font {
        Font(
            provider: TextStyleProvider(
                style: style,
                design: design,
                weight: weight
            )
        )
    }

    /// Gets a system font with the given text style and design.
    ///
    /// This function has been deprecated, use the one with nullable `design`
    /// and `weight` instead.
    @available(OpenSwiftUI_v1_0, *)
    @available(*, deprecated, message: "Use `system(_:design:weight:)` instead.")
    @_disfavoredOverload
    public static func system(
        _ style: Font.TextStyle,
        design: Font.Design = .default
    ) -> Font {
        Font(
            provider: TextStyleProvider(
                style: style,
                design: design
            )
        )
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    @available(*, deprecated, message: "Use `system(_:design:weight:)` API instead.")
    @_disfavoredOverload
    public static func system(
        _ style: Font.TextStyle,
        design: Font.Design = .default,
        weight: Font.Weight
    ) -> Font {
        Font(
            provider: TextStyleProvider(
                style: style,
                design: design,
                weight: weight
            )
        )
    }

    #if canImport(CoreText)
    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public static func system(
        _ style: Font.PrivateTextStyle,
        design: Font.Design? = nil,
        weight: Font.Weight? = nil
    ) -> Font {
        Font(
            provider: PrivateTextStyleProvider(
                style: style.value,
                design: design?.ctFontDesign,
                weight: weight
            )
        )
    }

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    @available(*, deprecated, message: "Use `system(_:design:weight:)` instead.")
    @_disfavoredOverload
    public static func system(
        _ style: Font.PrivateTextStyle,
        design: Font.Design = .default,
        weight: Font.Weight? = nil
    ) -> Font {
        Font(
            provider: PrivateTextStyleProvider(
                style: style.value,
                design: design.ctFontDesign,
                weight: weight
            )
        )
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public static func system(
        _ style: Font.TextStyle,
        design: Font.PrivateDesign,
        weight: Font.Weight? = nil
    ) -> Font {
        Font(
            provider: PrivateTextStyleProvider(
                style: style.ctTextStyle,
                design: design.value,
                weight: weight
            )
        )
    }
    #endif

    /// A dynamic text style to use for fonts.
    public enum TextStyle: CaseIterable, Sendable {
        /// The font style for large titles.
        case largeTitle

        /// The font used for first level hierarchical headings.
        case title

        /// The font used for second level hierarchical headings.
        @available(OpenSwiftUI_v2_0, *)
        case title2

        /// The font used for third level hierarchical headings.
        @available(OpenSwiftUI_v2_0, *)
        case title3

        /// The font used for headings.
        case headline

        /// The font used for subheadings.
        case subheadline

        /// The font used for body text.
        case body

        /// The font used for callouts.
        case callout

        /// The font used in footnotes.
        case footnote

        /// The font used for standard captions.
        case caption

        /// The font used for alternate captions.
        @available(OpenSwiftUI_v2_0, *)
        case caption2

        /// Create a font with the extra large title text style.
        @available(OpenSwiftUI_v6_0, *)
        @available(iOS, unavailable)
        @available(macOS, unavailable)
        @available(tvOS, unavailable)
        @available(watchOS, unavailable)
        case extraLargeTitle

        /// Create a font with the second level extra large title text style.
        @available(OpenSwiftUI_v6_0, *)
        @available(iOS, unavailable)
        @available(macOS, unavailable)
        @available(tvOS, unavailable)
        @available(watchOS, unavailable)
        case extraLargeTitle2

        @available(OpenSwiftUI_v6_0, *)
        @available(iOS, unavailable)
        @available(macOS, unavailable)
        @available(watchOS, unavailable)
        @available(visionOS, unavailable)
        case caption3

        public static var allCases: [Font.TextStyle] {
            get {
                var cases: [Font.TextStyle] = [
                    .largeTitle,
                    .title,
                    .title2,
                    .title3,
                    .headline,
                    .subheadline,
                    .body,
                    .callout,
                    .footnote,
                    .caption,
                    .caption2,
                ]
                #if os(visionOS)
                cases.append(.extraLargeTitle)
                cases.append(.extraLargeTitle2)
                #elseif os(tvOS)
                cases.append(.caption3)
                #endif
                return cases
            }
            set {}
        }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public struct PrivateTextStyle: Hashable {
        #if canImport(CoreText)
        var value: CFString

        public static let footnote2: Font.PrivateTextStyle = .init(
            value: kCTUIFontTextStyleFootnote2
        )

        package static let emphasizedBody: Font.PrivateTextStyle = .init(
            value: kUICTFontTextStyleShortCaption2
        )

        package static let shortCaption1: Font.PrivateTextStyle = .init(
            value: kUICTFontTextStyleShortCaption1
        )

        package static let shortCaption2: Font.PrivateTextStyle = .init(
            value: kUICTFontTextStyleShortCaption2
        )
        #endif
    }
}

@_spi(Private)
@available(*, unavailable)
extension Font.PrivateTextStyle: Sendable {}

#if canImport(CoreText)
extension Font.TextStyle {
    package var ctTextStyle: CFString {
        switch self {
        case .largeTitle: kCTUIFontTextStyleTitle0
        case .title: kCTUIFontTextStyleTitle1
        case .title2: kCTUIFontTextStyleTitle2
        case .title3: kCTUIFontTextStyleTitle3
        case .headline: kCTUIFontTextStyleHeadline
        case .subheadline: kCTUIFontTextStyleSubhead
        case .body: kCTUIFontTextStyleBody
        case .callout: kCTUIFontTextStyleCallout
        case .footnote: kCTUIFontTextStyleFootnote
        case .caption: kCTUIFontTextStyleCaption1
        case .caption2: kCTUIFontTextStyleCaption2
        case .extraLargeTitle: kCTUIFontTextStyleExtraLargeTitle
        case .extraLargeTitle2: kCTUIFontTextStyleExtraLargeTitle2
        case .caption3: kCTUIFontTextStyleCaption3
        }
    }
}

extension DynamicTypeSize {
    package var ctTextSize: CFString {
        switch self {
        case .xSmall: kCTFontContentSizeCategoryXS
        case .small: kCTFontContentSizeCategoryS
        case .medium: kCTFontContentSizeCategoryM
        case .large: kCTFontContentSizeCategoryL
        case .xLarge: kCTFontContentSizeCategoryXL
        case .xxLarge: kCTFontContentSizeCategoryXXL
        case .xxxLarge: kCTFontContentSizeCategoryXXXL
        case .accessibility1: kCTFontContentSizeCategoryAccessibilityM
        case .accessibility2: kCTFontContentSizeCategoryAccessibilityL
        case .accessibility3: kCTFontContentSizeCategoryAccessibilityXL
        case .accessibility4: kCTFontContentSizeCategoryAccessibilityXXL
        case .accessibility5: kCTFontContentSizeCategoryAccessibilityXXXL
        }
    }

    package init?(_ kCTFontContentSizeCategory: CFString) {
        switch kCTFontContentSizeCategory {
        case kCTFontContentSizeCategoryXS: self = .xSmall
        case kCTFontContentSizeCategoryS: self = .small
        case kCTFontContentSizeCategoryM: self = .medium
        case kCTFontContentSizeCategoryL: self = .large
        case kCTFontContentSizeCategoryXL: self = .xLarge
        case kCTFontContentSizeCategoryXXL: self = .xxLarge
        case kCTFontContentSizeCategoryXXXL: self = .xxxLarge
        case kCTFontContentSizeCategoryAccessibilityM: self = .accessibility1
        case kCTFontContentSizeCategoryAccessibilityL: self = .accessibility2
        case kCTFontContentSizeCategoryAccessibilityXL: self = .accessibility3
        case kCTFontContentSizeCategoryAccessibilityXXL: self = .accessibility4
        case kCTFontContentSizeCategoryAccessibilityXXXL: self = .accessibility5
        default: return nil
        }
    }
}
#endif

extension Font {
    private struct TextStyleProvider: FontProvider {
        var style: Font.TextStyle
        var design: Font.Design?
        var weight: Font.Weight?

        func resolve(in context: Font.Context) -> CTFontDescriptor {
            context.fontDefinition.base
                .resolveTextStyleFont(
                    textStyle: style,
                    design: design,
                    weight: weight,
                    in: context,
                )
        }

        func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
            context.fontDefinition.base
                .resolveTextStyleFontInfo(
                    textStyle: style,
                    design: design,
                    weight: weight,
                    in: context,
                )
        }
    }

    #if canImport(CoreText)
    private struct PrivateTextStyleProvider: FontProvider {
        var style: CFString
        var design: CFString?
        var weight: Font.Weight?

        func resolve(in context: Font.Context) -> CTFontDescriptor {
            context.fontDefinition.base
                .resolvePrivateTextStyleFont(
                    textStyle: style,
                    design: design,
                    weight: weight,
                    in: context,
                )
        }

        func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
            context.fontDefinition.base
                .resolvePrivateTextStyleFontInfo(
                    textStyle: style,
                    design: design,
                    weight: weight,
                    in: context,
                )
        }
    }
    #endif
}
