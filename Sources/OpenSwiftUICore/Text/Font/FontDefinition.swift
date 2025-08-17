//
//  FontDefinition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: A1A6E08ED7787270EADAD2AE750791A9 (SwiftUICore)

#if canImport(CoreText)
public import CoreText
#endif
public import CoreFoundation

// MARK: - FontDefinition

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public protocol FontDefinition {
    @available(OpenSwiftUI_v4_0, *)
    static func resolveTextStyleFont(
        textStyle: Font.TextStyle,
        design: Font.Design?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> CTFontDescriptor

    @available(OpenSwiftUI_v4_0, *)
    static func resolveTextStyleFontInfo(
        textStyle: Font.TextStyle,
        design: Font.Design?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> Font.ResolvedTraits

    @available(OpenSwiftUI_v4_0, *)
    static func resolveSystemFont(
        size: CGFloat,
        design: Font.Design?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> CTFontDescriptor

    @available(OpenSwiftUI_v4_0, *)
    static func resolveCustomFont(
        name: String,
        size: CGFloat,
        textStyle: Font.TextStyle?,
        in context: Font.Context
    ) -> CTFontDescriptor

    @available(OpenSwiftUI_v4_4, *)
    static func resolvePrivateTextStyleFont(
        textStyle: CFString,
        design: CFString?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> CTFontDescriptor

    @available(OpenSwiftUI_v4_4, *)
    static func resolvePrivateTextStyleFontInfo(
        textStyle: CFString,
        design: CFString?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> Font.ResolvedTraits

    @available(OpenSwiftUI_v5_0, *)
    static func resolvePrivateSystemDesignFont(
        size: CGFloat,
        design: CFString,
        weight: Font.Weight,
        in context: Font.Context
    ) -> CTFontDescriptor

    @available(OpenSwiftUI_v5_0, *)
    static func resolvePrivateSystemDesignFontInfo(
        size: CGFloat,
        design: CFString,
        weight: Font.Weight,
        in context: Font.Context
    ) -> Font.ResolvedTraits

    @available(OpenSwiftUI_v5_0, *)
    static func resolveFont(_ font: CTFont) -> CTFontDescriptor

    @available(OpenSwiftUI_v5_0, *)
    static func resolveFontInfo(_ font: CTFont) -> Font.ResolvedTraits
}

// MARK: - FontDefinition + Extension

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension FontDefinition {
    public static func resolveTextStyleFont(
        textStyle: Font.TextStyle,
        design: Font.Design?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> CTFontDescriptor {
        DefaultFontDefinition.resolveTextStyleFont(
            textStyle: textStyle,
            design: design,
            weight: weight,
            in: context
        )
    }

    public static func resolveTextStyleFontInfo(
        textStyle: Font.TextStyle,
        design: Font.Design?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> Font.ResolvedTraits {
        Font.ResolvedTraits(
            textStyle: textStyle,
            weight: weight,
            dynamicTypeSize: .init(context.sizeCategory)
        )
    }

    public static func resolveSystemFont(
        size: CGFloat,
        design: Font.Design?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> CTFontDescriptor {
        DefaultFontDefinition.resolveSystemFont(
            size: size,
            design: design,
            weight: weight,
            in: context
        )
    }

    public static func resolveCustomFont(
        name: String,
        size: CGFloat,
        textStyle: Font.TextStyle?,
        in context: Font.Context
    ) -> CTFontDescriptor {
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension FontDefinition {
    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public static func resolvePrivateTextStyleFont(
        textStyle: CFString,
        design: CFString?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> CTFontDescriptor {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public static func resolvePrivateTextStyleFontInfo(
        textStyle: CFString,
        design: CFString?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> Font.ResolvedTraits {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public static func resolvePrivateSystemDesignFont(
        size: CGFloat,
        design: CFString,
        weight: Font.Weight,
        in context: Font.Context
    ) -> CTFontDescriptor {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public static func resolvePrivateSystemDesignFontInfo(
        size: CGFloat,
        design: CFString,
        weight: Font.Weight,
        in context: Font.Context
    ) -> Font.ResolvedTraits {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public static func resolveFont(_ font: CTFont) -> CTFontDescriptor {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public static func resolveFontInfo(_ font: CTFont) -> Font.ResolvedTraits {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - DefaultFontDefinition [WIP]

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public enum DefaultFontDefinition: FontDefinition {
    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public static func resolveTextStyleFont(
        textStyle: Font.TextStyle,
        design: Font.Design?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> CTFontDescriptor {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public static func resolveSystemFont(
        size: CGFloat,
        design: Font.Design?,
        weight: Font.Weight?,
        in context: Font.Context
    ) -> CTFontDescriptor {
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(Private)
@available(*, unavailable)
extension DefaultFontDefinition: Sendable {}

// MARK: FontDefinitionType

private struct FontDefinitionKey: EnvironmentKey {
    static let defaultValue: FontDefinitionType  = .init(base: DefaultFontDefinition.self)
}

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
extension EnvironmentValues {
    public var fontDefinition: FontDefinitionType {
        get { self[FontDefinitionKey.self] }
        set { self[FontDefinitionKey.self] = newValue }
    }
}

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public struct FontDefinitionType: Hashable {
    var base: any FontDefinition.Type

    public static func == (lhs: FontDefinitionType, rhs: FontDefinitionType) -> Bool {
        lhs.base == rhs.base
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
}
