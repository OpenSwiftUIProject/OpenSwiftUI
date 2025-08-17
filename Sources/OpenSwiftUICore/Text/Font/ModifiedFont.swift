//
//  ModifiedFont.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 25811D44B7BE5E768C1CBA33158F398B (SwiftUICore)

public import Foundation
#if canImport(CoreText)
package import CoreText
#endif

@available(OpenSwiftUI_v1_0, *)
extension Font {
    /// Adds italics to the font.
    public func italic() -> Font {
        Font(provider: StaticModifierProvider<ItalicModifier>(base: self))
    }

    /// Adjusts the font to enable all small capitals.
    ///
    /// See ``Font/lowercaseSmallCaps()`` and ``Font/uppercaseSmallCaps()`` for
    /// more details.
    public func smallCaps() -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    /// Adjusts the font to enable lowercase small capitals.
    ///
    /// This function turns lowercase characters into small capitals for the
    /// font. It is generally used for display lines set in large and small
    /// caps, such as titles. It may include forms related to small capitals,
    /// such as old-style figures.
    public func lowercaseSmallCaps() -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    /// Adjusts the font to enable uppercase small capitals.
    ///
    /// This feature turns capital characters into small capitals. It is
    /// generally used for words which would otherwise be set in all caps, such
    /// as acronyms, but which are desired in small-cap form to avoid disrupting
    /// the flow of text.
    public func uppercaseSmallCaps() -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    /// Returns a modified font that uses fixed-width digits, while leaving
    /// other characters proportionally spaced.
    ///
    /// This modifier only affects numeric characters, and leaves all other
    /// characters unchanged. If the base font doesn't support fixed-width,
    /// or _monospace_ digits, the font remains unchanged.
    ///
    /// The following example shows two text fields arranged in a ``VStack``.
    /// Both text fields specify the 12-point system font, with the second
    /// adding the `monospacedDigit()` modifier to the font. Because the text
    /// includes the digit 1, normally a narrow character in proportional
    /// fonts, the second text field becomes wider than the first.
    ///
    ///     @State private var userText = "Effect of monospacing digits: 111,111."
    ///
    ///     var body: some View {
    ///         VStack {
    ///             TextField("Proportional", text: $userText)
    ///                 .font(.system(size: 12))
    ///             TextField("Monospaced", text: $userText)
    ///                 .font(.system(size: 12).monospacedDigit())
    ///         }
    ///         .padding()
    ///         .navigationTitle(Text("Font + monospacedDigit()"))
    ///     }
    ///
    /// ![A macOS window showing two text fields arranged vertically. Each
    /// shows the text Effect of monospacing digits: 111,111. The even spacing
    /// of the digit 1 in the second text field causes it to be noticably wider
    /// than the first.](Environment-Font-monospacedDigit-1)
    ///
    /// - Returns: A font that uses fixed-width numeric characters.
    public func monospacedDigit() -> Font {
        Font(provider: StaticModifierProvider<MonospacedDigitModifier>(base: self))
    }

    /// Sets the weight of the font.
    public func weight(_ weight: Font.Weight) -> Font {
        Font(provider: ModifierProvider(
            base: self,
            modifier: AnyFontModifier.dynamic(WeightModifier(weight: weight))
        ))
    }

    /// Sets the width of the font.
    @available(OpenSwiftUI_v4_0, *)
    public func width(_ width: Font.Width) -> Font {
        Font(provider: ModifierProvider(
            base: self,
            modifier: AnyFontModifier.dynamic(WidthModifier(width: width.value))
        ))
    }

    /// Adds bold styling to the font.
    public func bold() -> Font {
        Font(provider: StaticModifierProvider<BoldModifier>(base: self))
    }

    /// Returns a fixed-width font from the same family as the base font.
    ///
    /// If there's no suitable font face in the same family, OpenSwiftUI
    /// returns a default fixed-width font.
    ///
    /// The following example adds the `monospaced()` modifier to the default
    /// system font, then applies this font to a ``Text`` view:
    ///
    ///     struct ContentView: View {
    ///         let myFont = Font
    ///             .system(size: 24)
    ///             .monospaced()
    ///
    ///         var body: some View {
    ///             Text("Hello, world!")
    ///                 .font(myFont)
    ///                 .padding()
    ///                 .navigationTitle("Monospaced")
    ///         }
    ///     }
    ///
    ///
    /// ![A macOS window showing the text Hello, world in a 24-point
    /// fixed-width font.](Environment-Font-monospaced-1)
    ///
    /// OpenSwiftUI may provide different fixed-width replacements for standard
    /// user interface fonts (such as ``Font/title``, or a system font created
    /// with ``Font/system(_:design:)``) than for those same fonts when created
    /// by name with ``Font/custom(_:size:)``.
    ///
    /// The ``View/font(_:)`` modifier applies the font to all text within
    /// the view. To mix fixed-width text with other styles in the same
    /// `Text` view, use the ``Text/init(_:)-1a4oh`` initializer to use an
    /// appropropriately-styled
    /// [AttributedString](https://developer.apple.com/documentation/foundation/attributedstring)
    /// for the text view's content. You can use the
    ///
    /// [init(markdown:options:baseURL:)](https://developer.apple.com/documentation/foundation/attributedString/3796160-init)
    /// initializer to provide a Markdown-formatted string containing the
    /// backtick-syntax (\`…\`) to apply code voice to specific ranges
    /// of the attributed string.
    ///
    /// - Returns: A fixed-width font from the same family as the base font,
    /// if one is available, and a default fixed-width font otherwise.
    @available(OpenSwiftUI_v3_0, *)
    public func monospaced() -> Font {
        Font(provider: StaticModifierProvider<MonospacedModifier>(base: self))
    }

