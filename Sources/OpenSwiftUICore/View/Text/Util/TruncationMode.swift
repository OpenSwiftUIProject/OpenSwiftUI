//
//  TruncationMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 52803FDE2123C3846E0286DE7934BA01 (SwiftUICore?)

public import Foundation

@available(OpenSwiftUI_v1_0, *)
extension Text {

    // MARK: - Text.TruncationMode

    /// The type of truncation to apply to a line of text when it's too long to
    /// fit in the available space.
    ///
    /// When a text view contains more text than it's able to display, the view
    /// might truncate the text and place an ellipsis (...) at the truncation
    /// point. Use the ``View/truncationMode(_:)`` modifier with one of the
    /// `TruncationMode` values to indicate which part of the text to
    /// truncate, either at the beginning, in the middle, or at the end.
    public enum TruncationMode: Sendable {

        /// Truncate at the beginning of the line.
        ///
        /// Use this kind of truncation to omit characters from the beginning of
        /// the string. For example, you could truncate the English alphabet as
        /// "...wxyz".
        case head

        /// Truncate at the end of the line.
        ///
        /// Use this kind of truncation to omit characters from the end of the
        /// string. For example, you could truncate the English alphabet as
        /// "abcd...".
        case tail

        /// Truncate in the middle of the line.
        ///
        /// Use this kind of truncation to omit characters from the middle of
        /// the string. For example, you could truncate the English alphabet as
        /// "ab...yz".
        case middle
    }

    // MARK: - Text.Case

    /// A scheme for transforming the capitalization of characters within text.
    @available(OpenSwiftUI_v2_0, *)
    public enum Case: Sendable {

        /// Displays text in all uppercase characters.
        ///
        /// For example, "Hello" would be displayed as "HELLO".
        ///
        /// - SeeAlso: `StringProtocol.uppercased(with:)`
        case uppercase

        /// Displays text in all lowercase characters.
        ///
        /// For example, "Hello" would be displayed as "hello".
        ///
        /// - SeeAlso: `StringProtocol.lowercased(with:)`
        case lowercase
    }
}

// MARK: - Text.TruncationMode + ProtobufEnum

extension Text.TruncationMode: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
        case .head: 1
        case .tail: 2
        case .middle: 3
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 1: self = .head
        case 2: self = .tail
        case 3: self = .middle
        default: return nil
        }
    }
}

// MARK: - CodableTextCase

package enum CodableTextCase: Codable {
    case uppercase
    case lowercase

    package init(_ textCase: Text.Case) {
        self = switch textCase {
        case .uppercase: .uppercase
        case .lowercase: .lowercase
        }
    }

    package var textCase: Text.Case {
        switch self {
        case .uppercase: .uppercase
        case .lowercase: .lowercase
        }
    }

    private enum CodingKeys: CodingKey {
        case uppercase
        case lowercase
    }

    private enum UppercaseCodingKeys: CodingKey {}

    private enum LowercaseCodingKeys: CodingKey {}

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .uppercase:
            _ = container.nestedContainer(keyedBy: UppercaseCodingKeys.self, forKey: .uppercase)
        case .lowercase:
            _ = container.nestedContainer(keyedBy: LowercaseCodingKeys.self, forKey: .lowercase)
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
        case .uppercase:
            _ = try container.nestedContainer(keyedBy: UppercaseCodingKeys.self, forKey: .uppercase)
            self = .uppercase
        case .lowercase:
            _ = try container.nestedContainer(keyedBy: LowercaseCodingKeys.self, forKey: .lowercase)
            self = .lowercase
        }
    }
}

extension Text.Case: CodableByProxy {
    package var codingProxy: CodableTextCase { .init(self) }

    package static func unwrap(codingProxy: CodableTextCase) -> Text.Case {
        codingProxy.textCase
    }
}

