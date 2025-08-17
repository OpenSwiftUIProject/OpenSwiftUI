//
//  Font.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 3D5D82E35921924EBCD40D1BFB222CC3 (SwiftUICore)

public import Foundation
#if canImport(CoreText)
public import CoreText
#endif

// MARK: - Font

/// An environment-dependent font.
///
/// The system resolves a font's value at the time it uses the font in a given
/// environment because ``Font`` is a late-binding token.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Font: Hashable, Sendable {
    private var provider: AnyFontBox

    func resolve(in context: Context) -> CTFontDescriptor {
        provider.resolve(in: context)
    }

    func resolveTraits(in enviroment: EnvironmentValues) -> ResolvedTraits {
        let context = enviroment.fontResolutionContext
        var traits = provider.resolveTraits(in: context)
        for modifier in enviroment.fontModifiers {
            modifier.modify(traits: &traits)
        }
        return traits
    }

    init(box: AnyFontBox) {
        self.provider = box
    }

    init<P>(provider: P) where P: FontProvider {
        self.init(box: FontBox(base: provider))
    }

    @_spi(Private)
    public struct ResolvedTraits {
        var pointSize: CGFloat
        var weight: CGFloat
        var width: CGFloat?

        public init(pointSize: CGFloat, weight: CGFloat) {
            self.pointSize = pointSize
            self.weight = weight
            self.width = nil
        }

        public init(_ descriptor: CTFontDescriptor) {
            #if canImport(CoreText)
            if let sizeValue = CTFontDescriptorCopyAttribute(descriptor, kCTFontSizeAttribute),
               let size = sizeValue as? CGFloat {
                self.pointSize = size
            } else {
                self.pointSize = 0.0
            }
            self.weight = CTFontDescriptorGetWeight(descriptor)
            self.width = nil
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }

        public init(
            textStyle: Font.TextStyle,
            weight: Font.Weight?,
            dynamicTypeSize: DynamicTypeSize
        ) {
            #if canImport(CoreText)
            var w: CGFloat = 0.0
            let size = CTFontDescriptorGetTextStyleSize(
                textStyle.ctTextStyle,
                dynamicTypeSize.ctTextSize,
                -1,
                &w,
                0
            )
            self.pointSize = size
            self.weight = weight?.value ?? w
            self.width = nil
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }

        public init(
            textStyle: Font.TextStyle,
            weight: Font.Weight?,
            sizeCategory: ContentSizeCategory
        ) {
            self.init(
                textStyle: textStyle,
                weight: weight,
                dynamicTypeSize: .init(sizeCategory)
            )
        }

        public init(
            textStyle: Font.PrivateTextStyle,
            weight: Font.Weight?,
            dynamicTypeSize: DynamicTypeSize
        ) {
            #if canImport(CoreText)
            var w: CGFloat = 0.0
            let size = CTFontDescriptorGetTextStyleSize(
                textStyle.value,
                dynamicTypeSize.ctTextSize,
                -1,
                &w,
                0
            )
            self.pointSize = size
            self.weight = weight?.value ?? w
            self.width = nil
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }

    public func hash(into hasher: inout Hasher) {
        provider.hasher(into: &hasher)
    }

    public static func == (lhs: Font, rhs: Font) -> Bool {
        lhs.provider.isEqual(to: rhs.provider)
    }
}

@_spi(Private)
extension Font {
    public func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
        provider.resolveTraits(in: context)
    }
}

@_spi(Private)
@available(*, unavailable)
extension Font.ResolvedTraits: Sendable {}

// MARK: - FontProvider

protocol FontProvider: Hashable {
    func resolve(in context: Font.Context) -> CTFontDescriptor
    func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits
}

extension FontProvider {
    func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
        .init(resolve(in: context))
    }
}

// MARK: - FontBox

