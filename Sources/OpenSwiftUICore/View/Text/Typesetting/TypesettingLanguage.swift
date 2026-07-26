//
//  TypesettingLanguage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E539E054FF6DF2E95534C4C9F8C35428 (SwiftUICore)

public import Foundation
#if canImport(CoreText)
import CoreText_Private
#endif

// MARK: - TypesettingLanguage

/// Defines how typesetting language is determined for text.
///
/// Use a modifier like ``View/typesettingLanguage(_:isEnabled:)``
/// to specify the typesetting language.
@available(OpenSwiftUI_v5_0, *)
public struct TypesettingLanguage: Sendable, Equatable {
    package struct Flags: OptionSet {
        package var rawValue: UInt8

        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        package static let modifyFont: TypesettingLanguage.Flags = .init(rawValue: 1 << 0)
    }

    package enum Storage: Equatable {
        case automatic
        case contentAware
        case explicit(Locale.Language, TypesettingLanguage.Flags)
    }

    package var storage: TypesettingLanguage.Storage

    /// Automatic language behavior.
    ///
    /// When determining the language to use for typesetting the current UI
    /// language and preferred languages will be considered. For example, if
    /// the current UI locale is for English and Thai is included in the
    /// preferred languages then line heights will be taller to accommodate the
    /// taller glyphs used by Thai.
    public static let automatic: TypesettingLanguage = .init(storage: .automatic)

    /// Use explicit language.
    ///
    /// An explicit language will be used for typesetting. For example, if used
    /// with Thai language the line heights will be as tall as needed to
    /// accommodate Thai.
    ///
    /// - Parameters:
    ///   - language: The language to use for typesetting.
    /// - Returns: A `TypesettingLanguage`.
    public static func explicit(_ language: Locale.Language) -> TypesettingLanguage {
        .init(storage: .explicit(language, .modifyFont))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension TypesettingLanguage {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public static let contentAware: TypesettingLanguage = .init(storage: .contentAware)
}

// MARK: - View + typesettingLanguage

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Specifies the language for typesetting.
    ///
    /// In some cases `Text` may contain text of a particular language which
    /// doesn't match the device UI language. In that case it's useful to
    /// specify a language so line height, line breaking and spacing will
    /// respect the script used for that language. For example:
    ///
    ///     Text(verbatim: "แอปเปิล")
    ///         .typesettingLanguage(.init(languageCode: .thai))
    ///
    /// Note: this language does not affect text localization.
    ///
    /// - Parameters:
    ///   - language: The explicit language to use for typesetting.
    ///   - isEnabled: A Boolean value that indicates whether text language is
    ///     added
    /// - Returns: A view with the typesetting language set to the value you
    ///   supply.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func typesettingLanguage(
        _ language: Locale.Language,
        isEnabled: Bool = true
    ) -> some View {
        typesettingLanguage(.explicit(language), isEnabled: isEnabled)
    }

    /// Specifies the language for typesetting.
    ///
    /// In some cases `Text` may contain text of a particular language which
    /// doesn't match the device UI language. In that case it's useful to
    /// specify a language so line height, line breaking and spacing will
    /// respect the script used for that language. For example:
    ///
    ///     Text(verbatim: "แอปเปิล").typesettingLanguage(
    ///         .explicit(.init(languageCode: .thai)))
    ///
    /// Note: this language does not affect text localized localization.
    ///
    /// - Parameters:
    ///   - language: The language to use for typesetting.
    ///   - isEnabled: A Boolean value that indicates whether text language is
    ///     added
    /// - Returns: A view with the typesetting language set to the value you
    ///   supply.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func typesettingLanguage(
        _ language: TypesettingLanguage,
        isEnabled: Bool = true
    ) -> some View {
        transformEnvironment(\.typesettingConfiguration) {
            if isEnabled {
                $0.language = language
            }
        }
    }
}

// MARK: - LanguageTextModifier

class LanguageTextModifier: AnyTextModifier {
    let language: TypesettingLanguage

    init(language: TypesettingLanguage) {
        self.language = language
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        // NOTE: This also set languageAwareLineHeightRatio to automatic
        style.typesettingConfiguration = .init(language: language)
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? LanguageTextModifier else {
            return false
        }
        return language == other.language
    }
}

