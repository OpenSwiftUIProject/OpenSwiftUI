//
//  Text+Localized.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8C53218A357EE528547B0855666BD2E5 (SwiftUICore)

public import Foundation
import OpenAttributeGraphShims

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
    /// [https://developer.apple.com/documentation/Foundation/AttributeScopes/FoundationAttributes/3796122-imageURL](imageURL)
    /// attribute. Parsing with OpenSwiftUI treats any whitespace in the Markdown
    /// string as described by the
    /// [https://developer.apple.com/documentation/Foundation/AttributedString/MarkdownParsingOptions/InterpretedSyntax/inlineOnlyPreservingWhitespace](inlineOnlyPreservingWhitespace)
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

// MARK: - LocalizedStringKey

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct LocalizedStringKey: Equatable, ExpressibleByStringInterpolation {
    var key: String
    var hasFormatting: Bool = false
    private var arguments: [LocalizedStringKey.FormatArgument]

    public init(_ value: String) {
        self.init(stringLiteral: value)
    }

    @_semantics("openswiftui.localized_string_key.init_literal")
    @_semantics("swiftui.localized_string_key.init_literal")
    public init(stringLiteral value: String) {
        self.key = value
        self.arguments = []
    }

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


    func getArgumentsForInflection(
        for attributedString: NSAttributedString,
        in environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom?,
        with options: Text.ResolveOptions,
        including style: Text.Style
    ) -> (arguments: [CVarArg], isUniqueSizeVariant: Bool) {
        var isUniqueSizeVariant = environment.textSizeVariant == .regular
        let resolvedArguments = arguments.map { argument -> CVarArg in
            // TODO: AttributedStringTextStorage
            let resolved = argument.resolve(in: environment, idiom: idiom)
            isUniqueSizeVariant = isUniqueSizeVariant || resolved.exact
            return resolved.result
        }
        return (resolvedArguments, isUniqueSizeVariant)
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
                result = "\u{FFFC}\(token.id.description)\u{FFFC}"
            case let .attributedString(attributedString):
                _ = environment.accessibilityEnabled
                result = NSAttributedString(openSwiftUIAttributedString: attributedString)
            case let .localizedStringResource(resource):
                result = NSAttributedString(openSwiftUIAttributedString: resource.resolve(in: environment))
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
        }
    }

    // MARK: - LocalizedStringKey.StringInterpolation

    public struct StringInterpolation: StringInterpolationProtocol {
        var key: String = ""
        var arguments: [FormatArgument]
        var seed: UniqueSeedGenerator = .init()

        @_semantics("openswiftui.localized.interpolation_init")
        @_semantics("swiftui.localized.interpolation_init")
        public init(literalCapacity: Int, interpolationCount: Int) {
            key.reserveCapacity(literalCapacity + interpolationCount * 2)
            arguments = []
            arguments.reserveCapacity(interpolationCount)
        }

        @_semantics("openswiftui.localized.appendLiteral")
        @_semantics("swiftui.localized.appendLiteral")
        public mutating func appendLiteral(_ literal: String) {
            key.append(literal.replacingOccurrences(of: "%", with: "%%"))
        }

        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ string: String) {
            key.append("%@")
            arguments.append(.init(value: string))
        }

        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject: ReferenceConvertible {
            appendInterpolation(subject as! NSObject, formatter: formatter)
        }

        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject: NSObject {
            let argument = LocalizedStringKey.FormatArgument(value: subject, formatter: formatter)
            key.append("%@")
            arguments.append(argument)
        }

        @available(OpenSwiftUI_v3_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
            appendInterpolation(Text(input, format: format))
        }

        @available(OpenSwiftUI_v6_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == AttributedString {
            appendInterpolation(Text(input, format: format))
        }

        @_transparent
        public mutating func appendInterpolation<T>(_ value: T) where T: _FormatSpecifiable {
            appendInterpolation(value, specifier: formatSpecifier(T.self))
        }

        @_semantics("openswiftui.localized.appendInterpolation_param_specifier")
        @_semantics("swiftui.localized.appendInterpolation_param_specifier")
        public mutating func appendInterpolation<T>(_ value: T, specifier: String) where T: _FormatSpecifiable {
            key.append(specifier)
            arguments.append(.init(storage: .value(value._arg, nil)))
        }

        @available(OpenSwiftUI_v2_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ text: Text) {
            let token = LocalizedStringKey.FormatArgument.Token(id: seed.generate())
            let argument = LocalizedStringKey.FormatArgument(storage: .text(text, token))
            key.append("%@")
            arguments.append(argument)
        }

        @available(OpenSwiftUI_v3_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        @_semantics("swiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ attributedString: AttributedString) {
            let argument = LocalizedStringKey.FormatArgument(storage: .attributedString(attributedString))
            key.append("%@")
            arguments.append(argument)
        }

        #if canImport(Darwin)
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

    public static func == (a: LocalizedStringKey, b: LocalizedStringKey) -> Bool {
        a.key == b.key &&
        a.hasFormatting == b.hasFormatting &&
        a.arguments == b.arguments
    }

    private func localizedFormat(table: String?, bundle: Bundle?) -> String {
        let bundle = bundle ?? .main
        return bundle.localizedString(forKey: key, value: nil, table: table)
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
