//
//  Text.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7800CE2E251A218329C9998E1C3194FD (SwiftUICore)

public import Foundation

// MARK: - Text

/// A view that displays one or more lines of read-only text.
///
/// A text view draws a string in your app's user interface using a
/// ``Font/body`` font that's appropriate for the current platform. You can
/// choose a different standard font, like ``Font/title`` or ``Font/caption``,
/// using the ``View/font(_:)`` view modifier.
///
///     Text("Hamlet")
///         .font(.title)
///
/// ![A text view showing the name "Hamlet" in a title
/// font.](OpenSwiftUI-Text-title.png)
///
/// If you need finer control over the styling of the text, you can use the same
/// modifier to configure a system font or choose a custom font. You can also
/// apply view modifiers like ``Text/bold()`` or ``Text/italic()`` to further
/// adjust the formatting.
///
///     Text("by William Shakespeare")
///         .font(.system(size: 12, weight: .light, design: .serif))
///         .italic()
///
/// ![A text view showing by William Shakespeare in a 12 point, light, italic,
/// serif font.](OpenSwiftUI-Text-font.png)
///
/// To apply styling within specific portions of the text, you can create
/// the text view from an
/// [AttributedString](https://developer.apple.com/documentation/foundation/attributedstring),
/// which in turn allows you to use Markdown to style runs of text. You can
/// mix string attributes and OpenSwiftUI modifiers, with the string attributes
/// taking priority.
///
///     let attributedString = try! AttributedString(
///         markdown: "_Hamlet_ by William Shakespeare")
///
///     var body: some View {
///         Text(attributedString)
///             .font(.system(size: 12, weight: .light, design: .serif))
///     }
///
/// ![A text view showing Hamlet by William Shakespeare in a 12 point, light,
/// serif font, with the title Hamlet in italics.](OpenSwiftUI-Text-attributed.png)
///
/// A text view always uses exactly the amount of space it needs to display its
/// rendered contents, but you can affect the view's layout. For example, you
/// can use the ``View/frame(width:height:alignment:)`` modifier to propose
/// specific dimensions to the view. If the view accepts the proposal but the
/// text doesn't fit into the available space, the view uses a combination of
/// wrapping, tightening, scaling, and truncation to make it fit. With a width
/// of `100` points but no constraint on the height, a text view might wrap a
/// long string:
///
///     Text("To be, or not to be, that is the question:")
///         .frame(width: 100)
///
/// ![A text view showing a quote from Hamlet split over three
/// lines.](OpenSwiftUI-Text-split.png)
///
/// Use modifiers like ``View/lineLimit(_:)``, ``View/allowsTightening(_:)``,
/// ``View/minimumScaleFactor(_:)``, and ``View/truncationMode(_:)`` to
/// configure how the view handles space constraints. For example, combining a
/// fixed width and a line limit of `1` results in truncation for text that
/// doesn't fit in that space:
///
///     Text("Brevity is the soul of wit.")
///         .frame(width: 100)
///         .lineLimit(1)
///
/// ![A text view showing a truncated quote from Hamlet starting Brevity is t
/// and ending with three dots.](OpenSwiftUI-Text-truncated.png)
///
/// ### Localizing strings
///
/// If you initialize a text view with a string literal, the view uses the
/// ``Text/init(_:tableName:bundle:comment:)`` initializer, which interprets the
/// string as a localization key and searches for the key in the table you
/// specify, or in the default table if you don't specify one.
///
///     Text("pencil") // Searches the default table in the main bundle.
///
/// For an app localized in both English and Spanish, the above view displays
/// "pencil" and "lápiz" for English and Spanish users, respectively. If the
/// view can't perform localization, it displays the key instead. For example,
/// if the same app lacks Danish localization, the view displays "pencil" for
/// users in that locale. Similarly, an app that lacks any localization
/// information displays "pencil" in any locale.
///
/// To explicitly bypass localization for a string literal, use the
/// ``Text/init(verbatim:)`` initializer.
///
///     Text(verbatim: "pencil") // Displays the string "pencil" in any locale.
///
/// If you initialize a text view with a variable value, the view uses the
/// ``Text/init(_:)-3dz13`` initializer, which doesn't localize the string. However,
/// you can request localization by creating a ``LocalizedStringKey`` instance
/// first, which triggers the ``Text/init(_:tableName:bundle:comment:)``
/// initializer instead:
///
///     // Don't localize a string variable...
///     Text(writingImplement)
///
///     // ...unless you explicitly convert it to a localized string key.
///     Text(LocalizedStringKey(writingImplement))
///
/// When localizing a string variable, you can use the default table by omitting
/// the optional initialization parameters — as in the above example — just like
/// you might for a string literal.
///
/// When composing a complex string, where there is a need to assemble multiple
/// pieces of text, use string interpolation:
///
///     let name: String = //…
///     Text("Hello, \(name)")
///
/// This would look up the `"Hello, %@"` localization key in the localized
/// string file and replace the format specifier `%@` with the value of `name`
/// before rendering the text on screen.
///
/// Using string interpolation ensures that the text in your app can be localized
/// correctly in all locales, especially in right-to-left languages.
///
/// If you desire to style only parts of interpolated text while ensuring that
/// the content can still be localized correctly, interpolate `Text` or
/// [AttributedString](https://developer.apple.com/documentation/foundation/attributedstring):
///
///     let name = Text(person.name).bold()
///     Text("Hello, \(name)")
///
/// The example above uses ``LocalizedStringKey/StringInterpolation/appendInterpolation(_:)-7xnfe``
/// and will look up the `"Hello, %@"` in the localized string file and
/// interpolate a bold text rendering the value of  `name`.
///
/// Using ``LocalizedStringKey/StringInterpolation/appendInterpolation(_:)-5m52e``
/// you can interpolate ``Image`` in text.
///
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Text: Equatable, Sendable {

    // MARK: - Text.Storage

    @usableFromInline
    @frozen
    package enum Storage: Equatable {
        case verbatim(String)
        case anyTextStorage(AnyTextStorage)

        package func resolve<T>(
            into result: inout T,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions
        ) where T: ResolvedTextContainer {
            switch self {
            case let .verbatim(string):
                result.append(string, in: environment, with: options)
            case let .anyTextStorage(anyTextStorage):
                anyTextStorage.resolve(into: &result, in: environment, with: options)
            }
        }

        package func resolvesToEmpty(
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions = []
        ) -> Bool {
            switch self {
            case let .verbatim(string):
                string.isEmpty
            case let .anyTextStorage(anyTextStorage):
                anyTextStorage.resolvesToEmpty(in: environment, with: options)
            }
        }

        @usableFromInline
        package static func == (lhs: Text.Storage, rhs: Text.Storage) -> Bool {
            switch (lhs, rhs) {
            case let (.verbatim(lString), .verbatim(rString)):
                lString == rString
            case let (.anyTextStorage(lAnyTextStorage), .anyTextStorage(rAnyTextStorage)):
                lAnyTextStorage.isEqual(to: rAnyTextStorage)
            default:
                false
            }
        }

        package func isStyled(options: Text.ResolveOptions = []) -> Bool {
            switch self {
            case .verbatim:
                false
            case let .anyTextStorage( anyTextStorage):
                anyTextStorage.isStyled(options: options)
            }
        }

        package func allowsTypesettingLanguage() -> Bool {
            switch self {
            case .verbatim:
                true
            case let .anyTextStorage( anyTextStorage):
                anyTextStorage.allowsTypesettingLanguage()
            }
        }
    }

    package func assertUnstyled(
        _ context: String = #function,
        options: Text.ResolveOptions = []
    ) {
        guard isDebuggerAttached, isStyled(options: options) else {
            return
        }
        Log.runtimeIssues("Only unstyled text can be used with %s", [context])
    }

    // MARK: - Text.Modifier

    @usableFromInline
    @frozen
    package enum Modifier: Equatable {
        case color(Color?)
        case font(Font?)
        case italic
        case weight(Font.Weight?)
        case kerning(CGFloat)
        case tracking(CGFloat)
        case baseline(CGFloat)
        case rounded
        case anyTextModifier(AnyTextModifier)

        func modify(style: inout Text.Style, environment: EnvironmentValues) {
            switch self {
            case let .color(color):
                guard let color else {
                    style.color = Semantics.TextModifiersOverrideParentValues.isEnabled ? .default : .implicit
                    return
                }
                let baseStyle = style.color.baseStyle(in: environment)
                let copiedStyle = AnyShapeStyle(color).copyStyle(
                    name: .foreground,
                    in: environment,
                    foregroundStyle: baseStyle
                )
                style.color = .explicit(copiedStyle)
            case let .font(font):
                guard let font else {
                    style.baseFont = Semantics.FontModifiersNilResetValues.isEnabled ? .default : .implicit
                    return
                }
                style.baseFont = .explicit(font)
            case .italic:
                style.addFontModifier(type: Font.ItalicModifier.self)
            case let .weight(weight):
                if let weight {
                    style.addFontModifier(Font.WeightModifier(weight: weight))
                } else {
                    style.removeFontModifier(ofType: Font.WeightModifier.self)
                    style.removeFontModifier(ofType: Font.BoldModifier.self)
                }
            case let .kerning(value):
                if Semantics.TextModifiersOverrideParentValues.isEnabled {
                    style.kerning = value
                } else {
                    style.kerning = (style.kerning ?? .zero) + value
                }
            case let .tracking(value):
                style.tracking = value
            case let .baseline(value):
                _ = Semantics.TextModifiersOverrideParentValues.isEnabled
                style.baselineOffset = value
            case .rounded:
                style.addFontModifier(Font.DesignModifier(design: .rounded))
            case let .anyTextModifier(anyTextModifier):
                anyTextModifier.modify(style: &style, environment: environment)
            }
        }

        @usableFromInline
        package static func == (lhs: Text.Modifier, rhs: Text.Modifier) -> Bool {
            switch (lhs, rhs) {
            case let (.color(lColor), .color(rColor)): lColor == rColor
            case let (.font(lFont), .font(rFont)): lFont == rFont
            case (.italic, .italic): true
            case let (.weight(lWeight), .weight(rWeight)): lWeight == rWeight
            case let (.kerning(lValue), .kerning(rValue)): lValue == rValue
            case let (.tracking(lValue), .tracking(rValue)): lValue == rValue
            case let (.baseline(lValue), .baseline(rValue)): lValue == rValue
            case (.rounded, .rounded): true
            case let (.anyTextModifier(lAnyTextModifier), .anyTextModifier(rAnyTextModifier)): lAnyTextModifier.isEqual(to: rAnyTextModifier)
            default: false
            }
        }
    }

    // MARK: - Text.ResolveOptions

    @_spi(ForOpenSwiftUIOnly)
    @available(OpenSwiftUI_v6_0, *)
    public struct ResolveOptions: OptionSet, Sendable {
        public let rawValue: NSInteger

        public init(rawValue: NSInteger) {
            self.rawValue = rawValue
        }

        package init(for environment: EnvironmentValues) {
            self = [
                environment.accessibilityEnabled ? .includeAccessibility : [],
                environment.disableLinkColor ? .disableLinkColor : [],
            ]
        }

        package static let includeAccessibility: Text.ResolveOptions = .init(rawValue: 1 << 0)

        package static let foregroundKeyColor: Text.ResolveOptions = .init(rawValue: 1 << 1)

        package static let writeAuxiliaryMetadata: Text.ResolveOptions = .init(rawValue: 1 << 2)

        package static let includeTransitions: Text.ResolveOptions = .init(rawValue: 1 << 3)

        package static let disableLinkColor: Text.ResolveOptions = .init(rawValue: 1 << 4)

        package static let allowsKeyColors: Text.ResolveOptions = .init(rawValue: 1 << 5)

        package static let allowsTextSuffix: Text.ResolveOptions = .init(rawValue: 1 << 6)

        package static let includeSupportForRepeatedResolution: Text.ResolveOptions = .init(rawValue: 1 << 7)

        @available(OpenSwiftUI_v7_0, *)
        package static let ignoreMarkdown: Text.ResolveOptions = .init(rawValue: 1 << 8)
    }

    @usableFromInline
    package var storage: Text.Storage

    @usableFromInline
    package var modifiers: [Text.Modifier] = [Modifier]()

    /// Creates a text view that displays a string literal without localization.
    ///
    /// Use this initializer to create a text view with a string literal without
    /// performing localization:
    ///
    ///     Text(verbatim: "pencil") // Displays the string "pencil" in any locale.
    ///
    /// If you want to localize a string literal before displaying it, use the
    /// ``Text/init(_:tableName:bundle:comment:)`` initializer instead. If you
    /// want to display a string variable, use the ``Text/init(_:)-3dz13``
    /// initializer, which also bypasses localization.
    ///
    /// - Parameter content: A string to display without localization.
    @inlinable
    public init(verbatim content: String) {
        storage = .verbatim(content)
    }

    /// Creates a text view that displays a stored string without localization.
    ///
    /// Use this initializer to create a text view that displays — without
    /// localization — the text in a string variable.
    ///
    ///     Text(someString) // Displays the contents of `someString` without localization.
    ///
    /// OpenSwiftUI doesn't call the `init(_:)` method when you initialize a text
    /// view with a string literal as the input. Instead, a string literal
    /// triggers the ``Text/init(_:tableName:bundle:comment:)`` method — which
    /// treats the input as a ``LocalizedStringKey`` instance — and attempts to
    /// perform localization.
    ///
    /// By default, OpenSwiftUI assumes that you don't want to localize stored
    /// strings, but if you do, you can first create a localized string key from
    /// the value, and initialize the text view with that. Using a key as input
    /// triggers the ``Text/init(_:tableName:bundle:comment:)`` method instead.
    ///
    /// - Parameter content: The string value to display without localization.
    @_disfavoredOverload
    public init<S>(_ content: S) where S: StringProtocol {
        storage = .verbatim(String(content))
    }

    package func modified(with modifier: Text.Modifier) -> Text {
        var modifiedText = self
        modifiedText.modifiers.append(modifier)
        return modifiedText
    }

    package func resolveStringCheckingForResolvables(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions = [],
        idiom: AnyInterfaceIdiom? = nil
    ) -> (string: String, hasResolvableAttributes: Bool) {
        switch storage {
        case .verbatim(let string):
            return (string, false)
        case .anyTextStorage:
            var resolved = Text.ResolvedString()
            resolved.idiom = idiom
            resolve(into: &resolved, in: environment, with: options)
            return (resolved.string, resolved.hasResolvableAttributes)
        }
    }

    package func resolveString(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions = [],
        idiom: AnyInterfaceIdiom? = nil
    ) -> String {
        switch storage {
        case let .verbatim(string):
            return string
        case .anyTextStorage:
            var resolved = Text.ResolvedString()
            resolved.idiom = idiom
            resolve(into: &resolved, in: environment, with: options)
            return resolved.string
        }
    }

    package func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        let oldStyle = result.style
        if modifiers.isEmpty {
            storage.resolve(into: &result, in: environment, with: options)
        } else {
            for modifier in modifiers.reversed() {
                modifier.modify(style: &result.style, environment: environment)
            }
            storage.resolve(into: &result, in: environment, with: options)
            result.style = oldStyle
        }
    }

    package func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions = []
    ) -> Bool {
        storage.resolvesToEmpty(in: environment, with: options)
    }

    package func isStyled(options: Text.ResolveOptions = []) -> Bool {
        if storage.isStyled(options: options) {
            return true
        }
        for modifier in modifiers {
            switch modifier {
            case let .anyTextModifier(anyTextModifier):
                if anyTextModifier.isStyled(options: options) {
                    return true
                }
            default:
                return true
            }
        }
        return false
    }

    package func allowsTypesettingLanguage() -> Bool {
        storage.allowsTypesettingLanguage()
    }

    package init(anyTextStorage: AnyTextStorage) {
        storage = .anyTextStorage(anyTextStorage)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Text.Storage: @unchecked Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension Text.Modifier: @unchecked Sendable {}

// MARK: - AnyTextStorage

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package class AnyTextStorage {
    func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) -> Bool {
        var resolved = Text.ResolvedString()
        resolved.idiom = _GraphInputs.defaultInterfaceIdiom
        resolve(into: &resolved, in: environment, with: options)
        return resolved.string.isEmpty
    }

    func isEqual(to other: AnyTextStorage) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isStyled(options: Text.ResolveOptions) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func allowsTypesettingLanguage() -> Bool {
        false
    }

    var localizationInfo: _LocalizationInfo {
        .none
    }
}

