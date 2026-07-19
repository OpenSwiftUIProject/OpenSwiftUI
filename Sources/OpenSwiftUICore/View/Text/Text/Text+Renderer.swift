//
//  Text+Renderer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7F70C8A76EE0356881289646072938C0 (SwiftUICore)

#if canImport(CoreText)
import CoreText
#endif
import OpenAttributeGraphShims
public import OpenCoreGraphicsShims
import UIFoundation_Private

// TODO: TextRenderer

/// A proxy for a text view that custom text renderers use.
@available(OpenSwiftUI_v6_0, *)
public struct TextProxy {

    var text: ResolvedStyledText

    /// Returns the space needed by the text view, for a proposed size.
    ///
    /// - Parameter proposal: the proposed size of the text view.
    ///
    /// - Returns: the size that the text view requires for the
    ///   given proposal.
    public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }
}

// TODO: View + textRenderer

// MARK: - TextAttribute

/// A value that you can attach to text views and that text renderers can query.
@available(OpenSwiftUI_v5_0, *)
public protocol TextAttribute: Hashable {}

// MARK: - Text + customAttribute

@available(OpenSwiftUI_v5_0, *)
extension Text {
    /// Adds a custom attribute to the text view.
    ///
    /// Only one attribute of each type may be attached to each text
    /// view, with inner attributes taking precedence.
    ///
    /// - Parameter value: the attribute to attach.
    ///
    /// - Returns: a version of the text view with `value` attached.
    public func customAttribute<T>(_ value: T) -> Text where T: TextAttribute {
        modified(with: .customAttribute(value))
    }
}

// MARK: - TextAttributeModifierBase

