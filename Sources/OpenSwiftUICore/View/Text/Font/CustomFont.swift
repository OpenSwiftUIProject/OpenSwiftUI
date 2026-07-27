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
    public static func custom(_ name: String, size: CGFloat) -> Font {
        Font(
            provider: NamedProvider(
                name: name,
                size: size,
                textStyle: .body
            )
        )
    }

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