@available(OpenSwiftUI_v1_0, *)
extension AnyTextStorage: @unchecked Sendable {}

@available(OpenSwiftUI_v4_0, *)
extension AnyTextStorage: CustomDebugStringConvertible {
    @usableFromInline
    package var debugDescription: String {
        var description = "<\(Self.self): \(self)>"
        var resolved = Text.Resolved()
        resolved.idiom = _GraphInputs.defaultInterfaceIdiom
        resolve(into: &resolved, in: .init(), with: [])
        if let attributedString = resolved.attributedString {
            description.append(#": "\#(attributedString.string)""#)
        }
        return description
    }
}

// MARK: - AnyTextModifier

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package class AnyTextModifier {
    func isStyled(options: Text.ResolveOptions) -> Bool {
        true
    }

    func modify(style: inout Text.Style, environment: EnvironmentValues) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isEqual(to: AnyTextModifier) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(*, unavailable)
extension AnyTextModifier: Sendable {}

extension Text.Modifier {
    @inline(__always)
    static func strikethrough(_ lineStyle: Text.LineStyle?) -> Self {
        .anyTextModifier(StrikethroughTextModifier(lineStyle))
    }

    @inline(__always)
    static func underline(_ lineStyle: Text.LineStyle?) -> Self {
        .anyTextModifier(UnderlineTextModifier(lineStyle))
    }

    @inline(__always)
    static func stylisticAlternative(_ alternative: Font._StylisticAlternative) -> Self {
        .anyTextModifier(StylisticAlternativeTextModifier(alternative))
    }

    @inline(__always)
    static func bold(_ isActive: Bool = true) -> Self {
        .anyTextModifier(BoldTextModifier(isActive: isActive))
    }

    @inline(__always)
    static func italic(_ isActive: Bool = true) -> Self {
        .anyTextModifier(ItalicTextModifier(isActive: isActive))
    }

    @inline(__always)
    static func monospaced(_ isActive: Bool = true) -> Self {
        .anyTextModifier(MonospacedTextModifier(isActive: isActive))
    }

    @inline(__always)
    static func design(_ design: Font.Design?) -> Self {
        .anyTextModifier(TextDesignModifier(design))
    }

    @inline(__always)
    static func monospacedDigit() -> Self {
        .anyTextModifier(MonospacedDigitTextModifier())
    }

    @inline(__always)
    static func collapsible() -> Self {
        .anyTextModifier(CollapsibleTextModifier())
    }

    @inline(__always)
    static func width(_ width: CGFloat?) -> Self {
        .anyTextModifier(TextWidthModifier(width))
    }

    @inline(__always)
    static func foregroundStyle<S>(_ style: S) -> Self where S: ShapeStyle {
        .anyTextModifier(TextForegroundStyleModifier(style))
    }

    @inline(__always)
    static func foregroundKeyColor() -> Self {
        .anyTextModifier(TextForegroundKeyColorModifier())
    }
}

final class StrikethroughTextModifier: AnyTextModifier {
    let lineStyle: Text.LineStyle?

    init(_ lineStyle: Text.LineStyle?) {
        self.lineStyle = lineStyle
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.strikethrough = lineStyle.map { .explicit($0) } ?? .default
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? StrikethroughTextModifier else {
            return false
        }
        return lineStyle == other.lineStyle
    }
}

final class UnderlineTextModifier: AnyTextModifier {
    let lineStyle: Text.LineStyle?

    init(_ lineStyle: Text.LineStyle?) {
        self.lineStyle = lineStyle
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.underline = lineStyle.map { .explicit($0) } ?? .default
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? UnderlineTextModifier else {
            return false
        }
        return lineStyle == other.lineStyle
    }
}

private final class StylisticAlternativeTextModifier: AnyTextModifier {
    let value: Font._StylisticAlternative

    init(_ value: Font._StylisticAlternative) {
        self.value = value
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.addFontModifier(Font.StylisticAlternativeModifier(alternative: value))
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? StylisticAlternativeTextModifier else {
            return false
        }
        return value == other.value
    }
}

final class BoldTextModifier: AnyTextModifier {
    let isActive: Bool

    init(isActive: Bool = true) {
        self.isActive = isActive
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        if isActive {
            style.addFontModifier(type: Font.BoldModifier.self)
        } else {
            style.removeFontModifier(ofType: Font.BoldModifier.self)
        }
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? BoldTextModifier else {
            return false
        }
        return isActive == other.isActive
    }
}

final class ItalicTextModifier: AnyTextModifier {
    let isActive: Bool

    init(isActive: Bool = true) {
        self.isActive = isActive
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        if isActive {
            style.addFontModifier(type: Font.ItalicModifier.self)
        } else {
            style.removeFontModifier(ofType: Font.ItalicModifier.self)
        }
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? ItalicTextModifier else {
            return false
        }
        return isActive == other.isActive
    }
}

final class MonospacedTextModifier: AnyTextModifier {
    let isActive: Bool

    init(isActive: Bool = true) {
        self.isActive = isActive
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        if isActive {
            style.addFontModifier(type: Font.MonospacedModifier.self)
        } else {
            style.removeFontModifier(ofType: Font.MonospacedModifier.self)
        }
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? MonospacedTextModifier else {
            return false
        }
        return isActive == other.isActive
    }
}

final class TextDesignModifier: AnyTextModifier {
    let design: Font.Design?

    init(_ design: Font.Design?) {
        self.design = design
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        if let design {
            style.addFontModifier(Font.DesignModifier(design: design))
        } else {
            style.removeFontModifier(ofType: Font.DesignModifier.self)
        }
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? TextDesignModifier else {
            return false
        }
        return design == other.design
    }
}

final class MonospacedDigitTextModifier: AnyTextModifier {
    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.addFontModifier(type: Font.MonospacedDigitModifier.self)
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        other is MonospacedDigitTextModifier
    }
}

final class CollapsibleTextModifier: AnyTextModifier {
    override func isStyled(options: Text.ResolveOptions) -> Bool {
        false
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {}

    override func isEqual(to other: AnyTextModifier) -> Bool {
        other is CollapsibleTextModifier
    }
}

final package class SpeechModifier: AnyTextModifier {
    let value: AccessibilitySpeechAttributes

    init(_ value: AccessibilitySpeechAttributes) {
        self.value = value
    }

    override package func isStyled(options: Text.ResolveOptions) -> Bool {
        options.contains(.includeAccessibility)
    }

    override package func modify(style: inout Text.Style, environment: EnvironmentValues) {
        if let speech = style.speech {
            style.speech = value.combined(with: speech)
        } else {
            style.speech = value
        }
    }

    override package func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? SpeechModifier else {
            return false
        }
        return value == other.value
    }
}

final package class TextShadowModifier: AnyTextModifier {
    let shadow: _ShadowEffect

    init(_ shadow: _ShadowEffect) {
        self.shadow = shadow
    }

    override package func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.shadow = self
    }

