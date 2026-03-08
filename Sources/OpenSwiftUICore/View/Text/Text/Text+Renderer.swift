//
//  Text+Renderer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: 7F70C8A76EE0356881289646072938C0 (SwiftUICore)

#if canImport(CoreText)
import CoreText
#endif
import OpenAttributeGraphShims
public import OpenCoreGraphicsShims
import UIFoundation_Private

// TODO

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

/// A value that you can attach to text views and that text renderers can query.
@available(OpenSwiftUI_v5_0, *)
public protocol TextAttribute {}

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

            /// Returns a value that is offset the specified distance from this value.
            ///
            /// Use the `advanced(by:)` method in generic code to offset a value by a
            /// specified distance. If you're working directly with numeric values, use
            /// the addition operator (`+`) instead of this method.
            ///
            ///     func addOne<T: Strideable>(to x: T) -> T
            ///         where T.Stride: ExpressibleByIntegerLiteral
            ///     {
            ///         return x.advanced(by: 1)
            ///     }
            ///
            ///     let x = addOne(to: 5)
            ///     // x == 6
            ///     let y = addOne(to: 3.5)
            ///     // y = 4.5
            ///
            /// If this type's `Stride` type conforms to `BinaryInteger`, then for a
            /// value `x`, a distance `n`, and a value `y = x.advanced(by: n)`,
            /// `x.distance(to: y) == n`. Using this method with types that have a
            /// noninteger `Stride` may result in an approximation. If the result of
            /// advancing by `n` is not representable as a value of this type, then a
            /// runtime error may occur.
            ///
            /// - Parameter n: The distance to advance this value.
            /// - Returns: A value that is offset from this value by `n`.
            ///
            /// - Complexity: O(1)
            @_alwaysEmitIntoClient
            public func advanced(by n: Int) -> Text.Layout.CharacterIndex {
                .init(value: value + n)
            }

            /// Returns the distance from this value to the given value, expressed as a
            /// stride.
            ///
            /// If this type's `Stride` type conforms to `BinaryInteger`, then for two
            /// values `x` and `y`, and a distance `n = x.distance(to: y)`,
            /// `x.advanced(by: n) == y`. Using this method with types that have a
            /// noninteger `Stride` may result in an approximation.
            ///
            /// - Parameter other: The value to calculate the distance to.
            /// - Returns: The distance from this value to `other`.
            ///
            /// - Complexity: O(1)
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

            public subscript<T>(key: T.Type) -> T? where T: TextAttribute {
                _openSwiftUIUnimplementedFailure()
            }

            public var layoutDirection: LayoutDirection {
                _openSwiftUIUnimplementedFailure()
            }

            public var typographicBounds: Text.Layout.TypographicBounds {
                _openSwiftUIUnimplementedFailure()
            }

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

            @_alwaysEmitIntoClient
            public subscript<T>(key: T.Type) -> T? where T: TextAttribute {
                run[key]
            }

            public var typographicBounds: Text.Layout.TypographicBounds {
                _openSwiftUIUnimplementedFailure()
            }

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

// TODO

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