    /// Adjusts the line spacing of a font.
    ///
    /// You can change a font's line spacing while maintaining other
    /// characteristics of the font by applying this modifier.
    /// For example, you can decrease spacing of the ``body`` font by
    /// applying the ``Leading/tight`` value to it:
    ///
    ///     let myFont = Font.body.leading(.tight)
    ///
    /// The availability of leading adjustments depends on the font. For some
    /// fonts, the modifier has no effect and returns the original font.
    ///
    /// - Parameter leading: The line spacing adjustment to apply.
    ///
    /// - Returns: A modified font that uses the specified line spacing, or
    ///   the original font if it doesn't support line spacing adjustments.
    @available(OpenSwiftUI_v2_0, *)
    public func leading(_ leading: Font.Leading) -> Font {
        _openSwiftUIUnimplementedFailure()
    }
    
    @available(OpenSwiftUI_v2_0, *)
    @available(*, deprecated, renamed: "leading")
    public func _leading(_ leading: Font._Leading) -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    #if canImport(CoreText)
    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public func feature(_ type: Int, _ selector: Int) -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public func feature(_ settings: String...) -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Widget)
    @available(OpenSwiftUI_v4_0, *)
    public func features(_ features: [CFDictionary]) -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    public func _stylisticAlternative(_ alternative: Font._StylisticAlternative) -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    public func variation(_ identifier: Font.VariationAxisIdentifier, _ value: CGFloat) -> Font {
        _openSwiftUIUnimplementedFailure()
    }
    #endif

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    public enum VariationAxisIdentifier: Int, Hashable {
        case weight = 0x77676864

        case width = 0x77647468

        case slant = 0x736c6e74

        case opticalSize = 0x6f70737a

        case italic = 0x6974616c
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    public func grade(_ grade: Int) -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    package func modifier(_ modifier: some FontModifier) -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    package func modifier(type: (some StaticFontModifier).Type) -> Font {
        _openSwiftUIUnimplementedFailure()
    }

    /// A weight to use for fonts.
    @frozen
    public struct Weight: Hashable {
        package var value: CGFloat

        public static let ultraLight: Font.Weight = .init(value: -0.8)
        public static let thin: Font.Weight = .init(value: -0.6)
        public static let light: Font.Weight = .init(value: -0.4)
        public static let regular: Font.Weight = .init(value: 0.0)
        public static let medium: Font.Weight = .init(value: 0.23)
        public static let semibold: Font.Weight = .init(value: 0.3)
        public static let bold: Font.Weight = .init(value: 0.4)
        public static let heavy: Font.Weight = .init(value: 0.56)
        public static let black: Font.Weight = .init(value: 0.62)

        @_spi(Private)
        @available(OpenSwiftUI_v3_0, *)
        public static func custom(_ value: CGFloat) -> Font.Weight {
            .init(value: value)
        }
    }

    /// A width to use for fonts that have multiple widths.
    @available(OpenSwiftUI_v4_0, *)
    public struct Width: Hashable, Sendable {
        public var value: CGFloat

        #if canImport(CoreText)
        public static let compressed: Font.Width = .init(kCTFontWidthCompressed)
        public static let condensed: Font.Width = .init(kCTFontWidthCondensed)
        public static let standard: Font.Width = .init(kCTFontWidthStandard)
        public static let expanded: Font.Width = .init(kCTFontWidthExpanded)
        #endif

        public init(_ value: CGFloat) {
            self.value = value
        }
    }

    public enum _StylisticAlternative: Int, Hashable {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        case ten = 10
        case eleven = 11
        case twelve = 12
        case thirteen = 13
        case fourteen = 14
        case fifteen = 15
        case sixteen = 16
        case seventeen = 17
        case eighteen = 18
        case nineteen = 19
        case twenty = 20
    }

    /// A line spacing adjustment that you can apply to a font.
    ///
    /// Apply one of the `Leading` values to a font using the
    /// ``Font/leading(_:)`` method to increase or decrease the line spacing.
    @available(OpenSwiftUI_v2_0, *)
    public enum Leading: Sendable {
        /// The font's default line spacing.
        ///
        /// If you modify a font to use a nonstandard line spacing like
        /// ``tight`` or ``loose``, you can use this value to return to
        /// the font's default line spacing.
        case standard

        /// Reduced line spacing.
        ///
        /// This value typically reduces line spacing by 1 point for watchOS
        /// and 2 points on other platforms.
        case tight

        /// Increased line spacing.
        ///
        /// This value typically increases line spacing by 1 point for watchOS
        /// and 2 points on other platforms.
        case loose
    }

    public enum _Leading: Hashable {
        case tight
        case loose
        case standard
    }

    package struct BoldModifier: StaticFontModifier {
        package static func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            #if canImport(CoreText)
            descriptor = CTFontDescriptorCreateCopyWithSymbolicTraits(
                descriptor,
                .boldTrait,
                .boldTrait,
            ) ?? descriptor
            #endif
        }

        package static func modify(traits: inout Font.ResolvedTraits) {
            traits.weight = Font.Weight.bold.value
        }
    }

    package struct ItalicModifier: StaticFontModifier {
        package static func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            #if canImport(CoreText)
            descriptor = CTFontDescriptorCreateCopyWithSymbolicTraits(
                descriptor,
                .italicTrait,
                .italicTrait,
            ) ?? descriptor
            #endif
        }
    }

    package struct MonospacedModifier: StaticFontModifier {
        package static func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct MonospacedDigitModifier: StaticFontModifier {
        package static func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            #if canImport(CoreText)
            guard !context.shouldRedactContent else {
                return
            }
            descriptor = CTFontDescriptorCreateCopyWithFeature(
                descriptor,
                6.0 as CFNumber, // kCTFontFeatureTypeIdentifierKey
                1.0 as CFNumber, // kCTFontFeatureSelectorIdentifierKey
            )
            #endif
        }
    }

    package struct DesignModifier: FontModifier {
        package let design: Font.Design

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }

        package func hash(into hasher: inout Hasher) {
            _openSwiftUIUnimplementedFailure()
        }

        package static func == (a: Font.DesignModifier, b: Font.DesignModifier) -> Bool {
            _openSwiftUIUnimplementedFailure()
        }

        package var hashValue: Int {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct LeadingModifier: FontModifier {
        package var leading: Font.Leading

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct FeatureSettingModifier: FontModifier {
        package var type: Int
        package var selector: Int

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }

        package func hash(into hasher: inout Hasher) {
            _openSwiftUIUnimplementedFailure()
        }

        package static func == (a: Font.FeatureSettingModifier, b: Font.FeatureSettingModifier) -> Bool {
            _openSwiftUIUnimplementedFailure()
        }

        package var hashValue: Int {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct OpenTypeFeatureSettingModifier: FontModifier {
        package var settings: [String]

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }

        package func hash(into hasher: inout Hasher) {
            _openSwiftUIUnimplementedFailure()
        }

        package static func == (a: Font.OpenTypeFeatureSettingModifier, b: Font.OpenTypeFeatureSettingModifier) -> Bool {
            _openSwiftUIUnimplementedFailure()
        }

        package var hashValue: Int {
            _openSwiftUIUnimplementedFailure()
        }
    }

    #if canImport(CoreText)
    package struct FeatureDictionariesSettingModifier: FontModifier {
        package var features: [CFDictionary]

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }
    }
    #endif

    package struct WeightModifier: FontModifier {
        package var weight: Font.Weight

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }

        package func modify(traits: inout Font.ResolvedTraits) {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct WidthModifier: FontModifier {
        package var width: CGFloat

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }

        package func modify(traits: inout Font.ResolvedTraits) {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct StylisticAlternativeModifier: FontModifier {
        package var alternative: Font._StylisticAlternative

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct VariationModifier: FontModifier {
        package var identifier: Font.VariationAxisIdentifier
        package var value: CGFloat

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct GradeModifier: FontModifier {
        package var grade: Int

        package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
            _openSwiftUIUnimplementedFailure()
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension Font.VariationAxisIdentifier: Sendable {}

@available(*, unavailable)
extension Font._Leading: Sendable {}

@available(*, unavailable)
extension Font._StylisticAlternative: Sendable {}

// MARK: - FontModifier

package protocol FontModifier: Hashable {
    func modify(descriptor: inout CTFontDescriptor, in context: Font.Context)

    func modify(traits: inout Font.ResolvedTraits)
}

extension FontModifier {
    package func modify(traits: inout Font.ResolvedTraits) {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - StaticFontModifier

package protocol StaticFontModifier {
    static func modify(descriptor: inout CTFontDescriptor, in context: Font.Context)

    static func modify(traits: inout Font.ResolvedTraits)
}

extension StaticFontModifier {
    package static func modify(traits: inout Font.ResolvedTraits) {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - AnyFontModifier

package class AnyFontModifier: FontModifier {
    package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
        _openSwiftUIEmptyStub()
    }

    package func modify(traits: inout Font.ResolvedTraits) {
        _openSwiftUIEmptyStub()
    }

    package func isEqual(to other: AnyFontModifier) -> Bool {
        false
    }

    package func hash(into hasher: inout Hasher) {
        _openSwiftUIEmptyStub()
    }

    package static func == (lhs: AnyFontModifier, rhs: AnyFontModifier) -> Bool {
        lhs.isEqual(to: rhs)
    }

    package static func dynamic(_ modifier: some FontModifier) -> AnyFontModifier {
        AnyDynamicFontModifier(modifier)
    }

    package static func `static`<M>(_ type: M.Type) -> AnyFontModifier where M: StaticFontModifier {
        if let modifier = staticModifiers[ObjectIdentifier(M.self)] {
            return modifier
        } else {
            let modifier = AnyStaticFontModifier<M>()
            staticModifiers[ObjectIdentifier(M.self)] = modifier
            return modifier
        }
    }

    package var typeID: ObjectIdentifier {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

private var staticModifiers: [ObjectIdentifier: AnyFontModifier] = [:]

extension AnyFontModifier {
    package var isboldFontWeightModifier: Bool {
        guard let weight = self as? AnyDynamicFontModifier<Font.WeightModifier> else {
            return false
        }
        return weight.modifier.weight.value >= Font.Weight.bold.value
    }
}

// MARK: - AnyDynamicFontModifier

package final class AnyDynamicFontModifier<M>: AnyFontModifier where M: FontModifier {
    package final let modifier: M

    package init(_ modifier: M) {
        self.modifier = modifier
    }

    override package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
        modifier.modify(descriptor: &descriptor, in: context)
    }

    override package func modify(traits: inout Font.ResolvedTraits) {
        modifier.modify(traits: &traits)
    }

    override package func isEqual(to other: AnyFontModifier) -> Bool {
        guard let other = other as? AnyDynamicFontModifier<M> else {
            return false
        }
        return modifier == other.modifier
    }

    override package func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(M.self))
        modifier.hash(into: &hasher)
    }

    override package var typeID: ObjectIdentifier {
        ObjectIdentifier(M.self)
    }
}

// MARK: - AnyStaticFontModifier

package final class AnyStaticFontModifier<M>: AnyFontModifier where M: StaticFontModifier {
    override package func modify(descriptor: inout CTFontDescriptor, in context: Font.Context) {
        M.modify(descriptor: &descriptor, in: context)
    }

    override package func modify(traits: inout Font.ResolvedTraits) {
        M.modify(traits: &traits)
    }

    override package func isEqual(to other: AnyFontModifier) -> Bool {
        guard other is AnyStaticFontModifier<M> else {
            return false
        }
        return true
    }

    override package func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(M.self))
    }

    override package var typeID: ObjectIdentifier {
        ObjectIdentifier(M.self)
    }
}

// MARK: - EnvironmentValues + FontModifiers

private struct FontModifiersKey: EnvironmentKey {
    static let defaultValue: [AnyFontModifier] = []
}

extension EnvironmentValues {
    package var fontModifiers: [AnyFontModifier] {
        get { self[FontModifiersKey.self] }
        set { self[FontModifiersKey.self] = newValue }
    }
}

// MARK: - CodableFontWeight

extension Font.Weight: CodableByProxy {
    package var codingProxy: CodableFontWeight {
        CodableFontWeight(self)
    }
}

package struct CodableFontWeight: CodableProxy {
    package var base: Font.Weight

    package init(_ base: Font.Weight) {
        self.base = base
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(base.value)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(CGFloat.self)
        base = .init(value: value)
    }
}

// MARK: ModifierProvider

extension Font {
    private struct ModifierProvider<M>: FontProvider where M: FontModifier {
        var base: Font
        var modifier: M

        func resolve(in context: Font.Context) -> CTFontDescriptor {
            var descriptor = base.resolve(in: context)
            modifier.modify(descriptor: &descriptor, in: context)
            return descriptor
        }
    }

    private struct StaticModifierProvider<M>: FontProvider where M: StaticFontModifier {
        var base: Font

        func resolve(in context: Font.Context) -> CTFontDescriptor {
            var descriptor = base.resolve(in: context)
            M.modify(descriptor: &descriptor, in: context)
            return descriptor
        }
    }
}