    override package func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? TextShadowModifier else {
            return false
        }
        return shadow == other.shadow
    }
}

final package class TextTransitionModifier: AnyTextModifier {
    let resolved: Text.ResolvedProperties.Transition

    init(_ transition: ContentTransition) {
        self.resolved = .init(transition: transition)
    }

    override package func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.transition = self
    }

    override package func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? TextTransitionModifier else {
            return false
        }
        return resolved == other.resolved
    }
}

final class TextWidthModifier: AnyTextModifier {
    let width: CGFloat?

    init(_ width: CGFloat?) {
        self.width = width
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        if let width {
            style.addFontModifier(Font.WidthModifier(width: width))
        } else {
            style.removeFontModifier(ofType: Font.WidthModifier.self)
        }
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? TextWidthModifier else {
            return false
        }
        return width == other.width
    }
}

final class TextForegroundStyleModifier: AnyTextModifier {
    let style: AnyShapeStyle

    init<S>(_ style: S) where S: ShapeStyle {
        self.style = AnyShapeStyle(style)
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        let foregroundStyle = style.color.baseStyle(in: environment)
        let newStyle = self.style.copyStyle(in: environment, foregroundStyle: foregroundStyle)
        style.color = .explicit(newStyle)
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? TextForegroundStyleModifier else {
            return false
        }
        return style.storage == other.style.storage
    }
}

