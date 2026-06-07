//
//  Text+Localized.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8C53218A357EE528547B0855666BD2E5 (SwiftUICore)

public import Foundation
import OpenAttributeGraphShims
import OpenSwiftUI_SPI

// MARK: - Text + LocalizedStringKey

@available(OpenSwiftUI_v1_0, *)
extension Text {

    /// Creates a text view that displays localized content identified by a key.
    ///
    /// Use this initializer to look for the `key` parameter in a localization
    /// table and display the associated string value in the initialized text
    /// view. If the initializer can't find the key in the table, or if no table
    /// exists, the text view displays the string representation of the key
    /// instead.
    ///
    ///     Text("pencil") // Localizes the key if possible, or displays "pencil" if not.
    ///
    /// When you initialize a text view with a string literal, the view triggers
    /// this initializer because it assumes you want the string localized, even
    /// when you don't explicitly specify a table, as in the above example. If
    /// you haven't provided localization for a particular string, you still get
    /// reasonable behavior, because the initializer displays the key, which
    /// typically contains the unlocalized string.
    ///
    /// If you initialize a text view with a string variable rather than a
    /// string literal, the view triggers the ``Text/init(_:)-9d1g4``
    /// initializer instead, because it assumes that you don't want localization
    /// in that case. If you do want to localize the value stored in a string
    /// variable, you can choose to call the `init(_:tableName:bundle:comment:)`
    /// initializer by first creating a ``LocalizedStringKey`` instance from the
    /// string variable:
    ///
    ///     Text(LocalizedStringKey(someString)) // Localizes the contents of `someString`.
    ///
    /// If you have a string literal that you don't want to localize, use the
    /// ``Text/init(verbatim:)`` initializer instead.
    ///
    /// ### Styling localized strings with markdown
    ///
    /// If the localized string or the fallback key contains Markdown, the
    /// view displays the text with appropriate styling. For example, consider
    /// an app with the following entry in its Spanish localization file:
    ///
    ///     "_Please visit our [website](https://www.example.com)._" = "_Visita nuestro [sitio web](https://www.example.com)._";
    ///
    /// You can create a `Text` view with the Markdown-formatted base language
    /// version of the string as the localization key, like this:
    ///
    ///     Text("_Please visit our [website](https://www.example.com)._")
    ///
    /// When viewed in a Spanish locale, the view uses the Spanish text from the
    /// strings file, applying the Markdown styling.
    ///
    /// ![A text view that says Visita nuestro sitio web, with all text
    /// displayed in italics. The words sitio web are colored blue to indicate
    /// they are a link.](OpenSwiftUI-Text-init-localized.png)
    ///
    /// > Important: `Text` doesn't render all styling possible in Markdown. It
    /// doesn't support line breaks, soft breaks, or any style of paragraph- or
    /// block-based formatting like lists, block quotes, code blocks, or tables.
    /// It also doesn't support the
    /// [imageURL](https://developer.apple.com/documentation/Foundation/AttributeScopes/FoundationAttributes/3796122-imageURL)
    /// attribute. Parsing with OpenSwiftUI treats any whitespace in the Markdown
    /// string as described by the
    /// [inlineOnlyPreservingWhitespace](https://developer.apple.com/documentation/Foundation/AttributedString/MarkdownParsingOptions/InterpretedSyntax/inlineOnlyPreservingWhitespace)
    /// parsing option.
    ///
    /// - Parameters:
    ///   - key: The key for a string in the table identified by `tableName`.
    ///   - tableName: The name of the string table to search. If `nil`, use the
    ///     table in the `Localizable.strings` file.
    ///   - bundle: The bundle containing the strings file. If `nil`, use the
    ///     main bundle.
    ///   - comment: Contextual information about this key-value pair.
    @_semantics("openswiftui.init_with_localization")
    @_semantics("swiftui.init_with_localization")
    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.init(
            anyTextStorage: LocalizedTextStorage(
                key: key,
                table: tableName,
                bundle: bundle
            )
        )
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Text {
    func withInlinePresentationIntent(from attributes: [NSAttributedString.Key: Any]) -> Text {
        guard let inlinePresentationIntent = attributes[.inlinePresentationIntent] as? UInt else {
            return self
        }
        var text = self
        if (inlinePresentationIntent & (1 << 0)) != 0 {
            text.modifiers.append(.italic)
        }
        if (inlinePresentationIntent & (1 << 1)) != 0 {
            text.modifiers.append(.anyTextModifier(BoldTextModifier()))
        }
        if (inlinePresentationIntent & (1 << 2)) != 0 {
            text.modifiers.append(.anyTextModifier(MonospacedTextModifier()))
        }
        if (inlinePresentationIntent & (1 << 5)) != 0 {
            text = text.strikethrough()
        }
        return text
    }
}

// MARK: - LocalizedStringKey

/// The key used to look up an entry in a strings file or strings dictionary
/// file.
///
/// Initializers for several OpenSwiftUI types -- such as ``Text``,
/// ``Toggle``, ``Picker`` and others --  implicitly look up a localized string
/// when you provide a string literal. When you use the initializer
/// `Text("Hello")`, OpenSwiftUI creates a `LocalizedStringKey` for you and
/// uses that to look up a localization of the `Hello` string. This works
/// because `LocalizedStringKey` conforms to
/// [ExpressibleByStringLiteral](https://developer.apple.com/documentation/Swift/ExpressibleByStringLiteral).
///
/// Types whose initializers take a `LocalizedStringKey` usually have
/// a corresponding initializer that accepts a parameter that conforms to
/// [StringProtocol](https://developer.apple.com/documentation/Swift/StringProtocol).
/// Passing a `String` variable to these initializers avoids localization,
/// which is usually appropriate when the variable contains a user-provided
/// value.
///
/// As a general rule, use a string literal argument when you want
/// localization, and a string variable argument when you don't. In the case
/// where you want to localize the value of a string variable, use the string to
/// create a new `LocalizedStringKey` instance.
///
/// The following example shows how to create ``Text`` instances both
/// with and without localization. The title parameter provided to the
/// ``Section`` is a literal string, so OpenSwiftUI creates a
/// `LocalizedStringKey` for it. However, the string entries in the
/// `messageStore.today` array are `String` variables, so the ``Text`` views
/// in the list use the string values verbatim.
///
///     List {
///         Section(header: Text("Today")) {
///             ForEach(messageStore.today) { message in
///                 Text(message.title)
///             }
///         }
///     }
///
/// If the app is localized into Japanese with the following
/// translation of its `Localizable.strings` file:
///
///     "Today" = "今日";
///
/// When run in Japanese, the example produces a
/// list like the following, localizing "Today" for the section header, but not
/// the list items.
///
/// ![A list with a single section header displayed in Japanese.
/// The items in the list are all in English: New for Monday, Account update,
/// and Server
/// maintenance.](OpenSwiftUI-LocalizedStringKey-Today-List-Japanese.png)
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct LocalizedStringKey: Equatable, ExpressibleByStringInterpolation {
    var key: String
    var hasFormatting: Bool = false
    private var arguments: [LocalizedStringKey.FormatArgument]

    /// Creates a localized string key from the given string value.
    ///
    /// - Parameter value: The string to use as a localization key.
    public init(_ value: String) {
        self.init(stringLiteral: value)
    }

    /// Creates a localized string key from the given string literal.
    ///
    /// - Parameter value: The string literal to use as a localization key.
    @_semantics("openswiftui.localized_string_key.init_literal")
    @_semantics("swiftui.localized_string_key.init_literal")
    public init(stringLiteral value: String) {
        self.key = value
        self.arguments = []
    }

    /// Creates a localized string key from the given string interpolation.
    ///
    /// To create a localized string key from a string interpolation, use
    /// the `\()` string interpolation syntax. Swift matches the parameter
    /// types in the expression to one of the `appendInterpolation` methods
    /// in ``LocalizedStringKey/StringInterpolation``. The interpolated
    /// types can include numeric values, Foundation types, and OpenSwiftUI
    /// ``Text`` and ``Image`` instances.
    ///
    /// The following example uses a string interpolation with two arguments:
    /// an unlabeled
    /// [Date](https://developer.apple.com/documentation/Foundation/Date)
    /// and a ``Text/DateStyle`` labeled `style`. The compiler maps these to the
    /// method
    /// ``LocalizedStringKey/StringInterpolation/appendInterpolation(_:style:)``
    /// as it builds the string that it creates the
    /// ``LocalizedStringKey`` with.
    ///
    ///     let key = LocalizedStringKey("Date is \(company.foundedDate, style: .offset)")
    ///     let text = Text(key) // Text contains "Date is +45 years"
    ///
    /// You can write this example more concisely, implicitly creating a
    /// ``LocalizedStringKey`` as the parameter to the ``Text``
    /// initializer:
    ///
    ///     let text = Text("Date is \(company.foundedDate, style: .offset)")
    ///
    /// - Parameter stringInterpolation: The string interpolation to use as the
    ///   localization key.
    @_semantics("openswiftui.localized_string_key.init_interpolation")
    @_semantics("swiftui.localized_string_key.init_interpolation")
    public init(stringInterpolation: LocalizedStringKey.StringInterpolation) {
        self.key = stringInterpolation.key
        self.hasFormatting = true
        self.arguments = stringInterpolation.arguments
    }

    var isStyled: Bool {
        for argument in arguments {
            switch argument.storage {
            case .value:
                continue
            case let .text(text, _):
                if text.isStyled() {
                    return true
                }
            case let .attributedString(attributedString):
                if attributedString.isStyled {
                    return true
                }
            #if canImport(Darwin)
            case let .localizedStringResource(resource):
                if resource.resolve(in: .init()).isStyled {
                    return true
                }
            #endif
            }
        }
        #if canImport(Darwin)
        let options = AttributedString.MarkdownParsingOptions(
            allowsExtendedAttributes: false,
            interpretedSyntax: .inlineOnlyPreservingWhitespace,
            failurePolicy: .throwError
        )
        guard let attributedString = try? AttributedString(
            markdown: key,
            options: options,
            baseURL: nil
        ) else {
            return false
        }
        return attributedString.runs[
            AttributeScopes.FoundationAttributes.InlinePresentationIntentAttribute.self,
            AttributeScopes.FoundationAttributes.LinkAttribute.self
        ].contains { inlinePresentationIntent, link, _ in
            inlinePresentationIntent != nil || link != nil
        }
        #else
        return false
        #endif
    }

    package func resolve(
        in environment: EnvironmentValues,
        table: String?,
        bundle: Bundle?
    ) -> String {
        var resolved = Text.ResolvedString()
        resolve(into: &resolved, in: environment, options: [], table: table, bundle: bundle)
        return resolved.string
    }

    func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        options: Text.ResolveOptions,
        table: String?,
        bundle: Bundle?
    ) where T: ResolvedTextContainer {
        #if canImport(Darwin)
        if Semantics.MarkdownSupportForLocalizedStringKey.isEnabled {
            let bundle = bundle ?? .main
            let format = _LocalizeAttributedString(bundle, key, table, environment.locale)
            guard hasFormatting else {
                result.append(format, in: environment, with: options)
                return
            }
            let inflectionArguments = getArgumentsForInflection(
                for: format,
                in: environment,
                idiom: result.idiom,
                with: options,
                including: result.style
            )
            let formattedFormat = withVaList(inflectionArguments.arguments) { arguments in
                NSAttributedString(
                    openSwiftUIAttributedStringWithFormat: format,
                    options: [],
                    locale: environment.locale,
                    arguments: arguments
                )
            }
            resolveArguments(
                from: formattedFormat,
                into: &result,
                in: environment,
                options: options,
                isUniqueSizeVariant: inflectionArguments.isUniqueSizeVariant
            )
        } else {
            let bundle = bundle ?? .main
            let localizedString = _LocalizeString(bundle, key, table, environment.locale)
            guard hasFormatting else {
                result.append(localizedString, in: environment, with: options)
                return
            }
            var isUniqueSizeVariant = environment.textSizeVariant == .regular
            let resolvedArguments = arguments.map { argument -> CVarArg in
                let resolved = argument.resolve(in: environment, idiom: result.idiom)
                isUniqueSizeVariant = isUniqueSizeVariant || resolved.exact
                return resolved.result
            }
            let format = String(
                format: localizedString,
                locale: environment.locale,
                arguments: resolvedArguments
            )
            resolveArguments(
                from: format,
                into: &result,
                in: environment,
                options: options,
                isUniqueSizeVariant: isUniqueSizeVariant
            )
        }
        #else
        let bundle = bundle ?? .main
        let localizedString = _LocalizeString(bundle, key, table, environment.locale)
        guard hasFormatting else {
            result.append(localizedString, in: environment, with: options)
            return
        }
        var isUniqueSizeVariant = environment.textSizeVariant == .regular
        let resolvedArguments = arguments.map { argument -> CVarArg in
            let resolved = argument.resolve(in: environment, idiom: result.idiom)
            isUniqueSizeVariant = isUniqueSizeVariant || resolved.exact
            return resolved.result
        }
        let format = String(
            format: localizedString,
            locale: environment.locale,
            arguments: resolvedArguments
        )
        resolveArguments(
            from: format,
            into: &result,
            in: environment,
            options: options,
            isUniqueSizeVariant: isUniqueSizeVariant
        )
        #endif
    }

