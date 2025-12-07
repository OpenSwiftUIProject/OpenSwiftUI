//
//  ResolvedText.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7AFAB46D18FA6D189589CFA78D8B2B2E (SwiftUICore)

package import Foundation
package import UIFoundation_Private

// MARK: - ResolvedTextContainer

package protocol ResolvedTextContainer {
    var style: Text.Style { get set }

    var idiom: AnyInterfaceIdiom? { get }

    mutating func append<S>(
        _ string: S,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
        isUniqueSizeVariant: Bool
    ) where S: StringProtocol

    mutating func append(
        _ attributedString: NSAttributedString,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
        isUniqueSizeVariant: Bool
    )

    mutating func append(
        _ image: Image.Resolved,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    )

    mutating func append(
        _ namedImage: Image.NamedResolved,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    )

    mutating func append<R>(
        resolvable: R,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions,
        transition: ContentTransition?
    ) where R: ResolvableStringAttribute
}

extension ResolvedTextContainer {
    mutating func append<S>(
        _ string: S,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
    ) where S: StringProtocol {
        append(
            string,
            in: env,
            with: options,
            isUniqueSizeVariant: env.textSizeVariant != .regular
        )
    }

    mutating func append(
        _ attributedString: NSAttributedString,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
    ) {
        append(
            attributedString,
            in: env,
            with: options,
            isUniqueSizeVariant: env.textSizeVariant != .regular
        )
    }
}