final class TextForegroundKeyColorModifier: AnyTextModifier {
    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.color = .foregroundKeyColor(base: style.color.baseStyle(in: environment))
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        other is TextForegroundKeyColorModifier
    }
}

extension Text.Style.TextStyleColor {
    fileprivate func baseStyle(in environment: EnvironmentValues) -> AnyShapeStyle {
        switch self {
        case .implicit:
            return environment.foregroundStyle ?? HierarchicalShapeStyle.sharedPrimary
        case let .explicit(anyShapeStyle):
            return anyShapeStyle
        case .default:
            return environment.defaultForegroundStyle ?? HierarchicalShapeStyle.sharedPrimary
        case let .foregroundKeyColor(base):
            return base
        }
    }
}

@available(OpenSwiftUI_v2_0, *)
extension Text {
    public func _resolveText(in environment: EnvironmentValues) -> String {
        resolveString(in: environment)
    }
}

// MARK: - _LocalizationInfo

@available(OpenSwiftUI_v2_0, *)
public enum _LocalizationInfo: Equatable {
    case none
    case verbatim(String)
    case localized(key: String, tableName: String? = nil, bundle: Bundle? = nil, hasFormatting: Bool = false)
}

@available(*, unavailable)
extension _LocalizationInfo: Sendable {}