    func getArgumentsForInflection(
        for attributedString: NSAttributedString,
        in environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom?,
        with options: Text.ResolveOptions,
        including style: Text.Style
    ) -> (arguments: [CVarArg], isUniqueSizeVariant: Bool) {
        var isUniqueSizeVariant = environment.textSizeVariant == .regular
        let resolvedArguments = arguments.map { argument -> CVarArg in
            #if canImport(Darwin)
            guard case let .text(text, token) = argument.storage,
                  case let .anyTextStorage(anyTextStorage) = text.storage,
                  let attributedStringStorage = anyTextStorage as? AttributedStringTextStorage,
                  attributedStringStorage.str.foundation.morphology != nil else {
                let resolved = argument.resolve(in: environment, idiom: idiom)
                isUniqueSizeVariant = isUniqueSizeVariant || resolved.exact
                return resolved.result
            }
            let locale = environment.locale
            let formatArguments = arguments.map { argument in
                argument.resolve(in: environment, idiom: idiom).result
            }
            let formattedAttributedString = withVaList(formatArguments) { arguments in
                NSAttributedString(
                    openSwiftUIAttributedStringWithFormat: attributedString,
                    options: [],
                    locale: environment.locale,
                    arguments: arguments
                )
            }
            guard let tokenRange = formattedAttributedString.string.range(of: token.string) else {
                let resolved = argument.resolve(in: environment, idiom: idiom)
                isUniqueSizeVariant = isUniqueSizeVariant || resolved.exact
                return resolved.result
            }
            let nsTokenRange = NSRange(tokenRange, in: formattedAttributedString.string)
            let tokenAttributes = formattedAttributedString.attributes(
                at: nsTokenRange.location,
                longestEffectiveRange: nil,
                in: nsTokenRange
            )

            var resolvedStyle = style
            var hasTrackingModifier = false
            for modifier in text.withInlinePresentationIntent(from: tokenAttributes).modifiers.reversed() {
                if case .tracking = modifier {
                    hasTrackingModifier = true
                }
                modifier.modify(style: &resolvedStyle, environment: environment)
            }

            var properties = Text.ResolvedProperties()
            var attributes = resolvedStyle.nsAttributes(
                content: { String(attributedStringStorage.str.characters) },
                environment: environment,
                includeDefaultAttributes: true,
                with: options,
                properties: &properties
            )
            if hasTrackingModifier {
                if let tracking = resolvedStyle.tracking {
                    attributes[.kitTracking] = tracking
                } else {
                    attributes[.kitTracking] = nil
                }
            }
            let result = NSMutableAttributedString(openSwiftUIAttributedString: attributedStringStorage.str)
            result.addAttributes(attributes, range: NSRange(location: 0, length: result.length))
            isUniqueSizeVariant = isUniqueSizeVariant || properties.features.contains(.isUniqueSizeVariant)
            return result
            #else
            let resolved = argument.resolve(in: environment, idiom: idiom)
            isUniqueSizeVariant = isUniqueSizeVariant || resolved.exact
            return resolved.result
            #endif
        }
        return (resolvedArguments, isUniqueSizeVariant)
    }

