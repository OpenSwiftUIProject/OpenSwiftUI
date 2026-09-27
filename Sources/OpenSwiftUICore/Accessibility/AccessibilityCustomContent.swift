//
//  AccessibilityCustomContent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AB2166DCFF9943AF0BA6B5EE55765400 (SwiftUICore)

#if canImport(Accessibility)
public import Accessibility
#endif

// MARK: - AccessibilityCustomContentKey

/// Key used to specify the identifier and label associated with
/// an entry of additional accessibility information.
///
/// Use `AccessibilityCustomContentKey` and the associated modifiers taking
/// this value as a parameter in order to simplify clearing or replacing
/// entries of additional information that are manipulated from multiple places
/// in your code.
@available(OpenSwiftUI_v3_0, *)
public struct AccessibilityCustomContentKey {
    enum Identifier: Equatable {
        case string(String)
        case text(Text)
    }

    var identifier: Identifier
    var label: Text

    /// Create an `AccessibilityCustomContentKey` with the specified label and
    /// identifier.
    ///
    /// - Parameter label: Localized text describing to the user what
    ///   is contained in this additional information entry. For example:
    ///   "orientation".
    /// - Parameter id: String used to identify the additional information entry
    ///   to OpenSwiftUI. Adding an entry will replace any previous value with the
    ///   same identifier.
    public init(_ label: Text, id: String) {
        identifier = .string(id)
        self.label = label
    }

    /// Create an `AccessibilityCustomContentKey` with the specified label and
    /// identifier.
    ///
    /// - Parameter labelKey: Localized text describing to the user what
    ///   is contained in this additional information entry. For example:
    ///   "orientation".
    /// - Parameter id: String used to identify the additional information entry
    ///   to OpenSwiftUI. Adding an entry will replace any previous value with the
    ///   same identifier.
    public init(_ labelKey: LocalizedStringKey, id: String) {
        self.init(Text(labelKey), id: id)
    }

    /// Create an `AccessibilityCustomContentKey` with the specified label.
    ///
    /// - Parameter labelKey: Localized text describing to the user what
    ///   is contained in this additional information entry. For example:
    ///   "orientation". This will also be used as the identifier.
    public init(_ labelKey: LocalizedStringKey) {
        self.init(Text(labelKey))
    }

    package init(_ text: Text) {
        identifier = .text(text)
        label = text
    }
}

@available(*, unavailable)
extension AccessibilityCustomContentKey: Sendable {}

@available(OpenSwiftUI_v3_0, *)
extension AccessibilityCustomContentKey: Equatable {}

// MARK: - AccessibilityCustomContentEntry

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
public struct AccessibilityCustomContentEntry: Equatable {
    public typealias Importance = AXCustomContent.Importance

    enum Value: Equatable {
        case text(Text, Importance)
        case value(AnyAccessibilityValue, Importance)
        case clear
    }

    var key: AccessibilityCustomContentKey
    var value: Value

    public init(_ key: AccessibilityCustomContentKey, value: Text, importance: Importance = .default) {
        self.key = key
        self.value = .text(value, importance)
    }

    package init<V>(_ key: AccessibilityCustomContentKey, value: V, importance: Importance = .default)
    where V: AccessibilityValue & Codable {
        self.key = key
        self.value = .value(AnyAccessibilityValue(value), importance)
    }

    package init(clearing key: AccessibilityCustomContentKey) {
        self.key = key
        value = .clear
    }
}

@_spi(Private)
@available(*, unavailable)
extension AccessibilityCustomContentEntry: Sendable {}

// MARK: - AccessibilityCustomContentList

package typealias AccessibilityCustomContentList = [AccessibilityCustomContentEntry]

extension Array where Element == AccessibilityCustomContentEntry {
    package func resolve(in environment: EnvironmentValues) -> [AXCustomContent] {
        var result: [AXCustomContent] = []
        var identifiers: Set<String> = []
        for entry in self {
            let identifier = switch entry.key.identifier {
            case let .string(string): string
            case let .text(text): text.resolveString(in: environment)
            }
            guard !identifier.isEmpty, !identifiers.contains(identifier) else {
                continue
            }
            identifiers.insert(identifier)

            let resolvedValue: String
            let importance: Element.Importance
            switch entry.value {
            case let .text(value, valueImportance):
                resolvedValue = value.resolveString(in: environment)
                importance = valueImportance
            case let .value(value, valueImportance):
                resolvedValue = value.localizedDescription ?? ""
                importance = valueImportance
            case .clear:
                continue
            }
            let content = AXCustomContent(
                label: entry.key.label.resolveString(in: environment),
                value: resolvedValue
            )
            content.importance = importance
            result.insert(content, at: 0)
        }
        return result
    }
}

// MARK: - CodableAccessibilityCustomContentList

struct CodableAccessibilityCustomContentList: Codable {
    private struct CodableEntry: Codable {
        struct CodableKey: Codable {
            var identifier: AccessibilityText?
            var label: AccessibilityText?

            init(_ key: AccessibilityCustomContentKey, in environment: EnvironmentValues) {
                switch key.identifier {
                case let .string(string):
                    identifier = AccessibilityText(string)
                case let .text(text):
                    identifier = AccessibilityText(text, environment: environment)
                }
                label = AccessibilityText(key.label, environment: environment)
            }
        }

        struct CodableValue: Codable {
            enum Content: Codable {
                case text(AccessibilityText)
                case value(AnyAccessibilityValue)
            }

            var clear: Bool = false
            var content: Content?
            @ProxyCodable var importance: AccessibilityCustomContentEntry.Importance? = nil

            init(_ value: AccessibilityCustomContentEntry.Value, in environment: EnvironmentValues) {
                switch value {
                case let .text(text, importance):
                    if let text = AccessibilityText(text, environment: environment) {
                        content = .text(text)
                        self.importance = importance
                    }
                case let .value(value, importance):
                    content = .value(value)
                    self.importance = importance
                case .clear:
                    clear = true
                }
            }
        }

        var codableKey: CodableKey
        var codableValue: CodableValue
    }

    private var codableEntries: [CodableEntry]

    init(_ entries: AccessibilityCustomContentList, in environment: EnvironmentValues) {
        codableEntries = entries.map {
            CodableEntry(
                codableKey: .init($0.key, in: environment),
                codableValue: .init($0.value, in: environment)
            )
        }
    }

    var customContentList: AccessibilityCustomContentList {
        codableEntries.compactMap { entry in
            guard let identifier = entry.codableKey.identifier, let label = entry.codableKey.label else {
                return nil
            }
            var key = AccessibilityCustomContentKey(identifier.text)
            key.label = label.text
            var result = AccessibilityCustomContentEntry(clearing: key)
            if entry.codableValue.clear {
                return result
            }
            guard let content = entry.codableValue.content, let importance = entry.codableValue.importance else {
                return nil
            }
            switch content {
            case let .text(text):
                result.value = .text(text.text, importance)
            case let .value(value):
                result.value = .value(value, importance)
            }
            return result
        }
    }
}

// MARK: - AXCustomContent.Importance + CodableByProxy

extension AXCustomContent.Importance: CodableByProxy {
    package var codingProxy: UInt {
        rawValue
    }

    package static func unwrap(codingProxy rawValue: UInt) -> Self {
        Self(rawValue: rawValue)!
    }
}
