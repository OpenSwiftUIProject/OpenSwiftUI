//
//  Text+Accessibility.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by Text.Style
//  ID: 96A6D9E0D6EA43C386EBC45EDA3A548B (SwiftUICore)

package import Foundation

// MARK: - TextAccessibilityProvider

package protocol TextAccessibilityProvider {
    associatedtype Body: View

    static func makeView(
        content: StyledTextContentView,
        text: Text,
        resolved: ResolvedStyledText
    ) -> Body
}

struct EmptyTextAccessibilityProvider: TextAccessibilityProvider {
    static func makeView(
        content: StyledTextContentView,
        text: Text,
        resolved: ResolvedStyledText
    ) -> some View {
        content
    }
}

extension _GraphInputs {
    private struct TextAccessibilityProviderKey: GraphInput {
        static let defaultValue: any TextAccessibilityProvider.Type = EmptyTextAccessibilityProvider.self
    }

    package var textAccessibilityProvider: any TextAccessibilityProvider.Type {
        get { self[TextAccessibilityProviderKey.self] }
        set { self[TextAccessibilityProviderKey.self] = newValue }
    }
}

extension _ViewInputs {
    package var textAccessibilityProvider: any TextAccessibilityProvider.Type {
        get { base.textAccessibilityProvider }
        set { base.textAccessibilityProvider = newValue }
    }
}

// MARK: - AccessibilityText

package struct AccessibilityText: Equatable {
    package enum Storage: Equatable {
        case plain(String)
        case attributed(NSAttributedString)
    }

    package var storage: AccessibilityText.Storage

    package var optional: Bool

    package init(storage: AccessibilityText.Storage, optional: Bool = false) {
        self.storage = storage
        self.optional = optional
    }

    package init?(
        _ text: Text,
        environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom? = nil
    ) {
        let attributedString = AccessibilityCore.textResolvedToAttributedText(
            text,
            in: environment,
            includeResolvableAttributes: true,
            includeDefaultAttributes: true,
            updateResolvableAttributes: false,
            idiom: idiom
        )
        guard let attributedString else {
            return nil
        }
        self.init(storage: .attributed(attributedString), optional: false)
    }

    package init?(
        texts: [Text],
        environment: EnvironmentValues,
        optional: Bool = false,
        idiom: AnyInterfaceIdiom? = nil
    ) {
        let atrributedString = AccessibilityCore.textsResolvedToAttributedText(
            texts,
            in: environment,
            includeResolvableAttributes: true,
            includeDefaultAttributes: true,
            updateResolvableAttributes: false,
            resolveSuffix: false,
            idiom: idiom
        )
        guard let atrributedString else {
            return nil
        }
        self.init(storage: .attributed(atrributedString), optional: optional)
    }

    package init(_ string: Any) {
        #if canImport(Darwin)
        let object = string as AnyObject
        if object.isKind(of: NSAttributedString.self) {
            self.storage = .attributed(object as! NSAttributedString)
            self.optional = false
        } else if let string = object as? String {
            self.storage = .plain(string)
            self.optional = false
        } else {
            preconditionFailure("not a string type")
        }
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }

    package var text: Text {
        Text(anyTextStorage: AccessibilityTextStorage(self))
    }

    package var attributedString: NSAttributedString {
        switch storage {
        case let .plain(string): NSAttributedString(string: string)
        case let .attributed(nSAttributedString): nSAttributedString
        }
    }

    package var isEmpty: Bool {
        switch storage {
        case let .plain(string): string.isEmpty
        case let .attributed(nSAttributedString): nSAttributedString.length < 1
        }
    }
}

// MARK: - AccessibilityTextStorage

final package class AccessibilityTextStorage: AnyTextStorage, @unchecked Sendable {
    package var base: AccessibilityText

    package init(_ base: AccessibilityText) {
        self.base = base
    }

    package var hasResolvableAttributes: Bool {
        base.attributedString.isDynamic
    }
}

// MARK: - AccessibilityText + Protobuf [WIP]

extension AccessibilityText: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

extension AccessibilityText: CodableByProtobuf {}

// MARK: - AccessibilityTextAttributes

package struct AccessibilityTextAttributes: Equatable {
    package var contentType: AccessibilityTextContentType?
    package var headingLevel: AccessibilityHeadingLevel?
    package var durationTimeMMSS: Bool?
    package var label: Text?

    package init(
        contentType: AccessibilityTextContentType? = nil,
        headingLevel: AccessibilityHeadingLevel? = nil,
        durationTimeMMSS: Bool? = nil,
        label: Text? = nil
    ) {
        self.contentType = contentType
        self.headingLevel = headingLevel
        self.durationTimeMMSS = durationTimeMMSS
        self.label = label
    }

    package func combined(with other: AccessibilityTextAttributes) -> AccessibilityTextAttributes {
        AccessibilityTextAttributes(
            contentType: other.contentType ?? contentType,
            headingLevel: other.headingLevel ?? headingLevel,
            durationTimeMMSS: other.durationTimeMMSS ?? durationTimeMMSS,
            label: other.label ?? label
        )
    }

    package static func == (lhs: AccessibilityTextAttributes, rhs: AccessibilityTextAttributes) -> Bool {
        lhs.contentType?.rawValue == rhs.contentType?.rawValue &&
        lhs.headingLevel == rhs.headingLevel &&
        lhs.durationTimeMMSS == rhs.durationTimeMMSS &&
        lhs.label == rhs.label
    }
}

// MARK: - AccessibilityTextModifier [WIP]

final package class AccessibilityTextModifier: AnyTextModifier {
    package let value: AccessibilityTextAttributes

    package init(_ value: AccessibilityTextAttributes) {
        self.value = value
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        options.contains(.includeAccessibility)
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        // TODO: Text.Style
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? AccessibilityTextModifier else {
            return false
        }
        return value == other.value
    }
}

// MARK: - AccessibilityImageLabel

package enum AccessibilityImageLabel: Equatable {
    case text(Text)
    case systemSymbol(String)

    package init?(_ description: String?) {
        guard let description else { return nil }
        self = .text(.init(verbatim: description))
    }

    package init?(_ description: Text?) {
        guard let description else { return nil }
        self = .text(description)
    }

    private class SystemSymbolTextStorage: AnyTextStorage, @unchecked Sendable {
        var symbolName: String

        init(symbolName: String) {
            self.symbolName = symbolName
        }

        override func resolve<T>(
            into result: inout T,
            in environment: EnvironmentValues,
            with options: Text.ResolveOptions
        ) where T: ResolvedTextContainer {
            guard options.contains(.includeAccessibility),
                  let description = AccessibilityCore.description(for: symbolName, in: environment)
            else {
                result.append(symbolName, in: environment, with: options)
                return
            }
            result.append(description, in: environment, with: options)
        }

        override func isEqual(to other: AnyTextStorage) -> Bool {
            guard let other = other as? SystemSymbolTextStorage else {
                return false
            }
            return symbolName == other.symbolName
        }
    }

    package var text: Text {
        switch self {
        case let .text(text):
            text
        case let .systemSymbol(string):
            Text(anyTextStorage: SystemSymbolTextStorage(symbolName: string))
        }
    }
}

// MARK: - Text + storedAccessibilityLabel

extension Text {
    package var storedAccessibilityLabel: Text? {
        for modifier in modifiers.reversed() {
            guard case let .anyTextModifier(textModifier) = modifier,
                  let accessibilityTextModifier = textModifier as? AccessibilityTextModifier,
                  let label = accessibilityTextModifier.value.label
            else {
                continue
            }
            return label
        }
        return nil
    }
}