    func resolvesToEmpty(
        in environment: EnvironmentValues,
        options: Text.ResolveOptions,
        table: String?,
        bundle: Bundle?
    ) -> Bool {
        let bundle = bundle ?? .main
        let localizedString = _LocalizeString(bundle, key, table, environment.locale)
        guard hasFormatting else {
            return localizedString.isEmpty
        }
        let resolvedArguments = arguments.map { argument -> CVarArg in
            argument.resolve(in: environment, idiom: _GraphInputs.defaultInterfaceIdiom).result
        }
        let format = String(
            format: localizedString,
            locale: environment.locale,
            arguments: resolvedArguments
        )
        return format.isEmpty
    }

    func resolveArguments<T>(
        from format: NSAttributedString,
        into result: inout T,
        in environment: EnvironmentValues,
        options: Text.ResolveOptions,
        isUniqueSizeVariant: Bool
    ) where T: ResolvedTextContainer {
        let textArgs = getTextArguments()
        guard !textArgs.isEmpty else {
            result.append(
                format,
                in: environment,
                with: options,
                isUniqueSizeVariant: isUniqueSizeVariant
            )
            return
        }
        let string = format.string
        scan(
            string: string,
            in: environment,
            options: options,
            textArgs: textArgs
        ) { _, range in
            result.append(
                format.attributedSubstring(from: NSRange(range, in: string)),
                in: environment,
                with: options,
                isUniqueSizeVariant: isUniqueSizeVariant
            )
        } appendText: { text, _, environment in
            text.resolve(into: &result, in: environment, with: options)
        }
    }