// MARK: - Text + typesettingLanguage

@available(OpenSwiftUI_v1_0, *)
extension Text {

    /// Specifies the language for typesetting.
    ///
    /// In some cases `Text` may contain text of a particular language which
    /// doesn't match the device UI language. In that case it's useful to
    /// specify a language so line height, line breaking and spacing will
    /// respect the script used for that language. For example:
    ///
    ///     Text(verbatim: "แอปเปิล")
    ///         .typesettingLanguage(.init(languageCode: .thai))
    ///
    /// Note: this language does not affect text localization.
    ///
    /// - Parameters:
    ///   - language: The explicit language to use for typesetting.
    ///   - isEnabled: A Boolean value that indicates whether text language is
    ///     added
    /// - Returns: Text with the typesetting language set to the value you
    ///   supply.
    @available(OpenSwiftUI_v5_0, *)
    public func typesettingLanguage(
        _ language: Locale.Language,
        isEnabled: Bool = true
    ) -> Text {
        typesettingLanguage(.explicit(language), isEnabled: isEnabled)
    }

    /// Specifies the language for typesetting.
    ///
    /// In some cases `Text` may contain text of a particular language which
    /// doesn't match the device UI language. In that case it's useful to
    /// specify a language so line height, line breaking and spacing will
    /// respect the script used for that language. For example:
    ///
    ///     Text(verbatim: "แอปเปิล").typesettingLanguage(
    ///         .explicit(.init(languageCode: .thai)))
    ///
    /// Note: this language does not affect text localized localization.
    ///
    /// - Parameters:
    ///   - language: The language to use for typesetting.
    ///   - isEnabled: A Boolean value that indicates whether text language is
    ///     added
    /// - Returns: Text with the typesetting language set to the value you
    ///   supply.
    @available(OpenSwiftUI_v5_0, *)
    public func typesettingLanguage(
        _ language: TypesettingLanguage,
        isEnabled: Bool = true
    ) -> Text {
        guard isEnabled else {
            return self
        }
        let modifier: Text.Modifier = .anyTextModifier(LanguageTextModifier(language: language))
        return modified(with: modifier)
    }
}

// MARK: - TypesettingLanguage + Resolution

extension TypesettingLanguage {
    enum Resolved {
        case language(identifier: String, modifyFont: Bool)
        case font(identifier: String)
        case none
    }

    func resolve(
        with content: (() -> String)?,
        locale: Locale
    ) -> Resolved {
        switch storage {
        case .automatic:
            return .none
        case .contentAware:
            #if canImport(CoreText)
            if let content,
               let identifier = CTFontCopyTallestTextStyleLanguageForString(
                   content() as CFString
               ) as String? {
                return .font(identifier: identifier)
            }
            #endif
            guard let languageCode = locale.language.languageCode else {
                return .none
            }
            return .language(
                identifier: languageCode.identifier,
                modifyFont: true
            )
        case let .explicit(language, flags):
            return .language(
                identifier: language.maximalIdentifier,
                modifyFont: flags.contains(.modifyFont)
            )
        }
    }
}

// MARK: - LanguageFontModifier

extension AnyFontModifier {
    private static var languageModifiers: [String: AnyFontModifier] = [:]

    fileprivate static func languageModifier(_ identifier: String) -> AnyFontModifier {
        if let modifier = languageModifiers[identifier] {
            return modifier
        }
        let modifier = AnyFontModifier.dynamic(
            LanguageFontModifier(identifier: identifier)
        )
        languageModifiers[identifier] = modifier
        return modifier
    }
}

struct LanguageFontModifier: FontModifier {
    var identifier: String

    func modify(
        descriptor: inout CTFontDescriptor,
        in context: Font.Context
    ) {
        #if canImport(CoreText)
        guard CTFontDescriptorCopyAttribute(
            descriptor,
            kCTFontDescriptorLanguageAttribute
        ) == nil else {
            return
        }
        descriptor = CTFontDescriptorCreateCopyWithAttributes(
            descriptor,
            [
                kCTFontDescriptorLanguageAttribute: identifier,
            ] as CFDictionary
        )
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }
}
