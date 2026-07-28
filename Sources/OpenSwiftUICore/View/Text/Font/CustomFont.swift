//
//  CustomFont.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A1A6E08ED7787270EADAD2AE750791A9 (SwiftUICore)

public import Foundation
#if canImport(CoreText)
public import CoreText
#endif

@available(OpenSwiftUI_v1_0, *)
extension Font {
    /// Create a custom font with the given `name` and `size` that scales with
    /// the body text style.
    public static func custom(_ name: String, size: CGFloat) -> Font {
        Font(
            provider: NamedProvider(
                name: name,
                size: size,
                textStyle: .body
            )
        )
    }

    /// Create a custom font with the given `name` and `size` that scales
    /// relative to the given `textStyle`.
    @available(OpenSwiftUI_v2_0, *)
    public static func custom(
        _ name: String,
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle
    ) -> Font {
        Font(
            provider: NamedProvider(
                name: name,
                size: size,
                textStyle: textStyle
            )
        )
    }

    @available(OpenSwiftUI_v2_0, *)
    @available(*, deprecated, renamed: "custom(_:size:textStyle:)")
    public static func _custom(
        _ name: String,
        size: CGFloat,
        textStyle: Font.TextStyle
    ) -> Font {
        custom(name, size: size, relativeTo: textStyle)
    }

    /// Create a custom font with the given `name` and a fixed `size` that does
    /// not scale with Dynamic Type.
    @available(OpenSwiftUI_v2_0, *)
    public static func custom(_ name: String, fixedSize: CGFloat) -> Font {
        Font(
            provider: NamedProvider(
                name: name,
                size: fixedSize,
                textStyle: nil
            )
        )
    }

    @available(OpenSwiftUI_v2_0, *)
    @available(*, deprecated, renamed: "custom(_:fixedSize:)")
    public static func _custom(_ name: String, verbatimSize: CGFloat) -> Font {
        custom(name, fixedSize: verbatimSize)
    }

    /// Creates a custom font from a platform font instance.
    ///
    /// Initializing ``Font`` with platform font instance
    /// ([CTFont](https://developer.apple.com/documentation/coretext/ctfont-q6r))
    /// can bridge OpenSwiftUI ``Font`` with
    /// [NSFont](https://developer.apple.com/documentation/appkit/nsfont) or
    /// [UIFont](https://developer.apple.com/documentation/uikit/uifont), both
    /// of which are toll-free bridged to
    /// [CTFont](https://developer.apple.com/documentation/coretext/ctfont-q6r).
    /// For example:
    ///
    ///     // Use native Core Text API to create desired ctFont.
    ///     let ctFont = CTFontCreateUIFontForLanguage(.system, 12, nil)!
    ///
    ///     // Create OpenSwiftUI Text with the CTFont instance.
    ///     let text = Text("Hello").font(Font(ctFont))
    public init(_ font: CTFont) {
        self.init(provider: PlatformFontProvider(font: font))
    }
}

extension Font {
    private struct NamedProvider: FontProvider {
        var name: String
        var size: CGFloat
        var textStyle: Font.TextStyle?

        func resolve(in context: Font.Context) -> CTFontDescriptor {
            context.fontDefinition.base
                .resolveCustomFont(
                    name: name,
                    size: size,
                    textStyle: textStyle,
                    in: context
                )
        }
    }

    private struct PlatformFontProvider: FontProvider {
        var font: CTFont

        func resolve(in context: Font.Context) -> CTFontDescriptor {
            context.fontDefinition.base.resolveFont(font)
        }

        func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
            context.fontDefinition.base.resolveFontInfo(font)
        }
    }
}