    func resolveArguments<T>(
        from format: String,
        into result: inout T,
        in environment: EnvironmentValues,
        options: Text.ResolveOptions,
        isUniqueSizeVariant: Bool
    ) where T: ResolvedTextContainer {
        let textArgs = getTextArguments()
        guard !textArgs.isEmpty else {
            result.append(
                format,
                in: environment,
                with: options,
                isUniqueSizeVariant: isUniqueSizeVariant
            )
            return
        }
        scan(
            string: format,
            in: environment,
            options: options,
            textArgs: textArgs
        ) { string, range in
            result.append(
                string[range],
                in: environment,
                with: options,
                isUniqueSizeVariant: isUniqueSizeVariant
            )
        } appendText: { text, _, environment in
            text.resolve(into: &result, in: environment, with: options)
        }

    }

    private func getTextArguments() -> [(Int, LocalizedStringKey.FormatArgument)] {
        arguments.filter { argument in
            guard case .text = argument.storage else {
                return false
            }
            return true
        }.map { argument in
            guard case let .text(_, token) = argument.storage else {
                _openSwiftUIUnreachableCode()
            }
            return (token.id, argument)
        }
    }

    private func scan(
        string: String,
        in environment: EnvironmentValues,
        options: Text.ResolveOptions,
        textArgs: [(Int, LocalizedStringKey.FormatArgument)],
        appendLiteral: (String, Range<String.Index>) -> Void,
        appendText: (Text, Range<String.Index>, EnvironmentValues) -> Void
    ) {
        let argumentMap = Dictionary(uniqueKeysWithValues: textArgs)
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = nil
        let replacement = CharacterSet(charactersIn: String(FormatArgument.Token.delimiter))
        repeat {
            let literalStart = scanner.currentIndex
            if scanner.scanUpToCharacters(from: replacement) != nil {
                appendLiteral(string, literalStart..<scanner.currentIndex)
            }
            let tokenStart = scanner.currentIndex
            guard scanner.scanCharacter() == FormatArgument.Token.delimiter,
                  let tokenID = scanner.scanInt(representation: .decimal),
                  scanner.scanCharacter() == FormatArgument.Token.delimiter else {
                continue
            }
            guard let argument = argumentMap[tokenID],
                  case let .text(text, _) = argument.storage else {
                Log.internalWarning("Text interpolation look up miss.\n    source: \(string)\n    id: \(tokenID)")
                continue
            }
            let tokenEnd = scanner.currentIndex
            let tokenRange = tokenStart..<tokenEnd
            #if canImport(Darwin)
            var textEnvironment = environment
            if string[tokenRange].count != string.count {
                let locale = environment.locale
                let capitalizationContext = environment.capitalizationContext
                if tokenStart == string.startIndex {
                    textEnvironment.capitalizationContext = .lazy {
                        .middleOfSentence == capitalizationContext.resolved ? .middleOfSentence : .beginningOfSentence
                    }
                } else {
                    textEnvironment.capitalizationContext = .lazy {
                        _isBeginningOfSentence(string, String(string[tokenRange]), locale) ? .beginningOfSentence : .middleOfSentence
                    }
                }
            }
            appendText(text, tokenRange, textEnvironment)
            #else
            appendText(text, tokenRange, environment)
            #endif
        } while !scanner.isAtEnd
    }

