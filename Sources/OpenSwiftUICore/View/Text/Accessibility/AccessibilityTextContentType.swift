//
//  AccessibilityTextContentType.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// Textual context that assistive technologies can use to improve the
/// presentation of spoken text.
///
/// Use an `AccessibilityTextContentType` value when setting the accessibility text content
/// type of a view using the ``View/accessibilityTextContentType(_:)`` modifier.
///
@available(OpenSwiftUI_v3_0, *)
public struct AccessibilityTextContentType: Sendable {
    package enum RawValue: UInt, Codable {
        case plain
        case console
        case fileSystem
        case messaging
        case narrative
        case sourceCode
        case spreadsheet
        case wordProcessing
    }

    package var rawValue: RawValue

    package init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    /// A type that represents generic text that has no specific type.
    public static let plain: AccessibilityTextContentType = .init(.plain)

    /// A type that represents text used for input, like in the Terminal app.
    public static let console: AccessibilityTextContentType = .init(.console)

    /// A type that represents text used by a file browser, like in the Finder app in macOS.
    public static let fileSystem: AccessibilityTextContentType = .init(.fileSystem)

    /// A type that represents text used in a message, like in the Messages app.
    public static let messaging: AccessibilityTextContentType = .init(.messaging)

    /// A type that represents text used in a story or poem, like in the Books app.
    public static let narrative: AccessibilityTextContentType = .init(.narrative)

    /// A type that represents text used in source code, like in Swift Playgrounds.
    public static let sourceCode: AccessibilityTextContentType = .init(.sourceCode)

    /// A type that represents text used in a grid of data, like in the Numbers app.
    public static let spreadsheet: AccessibilityTextContentType = .init(.spreadsheet)

    /// A type that represents text used in a document, like in the Pages app.
    public static let wordProcessing: AccessibilityTextContentType = .init(.wordProcessing)
}

extension AccessibilityTextContentType: CodableByProxy {
    package var codingProxy: RawValue {
        rawValue
    }

    package static func unwrap(codingProxy rawValue: RawValue) -> AccessibilityTextContentType {
        .init(rawValue)
    }
}

extension AccessibilityTextContentType: ProtobufEnum {
    package var protobufValue: UInt {
        rawValue.rawValue
    }

    package init?(protobufValue v: UInt) {
        guard let rawValue = RawValue(rawValue: v) else {
            return nil
        }
        self.rawValue = rawValue
    }
}
