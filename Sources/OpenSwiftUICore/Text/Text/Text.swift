//
//  Text.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7800CE2E251A218329C9998E1C3194FD (SwiftUICore)

public import Foundation

#if !canImport(ObjectiveC)
public typealias NSInteger = Int
#endif

// MARK: - Text [WIP]

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
        guard isDebuggerAttached else {
            return
        }
//        guard isStyled(options: options) else {
//
//        }
        // Only unstyled text can be used with %s
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v1_0, *)
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

        @usableFromInline
        package static func == (lhs: Text.Modifier, rhs: Text.Modifier) -> Bool {
            _openSwiftUIUnimplementedFailure()
        }
    }

    @_spi(ForOpenSwiftUIOnly)
    @available(OpenSwiftUI_v6_0, *)
    public struct ResolveOptions: OptionSet, Sendable {
        @_spi(ForOpenSwiftUIOnly)
        public let rawValue: NSInteger

        @_spi(ForOpenSwiftUIOnly)
        public init(rawValue: NSInteger) {
            _openSwiftUIUnimplementedFailure()
        }

        @_spi(ForOpenSwiftUIOnly)
        package init(for environment: EnvironmentValues) {
            _openSwiftUIUnimplementedFailure()
        }

//        @_spi(ForOpenSwiftUIOnly)
//        package static let includeAccessibility: Text.ResolveOptions
//
//        @_spi(ForOpenSwiftUIOnly)
//        package static let foregroundKeyColor: Text.ResolveOptions
//
//        @_spi(ForOpenSwiftUIOnly)
//        package static let writeAuxiliaryMetadata: Text.ResolveOptions
//
//        @_spi(ForOpenSwiftUIOnly)
//        package static let includeTransitions: Text.ResolveOptions
//
//        @_spi(ForOpenSwiftUIOnly)
//        package static let disableLinkColor: Text.ResolveOptions
//
//        @_spi(ForOpenSwiftUIOnly)
//        package static let allowsKeyColors: Text.ResolveOptions
//
//        @_spi(ForOpenSwiftUIOnly)
//        package static let allowsTextSuffix: Text.ResolveOptions
//
//        @_spi(ForOpenSwiftUIOnly)
//        package static let includeSupportForRepeatedResolution: Text.ResolveOptions

        @_spi(ForOpenSwiftUIOnly)
        @available(OpenSwiftUI_v6_0, *)
        public typealias ArrayLiteralElement = Text.ResolveOptions

        @_spi(ForOpenSwiftUIOnly)
        @available(OpenSwiftUI_v6_0, *)
        public typealias Element = Text.ResolveOptions

        @_spi(ForOpenSwiftUIOnly)
        @available(OpenSwiftUI_v6_0, *)
        public typealias RawValue = NSInteger
    }

    @usableFromInline
    package var storage: Text.Storage

    @usableFromInline
    package var modifiers: [Text.Modifier] = [Modifier]()

    @inlinable
    public init(verbatim content: String) {
        storage = .verbatim(content)
    }

    @_disfavoredOverload
    public init<S>(_ content: S) where S: StringProtocol {
        _openSwiftUIUnimplementedFailure()
    }

    package func modified(with modifier: Text.Modifier) -> Text {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolveStringCheckingForResolvables(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions = [],
        idiom: AnyInterfaceIdiom? = nil
    ) -> (string: String, hasResolvableAttributes: Bool) {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolveString(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions = [],
        idiom: AnyInterfaceIdiom? = nil
    ) -> String {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions = []
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func isStyled(options: Text.ResolveOptions = []) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func allowsTypesettingLanguage() -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package init(anyTextStorage: AnyTextStorage) {
        _openSwiftUIUnimplementedFailure()
    }

    public static func == (a: Text, b: Text) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Text.Storage: @unchecked Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension Text.Modifier: @unchecked Sendable {}

// MARK: - AnyTextStorage [WIP]

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package class AnyTextStorage {
    func resolve<T>(
        into result: inout T,
        in: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func resolvesToEmpty(in environment: EnvironmentValues, with: Text.ResolveOptions) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    func isEqual(to: AnyTextStorage) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }


    func isStyled(options: Text.ResolveOptions) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func allowsTypesettingLanguage() -> Bool {
        false
    }

    var localizationInfo: _LocalizationInfo {
        _openSwiftUIUnimplementedFailure()
    }
}


//var debugDescription: Swift.String {
//    get
//}

@available(OpenSwiftUI_v1_0, *)
extension AnyTextStorage: @unchecked Sendable {}

@available(OpenSwiftUI_v3_0, *)
extension AnyTextStorage: CustomDebugStringConvertible {
    @usableFromInline
    package var debugDescription: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package class AnyTextModifier {
}

@available(*, unavailable)
extension AnyTextModifier: Sendable {}

//final package class SpeechModifier: AnyTextModifier {
//    final package let value: AccessibilitySpeechAttributes
//
//    package init(_ value: AccessibilitySpeechAttributes) {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    final package func isStyled(options: Text.ResolveOptions = []) -> Bool {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    final package func modify(style: inout Text.Style, environment: EnvironmentValues) {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    final package func isEqual(to other: AnyTextModifier) -> Bool {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    @objc
//    deinit {}
//}
//
//final package class TextShadowModifier: AnyTextModifier {
//    final package func modify(style: inout Text.Style, environment: EnvironmentValues) {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    final package func isEqual(to other: AnyTextModifier) -> Bool {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    @objc
//    deinit {}
//}
//
//final package class TextTransitionModifier: AnyTextModifier {
//    final package func modify(style: inout Text.Style, environment: EnvironmentValues) {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    final package func isEqual(to other: AnyTextModifier) -> Bool {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    @objc
//    deinit {}
//}

@available(OpenSwiftUI_v2_0, *)
extension Text {
    @available(OpenSwiftUI_v2_0, *)
    public func _resolveText(in environment: EnvironmentValues) -> String {

        _openSwiftUIUnimplementedFailure()
    }
}

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
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(_)
@available(OpenSwiftUI_v3_0, *)
extension Text {
    @_spi(_)
    public func shadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> Text {
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(OpenSwiftUIPrivate)
@available(OpenSwiftUI_v3_0, *)
extension Text {
    @_spi(OpenSwiftUIPrivate)
    public func contentTransition(_ transition: ContentTransition) -> Text {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Text {
    package enum System {
//        package static let back: Text
//        package static let cancel: Text
//        package static let uiClose: Text
//        package static let uiCopy: Text
//        package static let uiDelete: Text
//        package static let done: Text
//        package static let edit: Text
//        package static let uiLookUp: Text
//        package static let off: Text
//        package static let ok: Text
//        package static let on: Text
//        package static let paste: Text
//        package static let search: Text
//        package static let share: Text
//        package static let shareEllipses: Text
//        package static let rename: Text
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
        _openSwiftUIUnimplementedFailure()
    }
}

extension Bundle {
    package static var kit: Bundle {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Text.System {
    package static func kitLocalized(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        comment: StaticString? = nil
    ) -> Text {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Text.System {
    package static func swiftUICoreLocalized(
        _ key: LocalizedStringKey,
        tableName: String = "Core",
        comment: StaticString? = nil
    ) -> Text {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Bundle {
    package static var swiftUICore: Bundle {
        _openSwiftUIUnimplementedFailure()
    }
}

// FIXME
extension Text: PrimitiveView, UnaryView {}