    // MARK: - LocalizedStringKey.FormatArgument

    @usableFromInline
    struct FormatArgument: Equatable {
        let storage: LocalizedStringKey.FormatArgument.Storage

        init(value: CVarArg, formatter: Formatter? = nil) {
            if let formatter {
                self.storage = .value(value, formatter.copy() as? Formatter)
            } else {
                self.storage = .value(value, nil)
            }
        }

        init(storage: LocalizedStringKey.FormatArgument.Storage) {
            self.storage = storage
        }

        fileprivate func resolve(
            in environment: EnvironmentValues,
            idiom: AnyInterfaceIdiom?
        ) -> (result: CVarArg, exact: Bool) {
            let result: CVarArg
            switch storage {
            case let .value(value, formatter):
                guard let formatter else {
                    result = value
                    break
                }
                (formatter as? EnvironmentConfigurableFormatter)?.configure(in: environment)
                guard let string = formatter.string(for: value) else {
                    Log.externalWarning("The supplied formatter \(formatter) returned `nil` when invoked with \(value). An empty string will be used instead.")
                    result = ""
                    break
                }
                result = string
            case let .text(_, token):
                result = token.string
            case let .attributedString(attributedString):
                _ = environment.accessibilityEnabled
                result = NSAttributedString(openSwiftUIAttributedString: attributedString)
            #if canImport(Darwin)
            case let .localizedStringResource(resource):
                result = NSAttributedString(openSwiftUIAttributedString: resource.resolve(in: environment))
            #endif
            }
            return (result, environment.textSizeVariant == .regular)
        }

        @usableFromInline
        static func == (lhs: LocalizedStringKey.FormatArgument, rhs: LocalizedStringKey.FormatArgument) -> Bool {
            lhs.storage == rhs.storage
        }

        enum Storage: Equatable {
            case value(CVarArg, Formatter?)
            case text(Text, Token)
            case attributedString(AttributedString)
            #if canImport(Darwin)
            // Only appleOS Foundation support LocalizedStringResource
            case localizedStringResource(LocalizedStringResource)
            #endif

            static func == (lhs: Storage, rhs: Storage) -> Bool {
                switch (lhs, rhs) {
                case let (.value(lhsValue, lhsFormatter), .value(rhsValue, rhsFormatter)):
                    return compareValues(lhsValue, rhsValue) && lhsFormatter == rhsFormatter
                case let (.text(lhsText, lhsToken), .text(rhsText, rhsToken)):
                    return lhsText == rhsText && lhsToken == rhsToken
                case let (.attributedString(lhsString), .attributedString(rhsString)):
                    return lhsString == rhsString
                #if canImport(Darwin)
                case let (.localizedStringResource(lhsResource), .localizedStringResource(rhsResource)):
                    return lhsResource == rhsResource
                #endif
                default:
                    return false
                }
            }
        }

        struct Token: Equatable, Hashable, Identifiable {
            let id: Int

            init(id: Int) {
                self.id = id
            }

            @inline(__always)
            static var delimiter: Character { .nsAttachment }

            @inline(__always)
            var string: String {
                "\(Self.delimiter)\(id.description)\(Self.delimiter)"
            }
        }
    }

    // MARK: - LocalizedStringKey.StringInterpolation

    /// Represents the contents of a string literal with interpolations
    /// while it's being built, for use in creating a localized string key.
    public struct StringInterpolation: StringInterpolationProtocol {
        var key: String = ""
        var arguments: [FormatArgument]
        var seed: UniqueSeedGenerator = .init()