@usableFromInline
class AnyFontBox: @unchecked Sendable {
    func resolve(in context: Font.Context) -> CTFontDescriptor {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isEqual(to other: AnyFontBox) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func hasher(into hasher: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

private class FontBox<Base>: AnyFontBox, @unchecked Sendable where Base: FontProvider {
    let base: Base

    init(base: Base) {
        self.base = base
    }

    override func resolve(in context: Font.Context) -> CTFontDescriptor {
        base.resolve(in: context)
    }

    override func resolveTraits(in context: Font.Context) -> Font.ResolvedTraits {
        base.resolveTraits(in: context)
    }

    override func isEqual(to other: AnyFontBox) -> Bool {
        guard let other = other as? FontBox<Base> else {
            return false
        }
        return base == other.base
    }

    override func hasher(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}

// MARK: - Font.Context [WIP]

extension Font {
    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public struct Context: Hashable {
        @available(OpenSwiftUI_v4_0, *)
        public var sizeCategory: ContentSizeCategory

        @available(OpenSwiftUI_v4_0, *)
        public var legibilityWeight: LegibilityWeight?

        @available(OpenSwiftUI_v6_0, *)
        public var fontDefinition: FontDefinitionType

        @available(OpenSwiftUI_v6_0, *)
        public var watchDisplayVariant: WatchDisplayVariant

        @available(OpenSwiftUI_v6_0, *)
        public var shouldRedactContent: Bool
    }

    @_spi(Private)
    public func platformFont(in context: Font.Context) -> CTFont {
        _openSwiftUIUnimplementedFailure()
    }

    package func platformFont(
        in context: Font.Context,
        modifiers: [AnyFontModifier]
    ) -> CTFont {
        _openSwiftUIUnimplementedFailure()
    }

    package func platformFont(
        in environment: EnvironmentValues,
        modifiers: [AnyFontModifier]
    ) -> CTFont {
        _openSwiftUIUnimplementedFailure()
    }

    package func platformFont(in environment: EnvironmentValues) -> CTFont {
        _openSwiftUIUnimplementedFailure()
    }

    package static func scaleFactor(
        textStyle: Font.TextStyle,
        in category: DynamicTypeSize
    ) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(Private)
@available(*, unavailable)
extension Font.Context: Sendable {}

// MARK: - Font.Context + CustomDebugStringConvertible

@_spi(Private)
extension Font.Context: CustomDebugStringConvertible {
    public var debugDescription: String {
        #if os(watchOS)
        let watchDisplayVariantDescription = String(describing: watchDisplayVariant)
        #else
        let watchDisplayVariantDescription = "-"
        #endif
        return #"""
        Font.Context(
            sizeCategory: \#(sizeCategory)
            legibilityWeight: \#(legibilityWeight.debugDescription)
            fontDefinition: \#(fontDefinition)
            watchDisplayVariant: \#(watchDisplayVariantDescription)
            shouldRedactContent: \#(shouldRedactContent ? "true" : "false")
        )
        """#
    }
}

// MARK: - EnvironmentValues + Font.Context

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension EnvironmentValues {
    private struct FontContextKey: DerivedEnvironmentKey {
        static func value(in environment: EnvironmentValues) -> Font.Context {
            Font.Context(
                sizeCategory: environment.sizeCategory, 
                legibilityWeight: environment.legibilityWeight,
                fontDefinition: environment.fontDefinition,
                watchDisplayVariant: environment.watchDisplayVariant,
                shouldRedactContent: environment.shouldRedactContent
            )
        }
    }

    public var fontResolutionContext: Font.Context {
        self[FontContextKey.self]
    }
}

extension Font {
    private struct Resolved: Hashable {
        var font: Font
        var modifiers: [AnyFontModifier]
        var context: Font.Context
    }

    private struct RatioKey: Hashable {
        var textStyle: Font.TextStyle
        var category: DynamicTypeSize
    }

    private static var fontCache: ObjectCache<Resolved, CTFont> = {
        let cache: ObjectCache<Resolved, CTFont> = ObjectCache { resolved in
//            resolved.font
            _openSwiftUIUnimplementedFailure()
        }
        return cache
    }()

    private static var ratioCache: [RatioKey: CGFloat] = [:]
}