@available(OpenSwiftUI_v2_0, *)
extension Text {
    public var _localizationInfo: _LocalizationInfo {
        switch storage {
        case let .verbatim(string):
            .verbatim(string)
        case let .anyTextStorage(storage):
            storage.localizationInfo
        }
    }
}

// MARK: - Text + shadow

@_spi(_)
@available(OpenSwiftUI_v3_0, *)
extension Text {
    public func shadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> Text {
        modified(with: .anyTextModifier(TextShadowModifier(
            _ShadowEffect(color: color, radius: radius, offset: CGSize(width: x, height: y))
        )))
    }
}

// MARK: - Text + contentTransition

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension Text {
    public func contentTransition(_ transition: ContentTransition) -> Text {
        modified(with: .anyTextModifier(TextTransitionModifier(transition)))
    }
}

// MARK: - Text.System

extension Text {
    package enum System {
        package static let back: Text = Text.System.kitLocalized("Back")
        package static let cancel: Text = Text.System.kitLocalized("Cancel")
        package static let uiClose: Text = Text.System.kitLocalized("Close")
        package static let uiCopy: Text = Text.System.kitLocalized("Copy")
        package static let uiDelete: Text = Text.System.kitLocalized("Delete")
        package static let done: Text = Text.System.kitLocalized("Done")
        package static let edit: Text = Text.System.kitLocalized("Edit")
        package static let uiLookUp: Text = Text.System.kitLocalized("LookUp")
        package static let off: Text = Text.System.kitLocalized("Off")
        package static let ok: Text = Text.System.kitLocalized("OK")
        package static let on: Text = Text.System.kitLocalized("On")
        package static let paste: Text = Text.System.kitLocalized("Paste")
        package static let search: Text = Text.System.kitLocalized("Search")
        package static let share: Text = Text.System.kitLocalized("Share")
        package static let shareEllipses: Text = Text.System.kitLocalized("Share…")
        package static let rename: Text = Text.System.kitLocalized("Rename")
    }
}