        /// Creates an empty instance ready to be filled with string literal content.
        ///
        /// Don't call this initializer directly. Instead, initialize a variable or
        /// constant using a string literal with interpolated expressions.
        ///
        /// Swift passes this initializer a pair of arguments specifying the size of
        /// the literal segments and the number of interpolated segments. Use this
        /// information to estimate the amount of storage you will need.
        ///
        /// - Parameter literalCapacity: The approximate size of all literal segments
        ///   combined. This is meant to be passed to `String.reserveCapacity(_:)`;
        ///   it may be slightly larger or smaller than the sum of the counts of each
        ///   literal segment.
        /// - Parameter interpolationCount: The number of interpolations which will be
        ///   appended. Use this value to estimate how much additional capacity will
        ///   be needed for the interpolated segments.
        @_semantics("openswiftui.localized.interpolation_init")
        @_semantics("swiftui.localized.interpolation_init")
        public init(literalCapacity: Int, interpolationCount: Int) {
            key.reserveCapacity(literalCapacity + interpolationCount * 2)
            arguments = []
            arguments.reserveCapacity(interpolationCount)
        }

        /// Appends a literal string.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// - Parameter literal: The literal string to append.
        @_semantics("openswiftui.localized.appendLiteral")
        @_semantics("swiftui.localized.appendLiteral")
        public mutating func appendLiteral(_ literal: String) {
            key.append(literal.replacingOccurrences(of: "%", with: "%%"))
        }

        /// Appends a literal string segment to a string interpolation.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// - Parameter string: The literal string to append.
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ string: String) {
            key.append("%@")
            arguments.append(.init(value: string))
        }

        /// Appends an optionally-formatted instance of a Foundation type
        /// to a string interpolation.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// - Parameters:
        ///   - subject: The Foundation object to append.
        ///   - formatter: A formatter to convert `subject` to a string
        ///     representation.
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject: ReferenceConvertible {
            appendInterpolation(subject as! NSObject, formatter: formatter)
        }

        /// Appends an optionally-formatted instance of an Objective-C subclass
        /// to a string interpolation.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// The following example shows how to use a
        /// [Measurement](https://developer.apple.com/documentation/Foundation/Measurement)
        /// value and a
        /// [MeasurementFormatter](https://developer.apple.com/documentation/Foundation/MeasurementFormatter)
        /// to create a ``LocalizedStringKey`` that uses the formatter
        /// style
        /// [long](https://developer.apple.com/documentation/foundation/Formatter/UnitStyle/long)
        /// when generating the measurement's string representation. Rather than
        /// calling `appendInterpolation(_:formatter)` directly, the code
        /// gets the formatting behavior implicitly by using the `\()`
        /// string interpolation syntax.
        ///
        ///     let siResistance = Measurement(value: 640, unit: UnitElectricResistance.ohms)
        ///     let formatter = MeasurementFormatter()
        ///     formatter.unitStyle = .long
        ///     let key = LocalizedStringKey("Resistance: \(siResistance, formatter: formatter)")
        ///     let text1 = Text(key) // Text contains "Resistance: 640 ohms"
        ///
        /// - Parameters:
        ///   - subject: An [NSObject](https://developer.apple.com/documentation/objectivec/NSObject)
        ///     to append.
        ///   - formatter: A formatter to convert `subject` to a string
        ///     representation.
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject: NSObject {
            let argument = LocalizedStringKey.FormatArgument(value: subject, formatter: formatter)
            key.append("%@")
            arguments.append(argument)
        }

        /// Appends the formatted representation  of a nonstring type
        /// supported by a corresponding format style.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// The following example shows how to use a string interpolation to
        /// format a
        /// [Date](https://developer.apple.com/documentation/Foundation/Date)
        /// with a
        /// [Date.FormatStyle](https://developer.apple.com/documentation/Foundation/Date/FormatStyle)
        /// and append it to static text. The resulting interpolation implicitly
        /// creates a ``LocalizedStringKey``, which a ``Text`` uses to provide
        /// its content.
        ///
        ///     Text("The time is \(myDate, format: Date.FormatStyle(date: .omitted, time:.complete))")
        ///
        /// - Parameters:
        ///   - input: The instance to format and append.
        ///   - format: A format style to use when converting `input` into a string
        ///   representation.
        @available(OpenSwiftUI_v3_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
            appendInterpolation(Text(input, format: format))
        }

