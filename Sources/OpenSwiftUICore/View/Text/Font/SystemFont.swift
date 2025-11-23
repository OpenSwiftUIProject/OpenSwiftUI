//
//  SystemFont.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5603E46EFD6E0B67542F06407CC6DAD5 (SwiftUICore)

public import Foundation
#if canImport(CoreText)
import CoreText
#else
import CoreFoundation
#endif

@available(OpenSwiftUI_v1_0, *)
extension Font {
    /// Specifies a system font to use, along with the style, weight, and any
    /// design parameters you want applied to the text.
    ///
    /// Use this function to create a system font by specifying the size and
    /// weight, and a type design together. The following styles the system font
    /// as 17 point, ``Font/Weight/semibold`` text:
    ///
    ///     Text("Hello").font(.system(size: 17, weight: .semibold))
    ///
    /// While the following styles the text as 17 point ``Font/Weight/bold``,
    /// and applies a `serif` ``Font/Design`` to the system font:
    ///
    ///     Text("Hello").font(.system(size: 17, weight: .bold, design: .serif))
    ///
    /// Both `weight` and `design` can be optional. When you do not provide a
    /// `weight` or `design`, the system can pick one based on the current
    /// context, which may not be ``Font/Weight/regular`` or
    /// ``Font/Design/default`` in certain context. The following example styles
    /// the text as 17 point system font using ``Font/Design/rounded`` design,
    /// while its weight can depend on the current context:
    ///
    ///     Text("Hello").font(.system(size: 17, design: .rounded))
    @available(OpenSwiftUI_v4_0, *)
    public static func system(
        size: CGFloat,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil
    ) -> Font {
        Font(
            provider: SystemProvider(
                size: size,
                weight: weight,
                design: design,
            )
        )
    }

    @available(OpenSwiftUI_v6_0, *)
    package static func system(
        size: CGFloat,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil,
        relativeTo textStyle: Font.TextStyle? = nil,
        maximumSize: CGFloat? = nil
    ) -> Font {
        Font(
            provider: SystemProvider(
                size: size,
                weight: weight,
                design: design,
                textStyle: textStyle,
                maximumSize: maximumSize
            )
        )
    }

    /// Specifies a system font to use, along with the style, weight, and any
    /// design parameters you want applied to the text.
    ///
    /// Use this function to create a system font by specifying the size and
    /// weight, and a type design together. The following styles the system font
    /// as 17 point, ``Font/Weight/semibold`` text:
    ///
    ///     Text("Hello").font(.system(size: 17, weight: .semibold))
    ///
    /// While the following styles the text as 17 point ``Font/Weight/bold``,
    /// and applies a `serif` ``Font/Design`` to the system font:
    ///
    ///     Text("Hello").font(.system(size: 17, weight: .bold, design: .serif))
    ///
    /// If you want to use the default ``Font/Weight``
    /// (``Font/Weight/regular``), you don't need to specify the `weight` in the
    /// method. The following example styles the text as 17 point
    /// ``Font/Weight/regular``, and uses a ``Font/Design/rounded`` system font:
    ///
    ///     Text("Hello").font(.system(size: 17, design: .rounded))
    ///
    /// This function has been deprecated, use the one with nullable `weight`
    /// and `design` instead.
    @available(OpenSwiftUI_v1_0, *)
    @available(*, deprecated, message: "Use `system(size:weight:design:)` instead.")
    @_disfavoredOverload
    public static func system(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> Font {
        Font(
            provider: SystemProvider(
                size: size,
                weight: weight,
                design: design
            )
        )
    }

    #if canImport(CoreText)
    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public static func system(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.PrivateDesign
    ) -> Font {
        Font(
            provider: PrivateSystemDesignProvider(
                size: size,
                weight: weight,
                design: design
            )
        )
    }
    #endif

    /// A design to use for fonts.
    public enum Design: Hashable, Sendable {
        case `default`

        @available(watchOS 7.0, *)
        case serif

        case rounded

        @available(watchOS 7.0, *)
        case monospaced

        #if canImport(CoreText)
        var ctFontDesign: CFString {
            switch self {
            case .default: kCTFontUIFontDesignDefault
            case .serif: kCTFontUIFontDesignSerif
            case .rounded: kCTFontUIFontDesignRounded
            case .monospaced: kCTFontUIFontDesignMonospaced
            }
        }
        #endif
    }

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public struct PrivateDesign: Hashable {
        #if canImport(CoreText)
        var value: CFString

        public static let compact: Font.PrivateDesign = .init(
            value: kCTFontUIFontDesignCompact
        )

        public static let compactRounded: Font.PrivateDesign = .init(
            value: kCTFontUIFontDesignCompactRounded
        )

        public static let soft: Font.PrivateDesign = .init(
            value: kCTFontUIFontDesignSoft
        )

        public static let compactSoft: Font.PrivateDesign = .init(
            value: kCTFontUIFontDesignCompactSoft
        )
        #endif
    }
}

@_spi(Private)
@available(*, unavailable)
extension Font.PrivateDesign: Sendable {}

extension Font {
    private struct SystemProvider: FontProvider {
        var size: CGFloat
        var weight: Font.Weight?
        var design: Font.Design?
        var textStyle: Font.TextStyle?
        var maximumSize: CGFloat?

        func resolve(in context: Font.Context) -> CTFontDescriptor {
            context.fontDefinition.base
                .resolveSystemFont(
                    size: effectiveSize(in: context),
                    design: design,
                    weight: weight,
                    in: context,
                )
        }

        func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
            .init(
                pointSize: effectiveSize(in: context),
                weight: weight?.value ?? .zero
            )
        }

        func effectiveSize(in context: Font.Context) -> CGFloat {
            guard let textStyle else {
                return size
            }
            let scale = Font.scaleFactor(textStyle: textStyle, in: .init(context.sizeCategory))
            let result = round(size * scale)
            if let maximumSize {
                return min(result, maximumSize)
            } else {
                return result
            }
        }
    }

    #if canImport(CoreText)
    private struct PrivateSystemDesignProvider: FontProvider {
        var size: CGFloat
        var weight: Font.Weight
        var design: Font.PrivateDesign

        func resolve(in context: Font.Context) -> CTFontDescriptor {
            context.fontDefinition.base
                .resolvePrivateSystemDesignFont(
                    size: size,
                    design: design.value,
                    weight: weight,
                    in: context
                )
        }

        func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
            context.fontDefinition.base
                .resolvePrivateSystemDesignFontInfo(
                    size: size,
                    design: design.value,
                    weight: weight,
                    in: context
                )
        }
    }
    #endif
}