extension String {
    package enum System {}
}

extension String.System {
    package static func kitLocalized(
        _ key: String,
        tableName: String = "Localizable",
        comment: String
    ) -> String {
        NSLocalizedString(
            key,
            tableName: tableName,
            bundle: .kit,
            value: "",
            comment: comment
        )
    }
}

extension Bundle {
    package static var kit: Bundle {
        #if canImport(Darwin)
        return Bundle(
            for: NSClassFromString(
                isAppKitBased() ? "NSApplication" : "UIApplication"
            )!
        )
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return .main
        #endif
    }
}

extension Text.System {
    package static func kitLocalized(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        comment: StaticString? = nil
    ) -> Text {
        Text(
            key,
            tableName: tableName ?? "Localizable",
            bundle: .kit,
            comment: comment
        )
    }
}

extension Text.System {
    package static func openSwiftUICoreLocalized(
        _ key: LocalizedStringKey,
        tableName: String = "Core",
        comment: StaticString? = nil
    ) -> Text {
        Text(
            key,
            tableName: tableName,
            bundle: .openSwiftUICore,
            comment: comment
        )
    }
}

private class OpenSwiftUICoreClass: NSObject {}

extension Bundle {
    package static var openSwiftUICore: Bundle {
        Bundle(for: OpenSwiftUICoreClass.self)
    }
}