// MARK: - EnvironmentValues + Text Properties

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {

    /// An environment value that indicates how a text view aligns its lines
    /// when the content wraps or contains newlines.
    ///
    /// Set this value for a view hierarchy by applying the
    /// ``View/multilineTextAlignment(_:)`` view modifier. Views in the
    /// hierarchy that display text, like ``Text`` or ``TextEditor``, read the
    /// value from the environment and adjust their text alignment accordingly.
    ///
    /// This value has no effect on a ``Text`` view that contains only one
    /// line of text, because a text view has a width that exactly matches the
    /// width of its widest line. If you want to align an entire text view
    /// rather than its contents, set the aligment of its container, like a
    /// ``VStack`` or a frame that you create with the
    /// ``View/frame(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:alignment:)``
    /// modifier.
    ///
    /// > Note: You can use this value to control the alignment of a ``Text``
    ///   view that you create with the ``Text/init(_:style:)`` initializer
    ///   to display localized dates and times, including when the view uses
    ///   only a single line, but only when that view appears in a widget.
    public var multilineTextAlignment: TextAlignment {
        get { self[TextAlignmentKey.self] ?? .leading }
        set { self[TextAlignmentKey.self] = newValue }
    }

    /// A value that indicates how the layout truncates the last line of text to
    /// fit into the available space.
    ///
    /// The default value is ``Text/TruncationMode/tail``. Some controls,
    /// however, might have a different default if appropriate.
    public var truncationMode: Text.TruncationMode {
        get { self[TruncationModeKey.self] ?? .tail }
        set { self[TruncationModeKey.self] = newValue }
    }

    package var explicitTruncationMode: Text.TruncationMode? {
        get { self[TruncationModeKey.self] }
        set { self[TruncationModeKey.self] = newValue }
    }

    package var defaultTextFieldTruncationMode: Text.TruncationMode? {
        get { self[DefaultTextFieldTruncationMode.self] }
        set { self[DefaultTextFieldTruncationMode.self] = newValue }
    }

    /// The distance in points between the bottom of one line fragment and the
    /// top of the next.
    ///
    /// This value is always nonnegative.
    public var lineSpacing: CGFloat {
        get { self[LineSpacingKey.self] }
        set { self[LineSpacingKey.self] = newValue }
    }

    /// The natural line height of text is multiplied by this factor
    /// (if positive).
    ///
    /// The default value is `0.0`.
    @available(OpenSwiftUI_v2_0, *)
    public var _lineHeightMultiple: CGFloat {
        get { self[LineHeightMultipleKey.self] }
        set { self[LineHeightMultipleKey.self] = newValue }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    public var lineHeightMultiple: CGFloat {
        get { self[LineHeightMultipleKey.self] }
        set { self[LineHeightMultipleKey.self] = newValue }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    public var maximumLineHeight: CGFloat {
        get { self[MaximumLineHeightKey.self] }
        set { self[MaximumLineHeightKey.self] = newValue }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    public var minimumLineHeight: CGFloat {
        get { self[MinimumLineHeightKey.self] }
        set { self[MinimumLineHeightKey.self] = newValue }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    public var hyphenationFactor: CGFloat {
        get { self[HyphenationFactorKey.self] }
        set { self[HyphenationFactorKey.self] = newValue }
    }

    /// A Boolean value that indicates whether inter-character spacing should
    /// tighten to fit the text into the available space.
    ///
    /// The default value is `false`.
    public var allowsTightening: Bool {
        get { self[AllowsTighteningKey.self] }
        set { self[AllowsTighteningKey.self] = newValue }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public var avoidsOrphans: Bool {
        get { self[AvoidsOrphansKey.self] }
        set { self[AvoidsOrphansKey.self] = newValue }
    }

    var bodyHeadOutdent: CGFloat {
        get { self[BodyHeadOutdentKey.self] }
        set { self[BodyHeadOutdentKey.self] = newValue }
    }

    /// The minimum permissible proportion to shrink the font size to fit
    /// the text into the available space.
    ///
    /// In the example below, a label with a `minimumScaleFactor` of `0.5`
    /// draws its text in a font size as small as half of the actual font if
    /// needed to fit into the space next to the text input field:
    ///
    ///     HStack {
    ///         Text("This is a very long label:")
    ///             .lineLimit(1)
    ///             .minimumScaleFactor(0.5)
    ///         TextField("My Long Text Field", text: $myTextField)
    ///             .frame(width: 250, height: 50, alignment: .center)
    ///     }
    ///
    /// ![A screenshot showing the effects of setting the minimumScaleFactor on
    ///   the text in a view](OpenSwiftUI-View-minimumScaleFactor.png)
    ///
    /// You can set the minimum scale factor to any value greater than `0` and
    /// less than or equal to `1`. The default value is `1`.
    ///
    /// OpenSwiftUI uses this value to shrink text that doesn't fit in a view when
    /// it's okay to shrink the text. For example, a label with a
    /// `minimumScaleFactor` of `0.5` draws its text in a font size as small as
    /// half the actual font if needed.
    public var minimumScaleFactor: CGFloat {
        get { self[MinimumScaleFactorKey.self] }
        set { self[MinimumScaleFactorKey.self] = newValue }
    }

    /// A stylistic override to transform the case of `Text` when displayed,
    /// using the environment's locale.
    ///
    /// The default value is `nil`, displaying the `Text` without any case
    /// changes.
    @available(OpenSwiftUI_v2_0, *)
    public var textCase: Text.Case? {
        get { self[TextCaseKey.self] }
        set { self[TextCaseKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Sets the alignment of a text view that contains multiple lines of text.
    ///
    /// Use this modifier to set an alignment for a multiline block of text.
    /// For example, the modifier centers the contents of the following
    /// ``Text`` view:
    ///
    ///     Text("This is a block of text that shows up in a text element as multiple lines.\("\n") Here we have chosen to center this text.")
    ///         .frame(width: 200)
    ///         .multilineTextAlignment(.center)
    ///
    /// The text in the above example spans more than one line because:
    ///
    /// * The newline character introduces a line break.
    /// * The frame modifier limits the space available to the text view, and
    ///   by default a text view wraps lines that don't fit in the available
    ///   width. As a result, the text before the explicit line break wraps to
    ///   three lines, and the text after uses two lines.
    ///
    /// The modifier applies the alignment to the all the lines of text in
    /// the view, regardless of why wrapping occurs:
    ///
    /// ![A block of text that spans 5 lines. The lines of text are center-aligned.](View-multilineTextAlignment-1-iOS)
    ///
    /// The modifier has no effect on a ``Text`` view that contains only one
    /// line of text, because a text view has a width that exactly matches the
    /// width of its widest line. If you want to align an entire text view
    /// rather than its contents, set the aligment of its container, like a
    /// ``VStack`` or a frame that you create with the
    /// ``View/frame(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:alignment:)``
    /// modifier.
    ///
    /// > Note: You can use this modifier to control the alignment of a ``Text``
    ///   view that you create with the ``Text/init(_:style:)`` initializer
    ///   to display localized dates and times, including when the view uses
    ///   only a single line, but only when that view appears in a widget.
    ///
    /// The modifier also affects the content alignment of other text container
    /// types, like ``TextEditor`` and ``TextField``. In those cases, the
    /// modifier sets the alignment even when the view contains only a single
    /// line because view's width isn't dictated by the width of the text it
    /// contains.
    ///
    /// The modifier operates by setting the
    /// ``EnvironmentValues/multilineTextAlignment`` value in the environment,
    /// so it affects all the text containers in the modified view hierarchy.
    /// For example, you can apply the modifier to a ``VStack`` to
    /// configure all the text views inside the stack.
    ///
    /// - Parameter alignment: A value that you use to align multiple lines of
    ///   text within a view.
    ///
    /// - Returns: A view that aligns the lines of multiline ``Text`` instances
    ///   it contains.
    @inlinable
    nonisolated public func multilineTextAlignment(_ alignment: TextAlignment) -> some View {
        environment(\.multilineTextAlignment, alignment)
    }

    /// Sets the truncation mode for lines of text that are too long to fit in
    /// the available space.
    ///
    /// Use the `truncationMode(_:)` modifier to determine whether text in a
    /// long line is truncated at the beginning, middle, or end. Truncation is
    /// indicated by adding an ellipsis (…) to the line when removing text to
    /// indicate to readers that text is missing.
    ///
    /// In the example below, the bounds of text view constrains the amount of
    /// text that the view displays and the `truncationMode(_:)` specifies from
    /// which direction and where to display the truncation indicator:
    ///
    ///     Text("This is a block of text that will show up in a text element as multiple lines. The text will fill the available space, and then, eventually, be truncated.")
    ///         .frame(width: 150, height: 150)
    ///         .truncationMode(.tail)
    ///
    /// ![A screenshot showing the effect of truncation mode on text in a
    /// view.](OpenSwiftUI-view-truncationMode.png)
    ///
    /// - Parameter mode: The truncation mode that specifies where to truncate
    ///   the text within the text view, if needed. You can truncate at the
    ///   beginning, middle, or end of the text view.
    ///
    /// - Returns: A view that truncates text at different points in a line
    ///   depending on the mode you select.
    @inlinable
    nonisolated public func truncationMode(_ mode: Text.TruncationMode) -> some View {
        environment(\.truncationMode, mode)
    }

    /// Sets the amount of space between lines of text in this view.
    ///
    /// Use `lineSpacing(_:)` to set the amount of spacing from the bottom of
    /// one line to the top of the next for text elements in the view.
    ///
    /// In the ``Text`` view in the example below, 10 points separate the bottom
    /// of one line to the top of the next as the text field wraps inside this
    /// view. Applying `lineSpacing(_:)` to a view hierarchy applies the line
    /// spacing to all text elements contained in the view.
    ///
    ///     Text("This is a string in a TextField with 10 point spacing applied between the bottom of one line and the top of the next.")
    ///         .frame(width: 200, height: 200, alignment: .leading)
    ///         .lineSpacing(10)
    ///
    /// ![A screenshot showing the effects of setting line spacing on the text
    /// in a view.](OpenSwiftUI-view-lineSpacing.png)
    ///
    /// - Parameter lineSpacing: The amount of space between the bottom of one
    ///   line and the top of the next line in points.
    @inlinable
    nonisolated public func lineSpacing(_ lineSpacing: CGFloat) -> some View {
        environment(\.lineSpacing, lineSpacing)
    }

    /// Sets the factor to multiply the natural line height of each line by.
    ///
    /// - Parameter multiple: The natural line height of the receiver is
    ///   multiplied by this factor (if positive). The default value is `0.0`.
    @available(OpenSwiftUI_v2_0, *)
    @usableFromInline
    @available(*, deprecated, renamed: "lineHeightMultiple")
    @MainActor
    @preconcurrency internal func _lineHeightMultiple(_ multiple: CGFloat) -> some View {
        environment(\._lineHeightMultiple, multiple)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    nonisolated public func lineHeightMultiple(_ multiple: CGFloat) -> some View {
        environment(\.lineHeightMultiple, multiple)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    nonisolated public func maximumLineHeight(_ lineHeight: CGFloat) -> some View {
        environment(\.maximumLineHeight, lineHeight)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    nonisolated public func minimumLineHeight(_ lineHeight: CGFloat) -> some View {
        environment(\.minimumLineHeight, lineHeight)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v2_0, *)
    nonisolated public func hyphenationFactor(_ factor: CGFloat) -> some View {
        environment(\.hyphenationFactor, factor)
    }

    /// Sets whether text in this view can compress the space between characters
    /// when necessary to fit text in a line.
    ///
    /// Use `allowsTightening(_:)` to enable the compression of inter-character
    /// spacing of text in a view to try to fit the text in the view's bounds.
    ///
    /// In the example below, two identically configured text views show the
    /// effects of `allowsTightening(_:)` on the compression of the spacing
    /// between characters:
    ///
    ///     VStack {
    ///         Text("This is a wide text element")
    ///             .font(.body)
    ///             .frame(width: 200, height: 50, alignment: .leading)
    ///             .lineLimit(1)
    ///             .allowsTightening(true)
    ///
    ///         Text("This is a wide text element")
    ///             .font(.body)
    ///             .frame(width: 200, height: 50, alignment: .leading)
    ///             .lineLimit(1)
    ///             .allowsTightening(false)
    ///     }
    ///
    /// ![A screenshot showing the effect of enabling text tightening in a
    /// view.](OpenSwiftUI-view-allowsTightening.png)
    ///
    /// - Parameter flag: A Boolean value that indicates whether the space
    ///   between characters compresses when necessary.
    ///
    /// - Returns: A view that can compress the space between characters when
    ///   necessary to fit text in a line.
    @inlinable
    nonisolated public func allowsTightening(_ flag: Bool) -> some View {
        environment(\.allowsTightening, flag)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func avoidsOrphans(_ flag: Bool) -> some View {
        environment(\.avoidsOrphans, flag)
    }

    /// Sets the minimum amount that text in this view scales down to fit in the
    /// available space.
    ///
    /// Use the `minimumScaleFactor(_:)` modifier if the text you place in a
    /// view doesn't fit and it's okay if the text shrinks to accommodate. For
    /// example, a label with a minimum scale factor of `0.5` draws its text in
    /// a font size as small as half of the actual font if needed.
    ///
    /// In the example below, the ``HStack`` contains a ``Text`` label with a
    /// line limit of `1`, that is next to a ``TextField``. To allow the label
    /// to fit into the available space, the `minimumScaleFactor(_:)` modifier
    /// shrinks the text as needed to fit into the available space.
    ///
    ///     HStack {
    ///         Text("This is a long label that will be scaled to fit:")
    ///             .lineLimit(1)
    ///             .minimumScaleFactor(0.5)
    ///         TextField("My Long Text Field", text: $myTextField)
    ///     }
    ///
    /// ![A screenshot showing the effect of setting a minimumScaleFactor on
    /// text in a view.](OpenSwiftUI-View-minimumScaleFactor.png)
    ///
    /// - Parameter factor: A fraction between 0 and 1 (inclusive) you use to
    ///   specify the minimum amount of text scaling that this view permits.
    ///
    /// - Returns: A view that limits the amount of text downscaling.
    @inlinable
    nonisolated public func minimumScaleFactor(_ factor: CGFloat) -> some View {
        environment(\.minimumScaleFactor, factor)
    }

    @_spi(Private)
    nonisolated public func bodyHeadOutdent(_ amount: CGFloat) -> some View {
        environment(\.bodyHeadOutdent, amount)
    }

    /// Sets a transform for the case of the text contained in this view when
    /// displayed.
    ///
    /// The default value is `nil`, displaying the text without any case
    /// changes.
    ///
    /// - Parameter textCase: One of the ``Text/Case`` enumerations; the
    ///   default is `nil`.
    /// - Returns: A view that transforms the case of the text.
    @available(OpenSwiftUI_v2_0, *)
    @inlinable
    nonisolated public func textCase(_ textCase: Text.Case?) -> some View {
        environment(\.textCase, textCase)
    }
}

package struct MaximumLineHeightKey: EnvironmentKey {
    package static let defaultValue: CGFloat = .zero
}

package struct MinimumLineHeightKey: EnvironmentKey {
    package static let defaultValue: CGFloat = .zero
}

package struct MinimumScaleFactorKey: EnvironmentKey {
    package static let defaultValue: CGFloat = 1.0
}

private struct DefaultTextFieldTruncationMode: EnvironmentKey {
    package static var defaultValue: Text.TruncationMode? { nil }
}

private struct TextCaseKey: EnvironmentKey {
    static var defaultValue: Text.Case? { nil }
}

private struct TruncationModeKey: EnvironmentKey {
    static var defaultValue: Text.TruncationMode? { nil }
}

private struct HyphenationDisabledKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct HyphenationFactorKey: EnvironmentKey {
    static var defaultValue: CGFloat { .zero }
}

private struct LineHeightMultipleKey: EnvironmentKey {
    static var defaultValue: CGFloat { .zero }
}

private struct LineSpacingKey: EnvironmentKey {
    static var defaultValue: CGFloat { .zero }
}

private struct TextAlignmentKey: EnvironmentKey {
    static var defaultValue: TextAlignment? { nil }
}

private struct AllowsTighteningKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct AvoidsOrphansKey: EnvironmentKey {
    static var defaultValue: Bool { true }
}

private struct BodyHeadOutdentKey: EnvironmentKey {
    static var defaultValue: CGFloat { .zero }
}

// MARK: - String + Util

extension String {
    package func caseConvertedIfNeeded(_ environment: EnvironmentValues) -> String {
        guard let textCase = environment.textCase else {
            return self
        }
        let result = switch textCase {
        case .uppercase: uppercased(with: environment.locale)
        case .lowercase: lowercased(with: environment.locale)
        }
        return result
    }
}