        /// Appends the formatted representation  of a nonstring type
        /// supported by a corresponding format style.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// The following example shows how to use a string interpolation to
        /// format a
        /// [Date](https://developer.apple.com/documentation/Foundation/Date)
        /// with a
        /// [Date.FormatStyle](https://developer.apple.com/documentation/Foundation/Date/FormatStyle)
        /// and append it to static text. The resulting interpolation implicitly
        /// creates a ``LocalizedStringKey``, which a ``Text`` uses to provide
        /// its content.
        ///
        ///     Text("The time is \(myDate, format: Date.FormatStyle(date: .omitted, time:.complete).attributedStyle)")
        ///
        /// - Parameters:
        ///   - input: The instance to format and append.
        ///   - format: A format style to use when converting `input` into an attributed
        ///   string representation.
        @available(OpenSwiftUI_v6_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == AttributedString {
            appendInterpolation(Text(input, format: format))
        }

        /// Appends a type, convertible to a string by using a default format
        /// specifier, to a string interpolation.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// - Parameters:
        ///   - value: A primitive type to append, such as
        ///     [Int](https://developer.apple.com/documentation/swift/Int),
        ///     [UInt32](https://developer.apple.com/documentation/swift/UInt32), or
        ///     [Double](https://developer.apple.com/documentation/swift/Double).
        @_transparent
        public mutating func appendInterpolation<T>(_ value: T) where T: _FormatSpecifiable {
            appendInterpolation(value, specifier: formatSpecifier(T.self))
        }

        /// Appends a type, convertible to a string with a format specifier,
        /// to a string interpolation.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// - Parameters:
        ///   - value: The value to append.
        ///   - specifier: A format specifier to convert `subject` to a string
        ///     representation, like `%f` for a
        ///     [Double](https://developer.apple.com/documentation/swift/Double), or
        ///     `%x` to create a hexidecimal representation of a
        ///     [UInt32](https://developer.apple.com/documentation/swift/UInt32). For a
        ///     list of available specifier strings, see
        ///     [String Format Specifers](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFStrings/formatSpecifiers.html#//apple_ref/doc/uid/TP40004265).
        @_semantics("openswiftui.localized.appendInterpolation_param_specifier")
        @_semantics("swiftui.localized.appendInterpolation_param_specifier")
        public mutating func appendInterpolation<T>(_ value: T, specifier: String) where T: _FormatSpecifiable {
            key.append(specifier)
            arguments.append(.init(storage: .value(value._arg, nil)))
        }

        /// Appends the string displayed by a text view to a string
        /// interpolation.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// - Parameters:
        ///   - value: A ``Text`` instance to append.
        @available(OpenSwiftUI_v2_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ text: Text) {
            let token = LocalizedStringKey.FormatArgument.Token(id: seed.generate())
            let argument = LocalizedStringKey.FormatArgument(storage: .text(text, token))
            key.append("%@")
            arguments.append(argument)
        }

        /// Appends an attributed string to a string interpolation.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// The following example shows how to use a string interpolation to
        /// format an
        /// [AttributedString](https://developer.apple.com/documentation/Foundation/AttributedString)
        /// and append it to static text. The resulting interpolation implicitly
        /// creates a ``LocalizedStringKey``, which a ``Text`` view uses to provide
        /// its content.
        ///
        ///     struct ContentView: View {
        ///
        ///         var nextDate: AttributedString {
        ///             var result = Calendar.current
        ///                 .nextWeekend(startingAfter: Date.now)!
        ///                 .start
        ///                 .formatted(
        ///                     .dateTime
        ///                     .month(.wide)
        ///                     .day()
        ///                     .attributed
        ///                 )
        ///             result.backgroundColor = .green
        ///             result.foregroundColor = .white
        ///             return result
        ///         }
        ///
        ///         var body: some View {
        ///             Text("Our next catch-up is on \(nextDate)!")
        ///         }
        ///     }
        ///
        /// For this example, assume that the app runs on a device set to a
        /// Russian locale, and has the following entry in a Russian-localized
        /// `Localizable.strings` file:
        ///
        ///     "Our next catch-up is on %@!" = "Наша следующая встреча состоится %@!";
        ///
        /// The attributed string `nextDate` replaces the format specifier
        /// `%@`,  maintaining its color and date-formatting attributes, when
        /// the ``Text`` view renders its contents:
        ///
        /// ![A text view with Russian text, ending with a date that uses white
        /// text on a green
        /// background.](LocalizedStringKey-AttributedString-Russian)
        ///
        /// - Parameter attributedString: The attributed string to append.
        @available(OpenSwiftUI_v3_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ attributedString: AttributedString) {
            let argument = LocalizedStringKey.FormatArgument(storage: .attributedString(attributedString))
            key.append("%@")
            arguments.append(argument)
        }

        #if canImport(Darwin)
        /// Appends the localized string resource to a string interpolation.
        ///
        /// Don't call this method directly; it's used by the compiler when
        /// interpreting string interpolations.
        ///
        /// - Parameters:
        ///   - value: The localized string resource to append.
        @available(OpenSwiftUI_v4_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ resource: LocalizedStringResource) {
            let argument = LocalizedStringKey.FormatArgument(storage: .localizedStringResource(resource))
            key.append("%@")
            arguments.append(argument)
        }
        #endif

        @available(*, unavailable, message: "Unsupported type for interpolation, see LocalizedStringKey.StringInterpolation for supported types.")
        public mutating func appendInterpolation<T>(_ view: T) where T: View {
            _openSwiftUIUnreachableCode()
        }
    }
}

// MARK: - LocalizedTextStorage

private final class LocalizedTextStorage: AnyTextStorage, @unchecked Sendable {
    let key: LocalizedStringKey
    let table: String?
    let bundle: Bundle?