package class TextAttributeModifierBase: AnyTextModifier, Hashable {
    package func hash(into hasher: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package static func == (lhs: TextAttributeModifierBase, rhs: TextAttributeModifierBase) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

// MARK: - TextAttributeModifier

private final class TextAttributeModifier<Value>: TextAttributeModifierBase where Value: TextAttribute {
    let attribute: Value

    init(value: Value) {
        attribute = value
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.customAttributes.append(self)
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? TextAttributeModifier<Value> else {
            return false
        }
        return attribute == other.attribute
    }

    override package func hash(into hasher: inout Hasher) {
        attribute.hash(into: &hasher)
    }
}

extension Text.Modifier {
    @inline(__always)
    static func customAttribute<T>(_ value: T) -> Self where T: TextAttribute {
        .anyTextModifier(TextAttributeModifier(value: value))
    }
}

// MARK: Text + CustomAttributes

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension Text {
    public struct CustomAttributes: @unchecked Sendable, Hashable {
        var attributes: [TextAttributeModifierBase] = []

        public init() {
            _openSwiftUIEmptyStub()
        }

        public mutating func add<T>(_ value: T) where T: TextAttribute {
            attributes.append(TextAttributeModifier(value: value))
        }

        public subscript<T>(_ key: T.Type) -> T? where T: TextAttribute {
            for attribute in attributes {
                if let modifier = attribute as? TextAttributeModifier<T> {
                    return modifier.attribute
                }
            }
            return nil
        }
    }
}

// TODO: _TextRendererViewModifier

// MARK: - TextRendererBoxBase

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public class TextRendererBoxBase {
    let environment: EnvironmentValues

    init(environment: EnvironmentValues) {
        self.environment = environment
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func sizeThatFits(proposal: ProposedViewSize, text: TextProxy) -> CGSize {
        _openSwiftUIBaseClassAbstractMethod()
    }

    var displayPadding: EdgeInsets {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension TextRendererBoxBase: Sendable {}

@available(OpenSwiftUI_v5_0, *)
extension Text {
    // MARK: - Text.Layout

    /// A value describing the layout and custom attributes of a tree
    /// of `Text` views.
    public struct Layout: RandomAccessCollection, Equatable {
        private var lines: [Text.Layout.Line]

        /// Indicates if this text is truncated.
        @available(OpenSwiftUI_v6_0, *)
        public private(set) var isTruncated: Bool

        @_spi(Private)
        @available(OpenSwiftUI_v5_0, *)
        public var truncated: Bool {
            isTruncated
        }

        @_spi(Private)
        @available(OpenSwiftUI_v5_0, *)
        public private(set) var numberOfLines: Int

        @_alwaysEmitIntoClient
        public var startIndex: Int { 0 }

        public var endIndex: Int { lines.endIndex }

        public subscript(index: Int) -> Text.Layout.Line { lines[index] }

        // MARK: - Text.Layout.CharacterIndex

        /// The index of a character in the source text. An opaque
        /// type, this is intended to be used to determine relative
        /// locations of elements in the layout, rather than how they
        /// map to the source strings.
        @frozen
        public struct CharacterIndex: Comparable, Hashable, Strideable, Sendable {
            @usableFromInline
            package var value: Int

            @_alwaysEmitIntoClient
            internal init(value: Int) {
                self.value = value
            }

            @_alwaysEmitIntoClient
            public static func < (lhs: Text.Layout.CharacterIndex, rhs: Text.Layout.CharacterIndex) -> Bool {
                lhs.value < rhs.value
            }

            @_alwaysEmitIntoClient
            public func advanced(by n: Int) -> Text.Layout.CharacterIndex {
                .init(value: value + n)
            }

            @_alwaysEmitIntoClient
            public func distance(to other: Text.Layout.CharacterIndex) -> Int {
                other.value - value
            }
        }

        // MARK: - Text.Layout.TypographicBounds

        /// The typographic bounds of an element in a text layout.
        @frozen
        public struct TypographicBounds: Equatable, Sendable {
            /// The position of the left edge of the element's
            /// baseline, relative to the text view.
            public var origin: CGPoint

            /// The width of the element.
            public var width: CGFloat

            /// The ascent of the element.
            public var ascent: CGFloat

            /// The descent of the element.
            public var descent: CGFloat

            /// The leading of the element.
            public var leading: CGFloat

            /// Initializes to an empty bounds with zero origin.
            @_alwaysEmitIntoClient
            public init() {
                origin = .init()
                (width, ascent, descent, leading) = (0, 0, 0, 0)
            }

            /// Returns a rectangle encapsulating the bounds.
            @_alwaysEmitIntoClient
            public var rect: CGRect {
                CGRect(
                    x: origin.x,
                    y: origin.y - ascent,
                    width: width,
                    height: ascent + descent,
                )
            }
        }

        // MARK: - Text.Layout.Line [WIP]

        /// A single line in a text layout: a collection of runs of
        /// placed glyphs.
        public struct Line: RandomAccessCollection, Equatable {
            private enum Line {
                #if canImport(CoreText)
                case ctLine(CTLine, AnyTextLayoutRenderer?)
                #endif
                case nsLine(NSTextLineFragment)
            }

            private var _line: Text.Layout.Line.Line

            @inline(__always)
            var attributedString: NSAttributedString? {
                guard case let .nsLine(nSTextLineFragment) = _line else {
                    return nil
                }
                return nSTextLineFragment.attributedString
            }

            /// The origin of the line.
            public var origin: CGPoint

            package var drawingOptions: Text.Layout.DrawingOptions

            @_alwaysEmitIntoClient
            public var startIndex: Int {
                 0
            }

            public var endIndex: Int {
                _openSwiftUIUnimplementedFailure()
            }

            public subscript(index: Int) -> Text.Layout.Run {
                _openSwiftUIUnimplementedFailure()
            }

            /// The typographic bounds of the line.
            public var typographicBounds: Text.Layout.TypographicBounds {
                _openSwiftUIUnimplementedFailure()
            }

            @_spi(Private)
            @available(OpenSwiftUI_v6_0, *)
            public var characterRange: Range<Text.Layout.CharacterIndex> {
                _openSwiftUIUnimplementedFailure()
            }

//            package func characterRanges(runIndices: Range<Int>) -> _RangeSet<Text.Layout.CharacterIndex> {
//                _openSwiftUIUnimplementedFailure()
//            }
//
//            package func characterRanges(runIndices: _RangeSet<Int>) -> _RangeSet<Text.Layout.CharacterIndex> {
//                _openSwiftUIUnimplementedFailure()
//            }

            @_spi(Private)
            @available(OpenSwiftUI_v6_0, *)
            public var paragraphLayoutDirection: LayoutDirection {
                _openSwiftUIUnimplementedFailure()
            }

            public static func == (lhs: Text.Layout.Line, rhs: Text.Layout.Line) -> Bool {
                guard lhs.origin == rhs.origin else { return false }
                return switch (lhs._line, rhs._line) {
                #if canImport(CoreText)
                case let (.ctLine(lhsLine, _), .ctLine(rhsLine, _)): lhsLine === rhsLine
                #endif
                case let (.nsLine(lhsLine), .nsLine(rhsLine)): lhsLine === rhsLine
                default: false
                }
            }
        }

        // MARK: - Text.Layout.Run [WIP]

        /// A run of placed glyphs in a text layout.
        public struct Run: RandomAccessCollection, Equatable {
            @_spi(Private)
            @available(OpenSwiftUI_v6_0, *)
            public var lineOrigin: CGPoint

            @_spi(_)
            @available(*, deprecated, renamed: "lineOrigin")
            public var origin: CGPoint {
                lineOrigin
            }

            @_alwaysEmitIntoClient
            public var startIndex: Int {
                0
            }

            public var endIndex: Int {
                _openSwiftUIUnimplementedFailure()
            }

            @_alwaysEmitIntoClient
            public subscript(index: Int) -> Text.Layout.RunSlice {
                self[index ..< index &+ 1]
            }

            @_alwaysEmitIntoClient
            public subscript(bounds: Range<Int>) -> Text.Layout.RunSlice {
                RunSlice(run: self, indices: bounds)
            }

            /// The custom attribute of type `T` associated with the
            /// run of glyphs, or nil. If no run contains the custom
            /// attribute we also check its attachment's runs.
            public subscript<T>(key: T.Type) -> T? where T: TextAttribute {
                _openSwiftUIUnimplementedFailure()
            }

            /// The layout direction of the text run.
            public var layoutDirection: LayoutDirection {
                _openSwiftUIUnimplementedFailure()
            }

            /// The typographic bounds of the run of glyphs.
            public var typographicBounds: Text.Layout.TypographicBounds {
                _openSwiftUIUnimplementedFailure()
            }

            /// The array of character indices corresponding to the
            /// glyphs in `self`.
            public var characterIndices: [Text.Layout.CharacterIndex] {
                _openSwiftUIUnimplementedFailure()
            }

            @_spi(Private)
            @available(OpenSwiftUI_v6_0, *)
            public var characterRange: Range<Text.Layout.CharacterIndex> {
                _openSwiftUIUnimplementedFailure()
            }
        }

        // MARK: - Text.Layout.RunSlice [WIP]

        /// A slice of a run of placed glyphs in a text layout.
        public struct RunSlice: RandomAccessCollection, Equatable {
            public var run: Text.Layout.Run

            public var indices: Range<Int>

            public init(run: Text.Layout.Run, indices: Range<Int>) {
                self.run = run
                self.indices = indices
            }

            @_alwaysEmitIntoClient
            public var startIndex: Int {
                indices.lowerBound
            }

            @_alwaysEmitIntoClient
            public var endIndex: Int {
                indices.upperBound
            }

            @_alwaysEmitIntoClient
            public subscript(index: Int) -> Text.Layout.RunSlice {
                self[index ..< index &+ 1]
            }

            public subscript(bounds: Range<Int>) -> Text.Layout.RunSlice {
                _openSwiftUIUnimplementedFailure()
            }

            /// The custom attribute of type `T` associated with the
            /// run of glyphs, or nil.
            @_alwaysEmitIntoClient
            public subscript<T>(key: T.Type) -> T? where T: TextAttribute {
                run[key]
            }

            /// The typographic bounds of the partial run of glyphs.
            public var typographicBounds: Text.Layout.TypographicBounds {
                _openSwiftUIUnimplementedFailure()
            }

            /// The array of character indices corresponding to the
            /// glyphs in `self`.
            public var characterIndices: [Text.Layout.CharacterIndex] {
                _openSwiftUIUnimplementedFailure()
            }
        }
    }
}

@available(*, unavailable)
extension Text.Layout: Sendable {}

@available(*, unavailable)
extension Text.Layout.Line: Sendable {}

@available(*, unavailable)
extension Text.Layout.Run: Sendable {}

@available(*, unavailable)
extension Text.Layout.RunSlice: Sendable {}

// TODO: AnyTextLayoutRenderer

class AnyTextLayoutRenderer {}

// MARK: - Text.LayoutKey

@available(OpenSwiftUI_v5_0, *)
extension Text {

    /// A preference key that provides the `Text.Layout` values for all
    /// text views in the queried subtree.
    public struct LayoutKey: PreferenceKey, Sendable {

        public struct AnchoredLayout: Equatable {

            /// The origin of the text layout.
            public var origin: Anchor<CGPoint>

            /// The text layout value.
            public var layout: Text.Layout
        }

        public static let defaultValue: [AnchoredLayout] = []

        public static func reduce(
            value: inout [AnchoredLayout],
            nextValue: () -> [AnchoredLayout]
        ) {
            value.append(contentsOf: nextValue())
        }
    }
}

@available(*, unavailable)
extension Text.LayoutKey.AnchoredLayout: Sendable {}

// MARK: - Text.DrawingOptions

@available(OpenSwiftUI_v5_0, *)
extension Text.Layout {

    /// Option flags used when drawing `Text.Layout` lines or runs into
    /// a graphics context.
    @frozen
    public struct DrawingOptions: OptionSet {
        public let rawValue: UInt32

        @_alwaysEmitIntoClient
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// If set, subpixel quantization requested by the text engine
        /// is disabled. This can be useful for text that will be
        /// animated to prevent it jittering.
        @_alwaysEmitIntoClient
        public static var disablesSubpixelQuantization: Text.Layout.DrawingOptions {
            .init(rawValue: 1 << 0)
        }
    }
}

// TODO: GraphicsContext + draw for Text.Layout

// TODO: Text.Layout + foregroundColor


// MARK: - TextRendererInput

struct TextRendererInput: ViewInput {
    static let defaultValue: WeakAttribute<TextRendererBoxBase> = .init()
}

extension _ViewInputs {
    @inline(__always)
    var textRenderer: WeakAttribute<TextRendererBoxBase> {
        get { self[TextRendererInput.self] }
        set { self[TextRendererInput.self] = newValue }
    }
}

// MARK: - TextRendererAddsDrawingGroupKey

private struct TextRendererAddsDrawingGroupKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    @inline(__always)
    var textRendererAddsDrawingGroup: Bool {
        get { self[TextRendererAddsDrawingGroupKey.self] }
        set { self[TextRendererAddsDrawingGroupKey.self] = newValue }
    }
}

// MARK: - Text + modifier

@available(OpenSwiftUI_v1_0, *)
extension Text {
    /// Sets the color of the text displayed by this view.
    ///
    /// Use this method to change the color of the text rendered by a text view.
    ///
    /// For example, you can display the names of the colors red, green, and
    /// blue in their respective colors:
    ///
    ///     HStack {
    ///         Text("Red").foregroundColor(.red)
    ///         Text("Green").foregroundColor(.green)
    ///         Text("Blue").foregroundColor(.blue)
    ///     }
    ///
    /// ![Three text views arranged horizontally, each containing
    ///     the name of a color displayed in that
    ///     color.](OpenSwiftUI-Text-foregroundColor.png)
    ///
    /// - Parameter color: The color to use when displaying this text.
    /// - Returns: A text view that uses the color value you supply.
    @available(*, deprecated, renamed: "foregroundStyle(_:)")
    public func foregroundColor(_ color: Color?) -> Text {
        modified(with: .color(color))
    }

    /// Sets the style of the text displayed by this view.
    ///
    /// Use this method to change the rendering style of the text
    /// rendered by a text view.
    ///
    /// For example, you can display the names of the colors red,
    /// green, and blue in their respective colors:
    ///
    ///     HStack {
    ///         Text("Red").foregroundStyle(.red)
    ///         Text("Green").foregroundStyle(.green)
    ///         Text("Blue").foregroundStyle(.blue)
    ///     }
    ///
    /// ![Three text views arranged horizontally, each containing
    ///     the name of a color displayed in that
    ///     color.](OpenSwiftUI-Text-foregroundColor.png)
    ///
    /// - Parameter style: The style to use when displaying this text.
    /// - Returns: A text view that uses the color value you supply.
    @available(OpenSwiftUI_v5_0, *)
    public func foregroundStyle<S>(_ style: S) -> Text where S: ShapeStyle {
        if let color = style as? Color {
            return modified(with: .color(color))
        } else {
            return modified(with: .foregroundStyle(style))
        }
    }

    /// Sets the default font for text in the view.
    ///
    /// Use `font(_:)` to apply a specific font to an individual
    /// Text View, or all of the text views in a container.
    ///
    /// In the example below, the first text field has a font set directly,
    /// while the font applied to the following container applies to all of the
    /// text views inside that container:
    ///
    ///     VStack {
    ///         Text("Font applied to a text view.")
    ///             .font(.largeTitle)
    ///
    ///         VStack {
    ///             Text("These two text views have the same font")
    ///             Text("applied to their parent view.")
    ///         }
    ///         .font(.system(size: 16, weight: .light, design: .default))
    ///     }
    ///
    ///
    /// ![Applying a font to a single text view or a view container](OpenSwiftUI-view-font.png)
    ///
    /// - Parameter font: The font to use when displaying this text.
    /// - Returns: Text that uses the font you specify.
    public func font(_ font: Font?) -> Text {
        modified(with: .font(font))
    }

    /// Sets the font weight of the text.
    ///
    /// - Parameter weight: One of the available font weights.
    ///
    /// - Returns: Text that uses the font weight you specify.
    public func fontWeight(_ weight: Font.Weight?) -> Text {
        modified(with: .weight(weight))
    }

    /// Sets the font width of the text.
    ///
    /// - Parameter width: One of the available font widths.
    ///
    /// - Returns: Text that uses the font width you specify, if available.
    @available(OpenSwiftUI_v4_0, *)
    public func fontWidth(_ width: Font.Width?) -> Text {
        modified(with: .width(width?.value))
    }

    /// Applies a bold or emphasized treatment to the fonts of the text.
    ///
    /// For fonts created from text styles, it could mean applying emphasized
    /// styling, which does not necessarily mean the bold weight specifically,
    /// so this modifier is not to be confused with ``Text/fontWeight(_:)``.
    ///
    /// For example:
    ///
    ///     Text("hello").font(.body).bold()
    ///
    /// will most likely get you the emphasized version of body text style,
    /// which is often in ``Font/Weight/semibold`` weight. While
    ///
    ///     Text("hello").font(.body).fontWeight(.bold)
    ///
    /// will specifically get you the body text style font in the
    /// ``Font/Weight/bold`` weight.
    ///
    /// - Returns: Bold or emphasized text.
    public func bold() -> Text {
        modified(with: .bold())
    }

    /// Applies a bold font weight to the text.
    ///
    /// - Parameter isActive: A Boolean value that indicates
    ///   whether text has bold styling.
    ///
    /// - Returns: Bold text.
    @available(OpenSwiftUI_v4_0, *)
    public func bold(_ isActive: Bool) -> Text {
        modified(with: .bold(isActive))
    }

    /// Applies italics to the text.
    ///
    /// - Returns: Italic text.
    public func italic() -> Text {
        modified(with: .italic())
    }

    /// Applies italics to the text.
    ///
    /// - Parameter isActive: A Boolean value that indicates
    ///   whether italic styling is added.
    ///
    /// - Returns: Italic text.
    @available(OpenSwiftUI_v4_0, *)
    public func italic(_ isActive: Bool) -> Text {
        modified(with: .italic(isActive))
    }

    /// Modifies the font of the text to use the fixed-width variant
    /// of the current font, if possible.
    ///
    /// - Parameter isActive: A Boolean value that indicates
    ///   whether monospaced styling is added. Default value is `true`.
    ///
    /// - Returns: Monospaced text.
    @available(OpenSwiftUI_v4_4, *)
    public func monospaced(_ isActive: Bool = true) -> Text {
        modified(with: .monospaced(isActive))
    }

    /// Sets the font design of the text.
    ///
    /// - Parameter design: One of the available font designs.
    ///
    /// - Returns: Text that uses the font design you specify.
    @available(OpenSwiftUI_v4_1, *)
    public func fontDesign(_ design: Font.Design?) -> Text {
        modified(with: .design(design))
    }

    /// Modifies the text view's font to use fixed-width digits, while leaving
    /// other characters proportionally spaced.
    ///
    /// This modifier only affects numeric characters, and leaves all other
    /// characters unchanged.
    ///
    /// The following example shows the effect of `monospacedDigit()` on a
    /// text view. It arranges two text views in a ``VStack``, each displaying
    /// a formatted date that contains many instances of the character 1.
    /// The second text view uses the `monospacedDigit()`. Because 1 is
    /// usually a narrow character in proportional fonts, applying the
    /// modifier widens all of the 1s, and the text view as a whole.
    /// The non-digit characters in the text view remain unaffected.
    ///
    ///     let myDate = DateComponents(
    ///         calendar: Calendar(identifier: .gregorian),
    ///         timeZone: TimeZone(identifier: "EST"),
    ///         year: 2011,
    ///         month: 1,
    ///         day: 11,
    ///         hour: 11,
    ///         minute: 11
    ///     ).date!
    ///
    ///     var body: some View {
    ///         VStack(alignment: .leading) {
    ///             Text(myDate.formatted(date: .long, time: .complete))
    ///                 .font(.system(size: 20))
    ///             Text(myDate.formatted(date: .long, time: .complete))
    ///                 .font(.system(size: 20))
    ///                 .monospacedDigit()
    ///         }
    ///         .padding()
    ///         .navigationTitle("monospacedDigit() Modifier")
    ///     }
    ///
    /// ![Two vertically stacked text views, displaying the date January 11,
    /// 2011, 11:11:00 AM. The second text view uses fixed-width digits, causing
    /// all of the 1s to be wider than in the first text
    /// view.](Text-monospacedDigit-1)
    ///
    /// If the base font of the text view doesn't support fixed-width digits,
    /// the font remains unchanged.
    ///
    /// - Returns: A text view with a modified font that uses fixed-width
    /// numeric characters, while leaving other characters proportionally
    /// spaced.
    @available(OpenSwiftUI_v3_0, *)
    public func monospacedDigit() -> Text {
        modified(with: .monospacedDigit())
    }

    /// Applies a strikethrough to the text.
    ///
    /// - Parameters:
    ///   - isActive: A Boolean value that indicates whether the text has a
    ///     strikethrough applied.
    ///   - color: The color of the strikethrough. If `color` is `nil`, the
    ///     strikethrough uses the default foreground color.
    ///
    /// - Returns: Text with a line through its center.
    public func strikethrough(
        _ isActive: Bool = true,
        color: Color? = nil
    ) -> Text {
        modified(with: .strikethrough(
            isActive ? Text.LineStyle(color: color) : nil
        ))
    }

    /// Applies a strikethrough to the text.
    ///
    /// - Parameters:
    ///   - isActive: A Boolean value that indicates whether strikethrough
    ///     is added. The default value is `true`.
    ///   - pattern: The pattern of the line.
    ///   - color: The color of the strikethrough. If `color` is `nil`, the
    ///     strikethrough uses the default foreground color.
    ///
    /// - Returns: Text with a line through its center.
    @available(OpenSwiftUI_v4_0, *)
    public func strikethrough(
        _ isActive: Bool = true,
        pattern: Text.LineStyle.Pattern,
        color: Color? = nil
    ) -> Text {
        modified(with: .strikethrough(
            isActive ? Text.LineStyle(pattern: pattern, color: color) : nil
        ))
    }

    /// Applies an underline to the text.
    ///
    /// - Parameters:
    ///   - isActive: A Boolean value that indicates whether the text has an
    ///     underline.
    ///   - color: The color of the underline. If `color` is `nil`, the
    ///     underline uses the default foreground color.
    ///
    /// - Returns: Text with a line running along its baseline.
    public func underline(
        _ isActive: Bool = true,
        color: Color? = nil
    ) -> Text {
        modified(with: .underline(
            isActive ? Text.LineStyle(color: color) : nil
        ))
    }

    /// Applies an underline to the text.
    ///
    /// - Parameters:
    ///   - isActive: A Boolean value that indicates whether underline
    ///     styling is added. The default value is `true`.
    ///   - pattern: The pattern of the line.
    ///   - color: The color of the underline. If `color` is `nil`, the
    ///     underline uses the default foreground color.
    ///
    /// - Returns: Text with a line running along its baseline.
    @available(OpenSwiftUI_v4_0, *)
    public func underline(
        _ isActive: Bool = true,
        pattern: Text.LineStyle.Pattern,
        color: Color? = nil
    ) -> Text {
        modified(with: .underline(
            isActive ? Text.LineStyle(pattern: pattern, color: color) : nil
        ))
    }

    /// Sets the spacing, or kerning, between characters.
    ///
    /// Kerning defines the offset, in points, that a text view should shift
    /// characters from the default spacing. Use positive kerning to widen the
    /// spacing between characters. Use negative kerning to tighten the spacing
    /// between characters.
    ///
    ///     VStack(alignment: .leading) {
    ///         Text("ABCDEF").kerning(-3)
    ///         Text("ABCDEF")
    ///         Text("ABCDEF").kerning(3)
    ///     }
    ///
    /// The last character in the first case, which uses negative kerning,
    /// experiences cropping because the kerning affects the trailing edge of
    /// the text view as well.
    ///
    /// ![Three text views showing character groups, with progressively
    /// increasing spacing between the characters in each
    /// group.](OpenSwiftUI-Text-kerning-1.png)
    ///
    /// Kerning attempts to maintain ligatures. For example, the Hoefler Text
    /// font uses a ligature for the letter combination _ffl_, as in the word
    /// _raffle_, shown here with a small negative and a small positive kerning:
    ///
    /// ![Two text views showing the word raffle in the Hoefler Text font, the
    /// first with small negative and the second with small positive kerning.
    /// The letter combination ffl has the same shape in both variants because
    /// it acts as a ligature.](OpenSwiftUI-Text-kerning-2.png)
    ///
    /// The *ffl* letter combination keeps a constant shape as the other letters
    /// move together or apart. Beyond a certain point in either direction,
    /// however, kerning does disable nonessential ligatures.
    ///
    /// ![Two text views showing the word raffle in the Hoefler Text font, the
    /// first with large negative and the second with large positive kerning.
    /// The letter combination ffl does not act as a ligature in either
    /// case.](OpenSwiftUI-Text-kerning-3.png)
    ///
    /// - Important: If you add both the ``Text/tracking(_:)`` and
    ///   ``Text/kerning(_:)`` modifiers to a view, the view applies the
    ///   tracking and ignores the kerning.
    ///
    /// - Parameter kerning: The spacing to use between individual characters in
    ///   this text. Value of `0` sets the kerning to the system default value.
    ///
    /// - Returns: Text with the specified amount of kerning.
    public func kerning(_ kerning: CGFloat) -> Text {
        modified(with: .kerning(kerning))
    }

    /// Sets the tracking for the text.
    ///
    /// Tracking adds space, measured in points, between the characters in the
    /// text view. A positive value increases the spacing between characters,
    /// while a negative value brings the characters closer together.
    ///
    ///     VStack(alignment: .leading) {
    ///         Text("ABCDEF").tracking(-3)
    ///         Text("ABCDEF")
    ///         Text("ABCDEF").tracking(3)
    ///     }
    ///
    /// The code above uses an unusually large amount of tracking to make it
    /// easy to see the effect.
    ///
    /// ![Three text views showing character groups with progressively
    /// increasing spacing between the characters in each
    /// group.](OpenSwiftUI-Text-tracking.png)
    ///
    /// The effect of tracking resembles that of the ``Text/kerning(_:)``
    /// modifier, but adds or removes trailing whitespace, rather than changing
    /// character offsets. Also, using any nonzero amount of tracking disables
    /// nonessential ligatures, whereas kerning attempts to maintain ligatures.
    ///
    /// - Important: If you add both the ``Text/tracking(_:)`` and
    ///   ``Text/kerning(_:)`` modifiers to a view, the view applies the
    ///   tracking and ignores the kerning.
    ///
    /// - Parameter tracking: The amount of additional space, in points, that
    ///   the view should add to each character cluster after layout. Value of `0`
    ///   sets the tracking to the system default value.
    ///
    /// - Returns: Text with the specified amount of tracking.
    public func tracking(_ tracking: CGFloat) -> Text {
        modified(with: .tracking(tracking))
    }

    /// Sets the vertical offset for the text relative to its baseline.
    ///
    /// Change the baseline offset to move the text in the view (in points) up
    /// or down relative to its baseline. The bounds of the view expand to
    /// contain the moved text.
    ///
    ///     HStack(alignment: .top) {
    ///         Text("Hello")
    ///             .baselineOffset(-10)
    ///             .border(Color.red)
    ///         Text("Hello")
    ///             .border(Color.green)
    ///         Text("Hello")
    ///             .baselineOffset(10)
    ///             .border(Color.blue)
    ///     }
    ///     .background(Color(white: 0.9))
    ///
    /// By drawing a border around each text view, you can see how the text
    /// moves, and how that affects the view.
    ///
    /// ![Three text views, each with the word "Hello" outlined by a border and
    /// aligned along the top edges. The first and last are larger than the
    /// second, with padding inside the border above the word "Hello" in the
    /// first case, and padding inside the border below the word in the last
    /// case.](OpenSwiftUI-Text-baselineOffset.png)
    ///
    /// The first view, with a negative offset, grows downward to handle the
    /// lowered text. The last view, with a positive offset, grows upward. The
    /// enclosing ``HStack`` instance, shown in gray, ensures all the text views
    /// remain aligned at their top edge, regardless of the offset.
    ///
    /// - Parameter baselineOffset: The amount to shift the text vertically (up
    ///   or down) relative to its baseline.
    ///
    /// - Returns: Text that's above or below its baseline.
    public func baselineOffset(_ baselineOffset: CGFloat) -> Text {
        modified(with: .baseline(baselineOffset))
    }

    public func _stylisticAlternative(_ alternative: Font._StylisticAlternative) -> Text {
        modified(with: .stylisticAlternative(alternative))
    }

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public func collapsible() -> Text {
        modified(with: .collapsible())
    }

    package func isCollapsible() -> Bool {
        modifiers.contains {
            guard case let .anyTextModifier(modifier) = $0 else {
                return false
            }
            return modifier is CollapsibleTextModifier
        }
    }
}
