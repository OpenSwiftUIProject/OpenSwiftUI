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
        guard isDebuggerAttached, isStyled(options: options) else {
            return
        }
        Log.runtimeIssues("Only unstyled text can be used with %s", [context])
    }

    // MARK: - Text.Modifier [WIP]

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
            // Blocked by Text.Style
            _openSwiftUIUnimplementedWarning()
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
        _openSwiftUIUnimplementedFailure()
    }

    package func resolveString(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions = [],
        idiom: AnyInterfaceIdiom? = nil
    ) -> String {
        switch storage {
        case let .verbatim(string):
            return string
        case let .anyTextStorage(anyTextStorage):
            var resolved = Text.ResolvedString()
            resolved.idiom = idiom
            storage.resolve(into: &resolved, in: environment, with: options)
            return resolved.string
        }
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
        #if os(iOS) || os(visionOS)
        resolved.idiom = .init(.phone)
        #elseif os(macOS)
        resolved.idiom = isCatalyst() ? .init(.pad) : .init(.mac)
        #endif
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
        #if os(iOS) || os(visionOS)
        resolved.idiom = .init(.phone)
        #elseif os(macOS)
        resolved.idiom = isCatalyst() ? .init(.pad) : .init(.mac)
        #endif
        resolve(into: &resolved, in: .init(), with: [])
        if let attributedString = resolved.attributedString {
            description.append(#": "\#(attributedString.string)""#)
        }
        return description
    }
}

// MARK: - AnyTextModifier [WIP]

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
//}

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
@available(OpenSwiftUI_v4_0, *)
extension Text {
    public func contentTransition(_ transition: ContentTransition) -> Text {
        _openSwiftUIUnimplementedFailure()
    }
}

#if canImport(Darwin)

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
        Bundle(
            for: NSClassFromString(
                isAppKitBased() ? "NSApplication" : "UIApplication"
            )!
        )
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

#endif