    init(key: LocalizedStringKey, table: String?, bundle: Bundle?) {
        self.key = key
        self.table = table
        self.bundle = bundle
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        key.resolve(into: &result, in: environment, options: options, table: table, bundle: bundle)
    }

    override func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) -> Bool {
        key.resolvesToEmpty(in: environment, options: options, table: table, bundle: bundle)
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? LocalizedTextStorage else {
            return false
        }
        return key == other.key &&
        table == other.table &&
        bundle == other.bundle
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        key.isStyled
    }

    override var localizationInfo: _LocalizationInfo {
        .localized(
            key: key.key,
            tableName: table,
            bundle: bundle,
            hasFormatting: key.hasFormatting
        )
    }
}

@available(*, unavailable)
extension LocalizedStringKey.StringInterpolation: Sendable {}

@available(*, unavailable)
extension LocalizedStringKey: Sendable {}

@available(*, unavailable)
extension LocalizedStringKey.FormatArgument: Sendable {}

#if canImport(Darwin)
extension LocalizedStringResource {
    // FIXME
    func resolve(in environment: EnvironmentValues) -> AttributedString {
        var resource = self
        resource.locale = environment.locale
        return AttributedString(localized: resource)
    }
}
#endif

@_alwaysEmitIntoClient
internal var int64Specifier: String {
    get { "%lld" }
}

@_alwaysEmitIntoClient
internal var int32Specifier: String {
    get { "%d" }
}

@_alwaysEmitIntoClient
internal var uint64Specifier: String {
    get { "%llu" }
}

@_alwaysEmitIntoClient
internal var uint32Specifier: String {
    get { "%u" }
}

@_alwaysEmitIntoClient
internal var floatSpecifier: String {
    get { "%f" }
}

@_alwaysEmitIntoClient
internal var doubleSpecifier: String {
    get { "%lf" }
}

@_alwaysEmitIntoClient
@_semantics("constant_evaluable")
internal func formatSpecifier<T>(_ type: T.Type) -> String {
    switch type {
    case is Int.Type:
        fallthrough
    case is Int64.Type:
        return int64Specifier
    case is Int8.Type:
        fallthrough
    case is Int16.Type:
        fallthrough
    case is Int32.Type:
        return int32Specifier
    case is UInt.Type:
        fallthrough
    case is UInt64.Type:
        return uint64Specifier
    case is UInt8.Type:
        fallthrough
    case is UInt16.Type:
        fallthrough
    case is UInt32.Type:
        return uint32Specifier
    case is Float.Type:
        return floatSpecifier
    case is CGFloat.Type:
        fallthrough
    case is Double.Type:
        return doubleSpecifier
    default:
        return "%@"
    }
}

@available(OpenSwiftUI_v1_0, *)
public protocol _FormatSpecifiable: Equatable {
    associatedtype _Arg: CVarArg
    var _arg: Self._Arg { get }
    var _specifier: String { get }
}

@available(OpenSwiftUI_v1_0, *)
extension Int: _FormatSpecifiable {
    public var _arg: Int64 {
        Int64(self)
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Int8: _FormatSpecifiable {
    public var _arg: Int32 {
        Int32(self)
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Int16: _FormatSpecifiable {
    public var _arg: Int32 {
        Int32(self)
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Int32: _FormatSpecifiable {
    public var _arg: Int32 {
        self
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Int64: _FormatSpecifiable {
    public var _arg: Int64 {
        self
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt: _FormatSpecifiable {
    public var _arg: UInt64 {
        UInt64(self)
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt8: _FormatSpecifiable {
    public var _arg: UInt32 {
        UInt32(self)
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt16: _FormatSpecifiable {
    public var _arg: UInt32 {
        UInt32(self)
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt32: _FormatSpecifiable {
    public var _arg: UInt32 {
        self
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt64: _FormatSpecifiable {
    public var _arg: UInt64 {
        self
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Float: _FormatSpecifiable {
    public var _arg: Float {
        self
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Double: _FormatSpecifiable {
    public var _arg: Double {
        self
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension CGFloat: _FormatSpecifiable {
    public var _arg: CGFloat {
        self
    }

    public var _specifier: String {
        formatSpecifier(Self.self)
    }
}

// Non-Darwin compatibility layer
#if !canImport(Darwin)
package func _LocalizeString(_ bundle: Bundle, _ key: String, _ table: String?, _ locale: Locale?) -> String {
    bundle.localizedString(forKey: key, value: nil, table: table)
}

package func _LocalizeAttributedString(_ bundle: Bundle, _ key: String, _ table: String?, _ locale: Locale?) -> NSAttributedString {
    NSAttributedString(string: bundle.localizedString(forKey: key, value: nil, table: table))
}

// Linux Foundation does not provide libswiftObjectiveC's NSObject CVarArg conformance yet.
// Traced on swift-corelibs-foundation#5487
extension NSObject: @retroactive CVarArg {
    public var _cVarArgEncoding: [Int] {
        _encodeBitsAsWords(self)
    }
}

#endif