extension Text {
    package struct Resolved: ResolvedTextContainer {
        package var style: Text.Style = .init()

        package var attributedString: NSMutableAttributedString?

        package var includeDefaultAttributes: Bool = true

        package var idiom: AnyInterfaceIdiom?

        package var properties: Text.ResolvedProperties = .init()

        package init() {
            _openSwiftUIEmptyStub()
        }

        package mutating func append<S>(
            _ string: S,
            in env: EnvironmentValues,
            with options: Text.ResolveOptions,
            isUniqueSizeVariant: Bool
        ) where S: StringProtocol {
            var string = String(string).caseConvertedIfNeeded(env)
            let attributes = style.nsAttributes(
                content: { string },
                environment: env,
                includeDefaultAttributes: includeDefaultAttributes,
                with: options,
                properties: &properties
            )
            append(string, with: attributes, in: env)
            if attributedString!.isEmptyOrTerminatedByParagraphSeparator {
                properties.paragraph.cachedStyle = nil
            }
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func append(
            _ attributedString: NSAttributedString,
            in env: EnvironmentValues,
            with options: Text.ResolveOptions,
            isUniqueSizeVariant: Bool
        ) {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func append(
            _ image: Image.Resolved,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions
        ) {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func append(
            _ namedImage: Image.NamedResolved,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions
        ) {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func append<R>(
            resolvable: R,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions,
            transition: ContentTransition?
        ) where R: ResolvableStringAttribute {
            _openSwiftUIUnimplementedFailure()
        }

        package func nsAttributes(
            content: (() -> String)?,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions,
            properties: inout Text.ResolvedProperties
        ) -> [NSAttributedString.Key: Any] {
            _openSwiftUIUnimplementedFailure()
        }

        private mutating func append(
            _ string: String,
            with attributes: [NSAttributedString.Key: Any],
            in environment: EnvironmentValues
        ) {
            var string = string.caseConvertedIfNeeded(environment)
            if environment.shouldRedactContent {
                string = String.init(repeating: "􀮷", count: string.count)
            }
            if environment.sensitiveContent {
                properties.addSensitive()
            }
            if let attributedString {
                attributedString.append(
                    NSAttributedString(
                        string: string,
                        attributes: attributes
                    )
                )
            } else {
                attributedString = NSMutableAttributedString(
                    string: string,
                    attributes: attributes
                )
            }
        }
    }

    // MARK: - Text.Style [WIP]

    package struct Style {
        internal var baseFont: TextStyleFont
        internal var fontModifiers: [AnyFontModifier]
        internal var color: TextStyleColor
        internal var backgroundColor: Color?
        internal var baselineOffset: CGFloat?
        internal var kerning: CGFloat?
        internal var tracking: CGFloat?
        internal var strikethrough: LineStyle
        internal var underline: LineStyle
        internal var encapsulation: Text.Encapsulation?
        internal var speech: AccessibilitySpeechAttributes?
        package var accessibility: AccessibilityTextAttributes?
//        internal var glyphInfo: CTGlyphInfo?
//        internal var shadow: TextShadowModifier?
//        internal var transition: TextTransitionModifier?
//        internal var scale: Text.Scale?
//        internal var superscript: Text.Superscript?
        internal var typesettingConfiguration: TypesettingConfiguration
//        internal var customAttributes: [TextAttributeModifierBase]
        #if canImport(Darwin)
//        internal var adaptiveImageGlyph: AttributedString.AdaptiveImageGlyph?
        #endif
        package var clearedFontModifiers: Set<ObjectIdentifier>

        init() {
            _openSwiftUIUnimplementedFailure()
        }

        // MARK: - Text.Style.LineStyle

        package enum LineStyle {
            case implicit
            case explicit(Text.LineStyle)
            case `default`

            package func resolve(
                in environment: EnvironmentValues,
                fallbackStyle: @autoclosure () -> Text.LineStyle?
            ) -> Text.LineStyle.Resolved? {
                let style: Text.LineStyle
                switch self {
                case .implicit:
                    guard let fallbackStyle = fallbackStyle() else {
                        return nil
                    }
                    style = fallbackStyle
                case let .explicit(lineStyle):
                    style = lineStyle
                case .default:
                    return nil
                }
                return Text.LineStyle.Resolved(
                    nsUnderlineStyle: style.nsUnderlineStyle,
                    color: style.color?.resolve(in: environment)
                )
            }
        }

        // MARK: - Text.Style.TextStyleColor [WIP]

        package enum TextStyleColor {
            case implicit
            case explicit(AnyShapeStyle)
            case `default`
            case foregroundKeyColor(base: AnyShapeStyle)

            package func resolve(
                in environment: EnvironmentValues,
                with options: Text.ResolveOptions,
                properties: inout Text.ResolvedProperties,
                includeDefaultAttributes: Bool = true
            ) -> Color.Resolved? {
                let style: AnyShapeStyle
                switch self {
                case .implicit:
                    guard includeDefaultAttributes else {
                        return nil
                    }
                    guard !options.contains(.foregroundKeyColor) else {
                        return .init(linearWhite: -1, opacity: 1)
                    }
                    let s = environment.defaultForegroundStyle
                    style = .init(s?.fallbackColor(in: environment, level: 0) ?? .primary)
                case .explicit(let anyShapeStyle):
                    style = anyShapeStyle
                case .default:
                    guard includeDefaultAttributes else {
                        return nil
                    }
                    guard !options.contains(.foregroundKeyColor) else {
                        return .init(linearWhite: -1, opacity: 1)
                    }
                    let s = environment.foregroundStyle
                    style = .init(s?.fallbackColor(in: environment, level: 0) ?? .primary)
                case .foregroundKeyColor(let base):
                    guard !options.contains(.allowsKeyColors) else {
                        return .init(linearWhite: -1, opacity: 1)
                    }
                    style = base
                }
                if options.contains(.allowsKeyColors) {
                    var shape = _ShapeStyle_Shape(
                        operation: .resolveStyle(name: .foreground, levels: 0..<1),
                        environment: environment,
                        role: .stroke
                    )
                    style._apply(to: &shape)
                    let shapeStyle = shape.stylePack[.foreground, 0]
                    return properties.addCustomStyle(shapeStyle)
                } else {
                    let color = style.fallbackColor(in: environment, level: 0) ?? .foreground
                    return color.resolve(in: environment)
                }
            }
        }

        // MARK: - Text.Style.TextStyleFont

        package enum TextStyleFont {
            case implicit
            case explicit(Font)
            case `default`

            package func resolve(
                in environment: EnvironmentValues,
                includeDefaultAttributes: Bool = true
            ) -> Font? {
                guard case let .explicit(font) = self else {
                    guard includeDefaultAttributes else {
                        return nil
                    }
                    if case .implicit = self {
                        return environment.effectiveFont
                    } else { // default
                        return environment.defaultFont ?? environment.fallbackFont
                    }
                }
                return font
            }
        }

        package func fontTraits(in environment: EnvironmentValues) -> Font.ResolvedTraits {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func addFontModifier<M>(_ modifier: M) where M: FontModifier {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func addFontModifier<M>(type: M.Type) where M: StaticFontModifier {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func removeFontModifier<M>(ofType _: M.Type) where M: FontModifier {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func removeFontModifier<M>(ofType _: M.Type) where M: StaticFontModifier {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package struct ResolvedProperties {
        package var insets: EdgeInsets

        package var features: Text.ResolvedProperties.Features

        package var styles: [_ShapeStyle_Pack.Style]

        package var transitions: [Text.ResolvedProperties.Transition]

        // package var suffix: ResolvedTextSuffix

        package struct CustomAttachments {
            package var characterIndices: [Int]

            package init(characterIndices: [Int] = []) {
                _openSwiftUIUnimplementedFailure()
            }

            package var isEmpty: Bool {
                _openSwiftUIUnimplementedFailure()
            }
        }

        package var customAttachments: Text.ResolvedProperties.CustomAttachments

        package init() {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func registerCustomAttachment(at offset: Int) {
            _openSwiftUIUnimplementedFailure()
        }

        package struct Features: OptionSet {
            package let rawValue: UInt16

            package init(rawValue: UInt16) {
                self.rawValue = rawValue
            }

            package static let keyColor: Text.ResolvedProperties.Features = .init(rawValue: 1 << 0)

            package static let attachments: Text.ResolvedProperties.Features = .init(rawValue: 1 << 1)

            package static let sensitive: Text.ResolvedProperties.Features = .init(rawValue: 1 << 2)

            package static let customRenderer: Text.ResolvedProperties.Features = .init(rawValue: 1 << 3)

            package static let useTextLayoutManager: Text.ResolvedProperties.Features = .init(rawValue: 1 << 4)

            package static let useTextSuffix: Text.ResolvedProperties.Features = .init(rawValue: 1 << 5)

            package static let produceTextLayout: Text.ResolvedProperties.Features = .init(rawValue: 1 << 6)

            package static let checkInterpolationStrategy: Text.ResolvedProperties.Features = .init(rawValue: 1 << 8)

            package static let isUniqueSizeVariant: Text.ResolvedProperties.Features = .init(rawValue: 1 << 8)
        }

        package struct Transition: Equatable {
            package var transition: ContentTransition

            package init(transition: ContentTransition) {
                self.transition = transition
            }
        }

        package struct Paragraph {
            package var compositionLanguage: NSCompositionLanguage

            var cachedStyle: NSParagraphStyle?
        }

        package var paragraph: Text.ResolvedProperties.Paragraph

        package mutating func addColor(_ c: Color.Resolved) {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func addAttachment() {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func addSensitive() {
            features.insert(.sensitive)
        }

        package mutating func addCustomStyle(_ style: _ShapeStyle_Pack.Style) -> Color.Resolved {
            _openSwiftUIUnimplementedFailure()
        }
    }
}

extension Text {
    struct ResolvedString: ResolvedTextContainer {
        var style: Text.Style = .init()
        var idiom: AnyInterfaceIdiom?
        var string: String = ""
        var hasResolvableAttributes: Bool = false

        init() {
            _openSwiftUIEmptyStub()
        }

        mutating func append<S>(
            _ string: S,
            in env: EnvironmentValues,
            with options: Text.ResolveOptions,
            isUniqueSizeVariant: Bool
        ) where S: StringProtocol {
            var s = String(string).caseConvertedIfNeeded(env)
            if env.shouldRedactContent {
                s = String(repeating: "􀮷", count: s.count)
            }
            self.string.append(s)
        }

        mutating func append(
            _ attributedString: NSAttributedString,
            in env: EnvironmentValues,
            with options: Text.ResolveOptions,
            isUniqueSizeVariant: Bool
        ) {
            append(
                attributedString.string,
                in: env,
                with: options,
                isUniqueSizeVariant: isUniqueSizeVariant
            )
        }

        mutating func append(
            _ image: Image.Resolved,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions
        ) {
            string.append("￼") // object replacement character (U+FFFC)
        }

        mutating func append(
            _ namedImage: Image.NamedResolved,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions
        ) {
            string.append("￼") // object replacement character (U+FFFC)
        }

        mutating func append<R>(
            resolvable: R,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions,
            transition: ContentTransition?
        ) where R: ResolvableStringAttribute {
            let context = ResolvableStringResolutionContext(
                referenceDate: nil,
                environment: environment,
                maximumWidth: nil
            )
            guard let attributedString = resolvable.resolve(in: context) else {
                Log.internalWarning("Unable to resolve custom attribute \(resolvable)")
                return
            }
            append(
                String(attributedString.characters),
                in: environment,
                with: options
            )
        }
    }
}

extension EnvironmentValues {
    private struct DisableLinkColorKey: EnvironmentKey {
        static var defaultValue: Bool { false }
    }

    package var disableLinkColor: Bool {
        get { self[DisableLinkColorKey.self] }
        set { self[DisableLinkColorKey.self] = newValue }
    }
}
